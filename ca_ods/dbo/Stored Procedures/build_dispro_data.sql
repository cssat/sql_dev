CREATE procedure [dbo].[build_dispro_data]
as
BEGIN

/*
		Dispro Query

Overall map:

	1. Select children identified in intakes off of rptIntake_children
	2. Link to removals under DCFS authority
	3. De-duplicate based on severity, then time
	4. Keep the (temporally) closest linked removal
*/

-- this is just for POC, at CA you should be able to set this to a more recent date
DECLARE @last_update datetime;
SET @last_update = (select top 1 cutoff_date from ref_last_dw_transfer);

/*
	1. Select children identified in intakes off of rptIntake_children
		
		Exclusion criteria:
		- only children with age recorded as between 0 and 17
		- only CPS intakes marked with CPS_YESNO field as 'YES'

		Defining the intake_region as the CASE_REGION field
		Including several race columns, though at this point we are only use TX_MULTI_RACE_ETHNICITY
		Defining whether or not the intake was screened-in based on SCREEN_DCSN field
*/

if object_id('tempdb..#dispro_intakes') is not null drop table #dispro_intakes;
SELECT
    -- ID
	  ri.ID_ACCESS_REPORT
	, ri.VICS_ID_CHILDREN id_child
	, iif(ri.ANY_FOUNDED = 'YES', 1, 0) founded
	-- TIME
	, ri.DT_ACCESS_RCVD
	, year(ri.dt_access_rcvd) year
	, NULL intake_rank
	-- GEOG
	, ri.case_region intake_region
	, rint.FIRST_WORKER_REGION
	-- RACE
	, ri.SINGLE_RACE
	, ri.TX_MULTI_RACE_ETHNICITY
	, ri.CD_MULTI_RACE_ETHNICITY
	, ri.TX_HSPNC
	-- MEASURES
	, iif(ri.SCREEN_DCSN = 'Screen In', 1, 0) screen_in
INTO #dispro_intakes
FROM [base].rptIntake_children ri
	LEFT JOIN [base].rptIntakes_CA rint
	ON ri.ID_ACCESS_REPORT = rint.ID_ACCESS_REPORT
WHERE
	year(ri.dt_ACCESS_RCVD) between 2006 and 2014
	and ri.CPS_YESNO = 'YES'
	and ri.AGE between 0 and 17


/*
-- Some tests

SELECT top 1000 * FROM #dispro_intakes;

SELECT
year(di.DT_ACCESS_RCVD) year
, count(*) count_all
, avg(screen_in * 1.0) screen_rate
FROM #dispro_intakes di
group by year(di.dt_access_rcvd)
ORDER BY year;
*/

/*
	2. Link to removals under DCFS authority
	"any qualifying removal that occurred within a year following intake... regardless
	of whether or not it is also linked to an intake from a different year"

	We do an INNER JOIN to rptPlacement, so this temp table will only have
	children with removals within 12 montsh of a CPS intake. When we join back
	to the #dispro_intakes table, it will be filled in with NULLs for children
	without associated removals.

	We also do two LEFT JOIN to rptPlacement_Events, once selecting first placements
	where plcmnt_seq = 1 (for initial placement not with kin)
	and again selecting third placements within 1 year where plcmnt_seq = 3
	and datediff(d, rpe3.removal_dt, rpe3.begin_date) <= 365 (for initial instability)

	Exclusion crtieria:
	- Only screened-in intakes are matched 
		di.screen_in = 1
	- Only removals within 1 year of intake up to 3 days before
		datediff(d, di.DT_ACCESS_RCVD, pl.removal_dt) between -3 and 365
	- Only removals where that are not closed before the intake (only pertains
		is the removal started within 3 days before the intake)
	- Only removals under DCFS placement authority
		pl.cd_placement_care_auth in (1, 2)
	
	Measures defined:
	- because of the inner join, all matches are removals, hence 
		1 removal
	- 60-day (deprecated) and 2-year removals based on episode_los
	- no reunification within one year based on episode_los and exit_reason
		iif(pl.episode_los < 365 AND  pl.exit_reason = 'Reunification', 0, 1) not_reun_within_1yr
	- Kin not 1st placement based on kin placements as cd_plcm_setng in (10, 11, 15)
	- Initial instability if a third placement exists within 1 year of removal
	- Ongoing instability if the episode_los > 730
	    and the time from the last placement to either today (still in care) or the discharge date (exited care) is less than 365 days
*/

-- Linking Removals

if object_id('tempdb..#removal_link') is not null drop table #removal_link;

