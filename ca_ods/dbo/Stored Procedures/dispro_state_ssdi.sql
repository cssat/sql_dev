CREATE procedure [dbo].[dispro_state_ssdi]
as
BEGIN

/*
    Calculate DI After Intake or After Removal for each decision point

	This query first unpivots the measure columns from dispro_data
	Adds a DI/AI column
	And fills in the DI/AI column by joining to a subquery that
		year, measure, and optionally region and selects the rate corresponding
		to the reference race (White or Non-Hispanic White only).
*/


if object_id('tempdb..##dispro_state_ssdi') is not null drop table ##dispro_state_ssdi;
select
  year
	-- , intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
	, sum(value) numerator
	, count(*) denominator
	, sum(value) * 1.0 / count(*) rate
	, cast(NULL as float) ssdi
INTO ##dispro_state_ssdi
FROM
(select
  -- non-pivot columns
    year
	-- , intake_region
	, TX_MULTI_RACE_ETHNICITY
  -- pivot columns
    , measure
	, value
FROM dispro_data
	UNPIVOT (value for measure in (
		  screen_in
		, removal
		, removal_60day
		, removal_2yr
		, not_reun_within_1yr
		, kin_not_1st_placement
		, initial_instability
		, ongoing_instability
	)) as measure) unpvt
WHERE
 --   intake_region in (
	--	 'Region 1'
	--	,'Region 2'
	--	,'Region 3'
	--	,'Region 4'
	--	,'Region 5'
	--	,'Region 6'
	--) AND
	TX_MULTI_RACE_ETHNICITY <> 'Unknown'
GROUP BY 
  year
	-- , intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure
ORDER BY
  year
	-- , intake_region
	, TX_MULTI_RACE_ETHNICITY
	, measure;


UPDATE du 
SET du.ssdi = cast(iif(wr.white_rate = 0, 0.0, du.rate * 1.0 / wr.white_rate) as float)
FROM ##dispro_state_ssdi du
LEFT JOIN 
	(select year
	-- , intake_region
	, measure
	, rate white_rate
	from ##dispro_state_ssdi
	where TX_MULTI_RACE_ETHNICITY = 'White/Caucasian') wr
ON du.year = wr.year
	-- AND du.intake_region = wr.intake_region
	AND du.measure = wr.measure;

END;