SELECT 
	  di.ID_ACCESS_REPORT
	, di.id_child
	, DATEDIFF(d, di.DT_ACCESS_RCVD, pl.removal_dt) intake_to_removal_days
	, pl.id_removal_episode_fact
	, pl.episode_los
	, 1 removal -- doing an inner join with rptPlacement means every matching record is a removal
	, iif(pl.episode_los > 60, 1, 0) removal_60day
	, iif(pl.episode_los > 730, 1, 0) removal_2yr
	, iif(pl.episode_los < 365 AND  pl.exit_reason = 'Reunification', 0, 1) not_reun_within_1yr
	-- cd_plcm_setng 10 is licensed relative, 
	 --   11 is licensed godparent/supp ntwrk/ tribal relative/ relative of unsepcified degree
	 --   15 is unlicensed relative of specified degree
	, iif(rpe1.cd_plcm_setng in (10, 11, 15), 0, 1) kin_not_1st_placement
	, iif(rpe3.row_id IS NOT NULL, 1, 0) initial_instability
	-- ongoing instability if in care more than 2 years AND moved within last 12 months
	, iif(pl.episode_los > 730
		AND datediff(d, pl.latest_plcmnt_dt, iif(pl.discharge_dt > @last_update, @last_update, pl.discharge_dt)) < 365, 1, 0) ongoing_instability
INTO #removal_link
FROM
	#dispro_intakes di
	INNER JOIN [base].rptPlacement pl
		ON di.ID_CHILD = pl.child
			AND datediff(d, di.DT_ACCESS_RCVD, pl.removal_dt) between -3 and 365
			AND di.DT_ACCESS_RCVD < pl.discharge_dt
			AND di.screen_in = 1 -- only interested in matches for screened-in intakes
			-- placement care authority DCFS placements only!
			AND pl.cd_placement_care_auth in (1, 2) -- DCFS and CLOSED only (closed for historical data according to Tammy)
	-- join to the first placement for kin_not_1st_placement
	LEFT JOIN base.rptPlacement_Events rpe1
		on pl.id_removal_episode_fact = rpe1.id_removal_episode_fact
		AND rpe1.plcmnt_seq = 1
	-- join to third placements within one year for initial_instability
	LEFT JOIN base.rptPlacement_Events rpe3
		on pl.id_removal_episode_fact = rpe3.id_removal_episode_fact
		AND rpe3.plcmnt_seq = 3
		AND datediff(d, rpe3.removal_dt, rpe3.begin_date) <= 365;

/*
select top 100 * from #removal_link
*/

/*
	3. For each child/intake, select one per year.

	The selection is will first prefer intakes with a finding,
	next prefer screened-in intakes,
	and last prefer time, taking the first one within the year.
*/


-- update intake table with intake ranks
UPDATE di2
SET intake_rank = temp.intake_rank2
FROM 
#dispro_intakes di2
INNER JOIN (
	SELECT *, 
	ROW_NUMBER() over(
					PARTITION BY
						di1.year
						, di1.id_child
					ORDER BY 
						di1.founded desc
						, di1.screen_in desc
						, di1.dt_access_rcvd
			) AS intake_rank2
			FROM #dispro_intakes di1
) AS temp 
	ON temp.id_child = di2.id_child
		AND temp.ID_ACCESS_REPORT = di2.ID_ACCESS_REPORT;


DELETE FROM #dispro_intakes
WHERE intake_rank > 1;

/*
select top 100 * from #dispro_intakes
*/


/*
	4. Keeping the closest removal to the intake from those linked above
*/

if object_id('tempdb..#removal_link_closest') is not null drop table #removal_link_closest;

SELECT
	  rl.ID_ACCESS_REPORT
	, rl.id_child
	, rl.id_removal_episode_fact
	, rl.episode_los
	, rl.removal
	, rl.removal_60day
	, rl.removal_2yr
	, rl.not_reun_within_1yr
	, rl.kin_not_1st_placement
	, rl.initial_instability
	, rl.ongoing_instability
INTO #removal_link_closest
FROM #removal_link rl
INNER JOIN (
	SELECT
		rlsub.ID_ACCESS_REPORT
		, rlsub.id_child
		, min(rlsub.intake_to_removal_days) min_intake_to_removal
	FROM #removal_link rlsub
	GROUP BY rlsub.ID_ACCESS_REPORT
	         , rlsub.id_child
	) rl_min
  ON rl.ID_ACCESS_REPORT = rl_min.ID_ACCESS_REPORT
  AND rl.id_child = rl_min.id_child
  AND rl.intake_to_removal_days   = rl_min.min_intake_to_removal

/*
	select top 100 * from #removal_link_longest
*/


-- FINAL SELECT

if object_id('dbo.dispro_data') is not null drop table [dbo].[dispro_data];
SELECT
  -- UNIQUE ID
	  di.ID_ACCESS_REPORT
	, di.id_child
  -- TIME
	, di.DT_ACCESS_RCVD
	, di.year
  -- GEOG INFO
	, di.intake_region
  -- RACE INFO
	, di.SINGLE_RACE
	, di.CD_MULTI_RACE_ETHNICITY
	, di.TX_MULTI_RACE_ETHNICITY
	, di.TX_HSPNC
  -- MEASURES
	, di.screen_in
	, iif(di.screen_in = 0, NULL, isnull(rll.removal, 0)) removal
	, rll.removal_60day
	, rll.removal_2yr
	, rll.not_reun_within_1yr
	, rll.kin_not_1st_placement
	, rll.initial_instability
	, rll.ongoing_instability
INTO [dbo].dispro_data
FROM #dispro_intakes di
	LEFT JOIN #removal_link_closest rll 
	  ON di.ID_ACCESS_REPORT = rll.ID_ACCESS_REPORT
	  AND di.id_child = rll.id_child
WHERE intake_rank = 1


END;