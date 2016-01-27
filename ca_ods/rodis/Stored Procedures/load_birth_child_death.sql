-- =============================================
-- Author:		Brian Waismeyer
-- Create date: 1-27-2016
-- Description:	Script to create rodis.birth_child_death (BCD).
-- =============================================
CREATE PROCEDURE [rodis].[load_birth_child_death]
AS
/*
The purpose of this script is to create a table where each row is a 
unique record of a birth-child-death event, coupled with
record variables identified as useful to POC analysis projects.

The table is initially constructed from a full outer join between
WA birth records and WA death records. This base data is then
expanded with a full outer join to WA child administration (CA) data. 

In other words, any observed child may have any combination of birth, 
welfare, or death records. However, children (who experieced a death) 
with a birth record are highly likely to have a death record and vice versa.

The end result is that most children have a single row in the
table. However, children with WA death record will have as many
rows as they have secondary causes of death.
*/

-- We construct a base table with full outer joins between WA birth
-- and WA death records.
TRUNCATE TABLE rodis.birth_child_death
 
-- NOTE: We use cd_birth_fact and cd_death_fact as our identifiers
-- because they can be used to link to either the rodis_wh fact 
-- tables or to the rodis.* source tables (they both correspond to
-- the bc_uni fields in all the rodis.* source tables).
;WITH raw_bd AS (
	SELECT bf.cd_birth_fact [id_birth]
		,df.cd_death_fact [id_death]
		,bf.id_prsn_child [id_child_birth]
		,df.id_prsn_child [id_child_death]
	FROM rodis_wh.birth_fact bf
	FULL OUTER JOIN rodis_wh.death_dim dd ON bf.id_birth_administration = dd.id_birth_administration
	LEFT JOIN rodis_wh.death_fact df ON dd.id_death = df.id_death
	)

-- Sometimes the birth record is associated with a CA
-- child ID, sometimes the death record is, and sometimes
-- both are. When both birth and death record are associated
-- with a CA ID, they always agree as to which ID they are
-- associated with. We coalesce the id_child columns into
-- a single column so we can use it as our foreign key for linking
-- to CA records.
,clean_bd AS (
	SELECT bd.id_birth
		,bd.id_death
		,ISNULL(bd.id_child_birth, bd.id_child_death) [id_child]
	FROM raw_bd bd
	)

-- Now we make the link to our CA records, resulting in the
-- most barebones version of our BCD table.
,clean_bcd AS (
	SELECT bd.id_birth
		,pd.ID_PRSN [id_child]
		,bd.id_death
	FROM clean_bd bd
	FULL OUTER JOIN dbo.PEOPLE_DIM pd ON bd.id_child = pd.ID_PRSN
	WHERE pd.IS_CURRENT = 1
		OR (
			pd.IS_CURRENT IS NULL
			AND bd.id_child IS NULL
			)
	)

/*
TRANSITION

At this point we have our barebones dataframe. Given the events 
we have collected thus far, every row can be thought of as 
representing a single child and every child should only have a 
single row.

This is probably not quite true as we know there was some error
in the CA--WA record matching process. But since we can't identify
who is a failed match v. who has no link, its an assumption we'll 
proceed under.

It's time to attach some variables!
*/

-- We start by adding some flags to make it easy to subset
-- the data by what records are available.
,t1 AS (
	SELECT bcd.*
		,CASE 
			WHEN id_birth IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_birth_record]
		,CASE 
			WHEN id_child IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_ca_record]
		,CASE 
			WHEN id_death IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_death_record]
		,CASE 
			WHEN id_birth IS NOT NULL
				AND id_child IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_birth_and_ca_records]
		,CASE 
			WHEN id_birth IS NOT NULL
				AND id_child IS NOT NULL
				AND id_death IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_all_records]
	FROM clean_bcd bcd
	)

-- Next we start adding dates of major events. First, birth!
-- We have two potential sources of birth data - CA records
-- and birth records. We pull from both and then create a
-- third column coalescing the two sources, favoring the birth
-- record when both sources are available.
,t2 AS (
	SELECT t.*
		,pd.DT_BIRTH AS child_birth_date_ca
		,br_date.CALENDAR_DATE AS child_birth_date_br
		,CASE 
			WHEN br_date.CALENDAR_DATE IS NOT NULL
				THEN br_date.CALENDAR_DATE
			ELSE pd.DT_BIRTH
			END [child_birth_date]
	FROM t1 t
	LEFT JOIN dbo.PEOPLE_DIM pd ON t.id_child = pd.ID_PRSN
		AND pd.IS_CURRENT = 1
	LEFT JOIN rodis_wh.birth_fact bf ON t.id_birth = bf.cd_birth_fact
	LEFT JOIN dbo.CALENDAR_DIM br_date ON bf.id_calendar_dim_birth_child = br_date.ID_CALENDAR_DIM
	)

-- Now date of injury (leading to death) and death where we have records. 
-- We also add a column calculating the days from birth to death.
,t3 AS (
	SELECT t.*
		,cd_injury.CALENDAR_DATE [child_fatal_injury_date]
		,cd_death.CALENDAR_DATE [child_death_date]
		,DATEDIFF(DAY, t.child_birth_date, cd_injury.CALENDAR_DATE) [days_birth_to_fatal_injury]
		,DATEDIFF(DAY, t.child_birth_date, cd_death.CALENDAR_DATE) [days_birth_to_death]
	FROM t2 t
	LEFT JOIN rodis_wh.death_fact df ON t.id_death = df.cd_death_fact
	LEFT JOIN dbo.CALENDAR_DIM cd_death ON df.id_calendar_dim_death = cd_death.ID_CALENDAR_DIM
	LEFT JOIN dbo.CALENDAR_DIM cd_injury ON df.id_calendar_dim_injury = cd_injury.ID_CALENDAR_DIM
	)

-- We don't add variables for birth here. Those can be grabbed
-- from the companion table, rodis.birth_child_intake_removal (BCIR).
-- Admittedly, BCIR will only have data for those children who have
-- either a birth record OR who have CA data and experienced at least
-- one intake/removal event. But those are probably the children
-- we are actually considered with analysing.

-- Instead, we focus on variables relative to the death event.

-- First we build a temp table for contrasts between the death events and
-- major CA events.
,any_intake AS (
	SELECT t.id_child
		,SUM(CASE 
				WHEN bcir.intake_date < t.child_fatal_injury_date
					AND bcir.intake_before_birth_fl = 0
					THEN 1
				ELSE 0
				END) [count_intakes_after_birth_before_fatal_injury]
		,SUM(CASE 
				WHEN bcir.intake_date < t.child_death_date
					AND bcir.intake_before_birth_fl = 0
					THEN 1
				ELSE 0
				END) [count_intakes_after_birth_before_death]
	FROM t3 t
	LEFT JOIN rodis.birth_child_intake_removal bcir ON t.id_child = bcir.id_child
	GROUP BY t.id_child
    )

-- Then we add our flags to our base table.
,t4 AS (
	SELECT t.*
		,IIF(ai.count_intakes_after_birth_before_fatal_injury > 0, 'yes', 'no') [any_intakes_after_birth_before_fatal_injury]
		,IIF(ai.count_intakes_after_birth_before_death > 0, 'yes', 'no') [any_intakes_after_birth_before_death]
	FROM t3 t
	LEFT JOIN any_intake ai ON t.id_child = ai.id_child
	)

-- Next we add on where the death occurred, the child
-- residene at the time of death, what the
-- primary underlying cause of death was given as,
-- and how this cause of death qualifies in our
-- death flag system.
,t5 AS (
	SELECT t.*
		,bd.d_rcnty [cd_residence_county]
		,rcnty.Portal_County [residence_county]
		,bd.d_dcnty [cd_death_county]
		,dcnty.Portal_County [death_county]
		,CASE 
			WHEN t.has_death_record = 'no'
				OR t.child_death_date IS NULL
				THEN NULL
			WHEN t.child_death_date >= '1/1/1999'
				THEN 'ICD-10'
			ELSE 'ICD-9'
			END [cause_of_death_icd_type]
		,CASE 
			WHEN t.has_death_record = 'no'
				THEN NULL
			ELSE dd.cd_ucode
			END [main_cause_of_death_icd]
	FROM t4 t
	LEFT JOIN rodis_wh.death_fact df ON t.id_death = df.cd_death_fact
	LEFT JOIN rodis_wh.death_dim dd ON df.id_death = dd.id_death
	LEFT JOIN rodis.bab_died bd ON t.id_death = bd.bc_uni
	LEFT JOIN rodis.portal_xwalk_ref_cnty rcnty ON bd.d_rcnty = rcnty.RODIS_County_Code
	LEFT JOIN rodis.portal_xwalk_ref_cnty dcnty ON bd.d_rcnty = dcnty.RODIS_County_Code
	)

,t6 AS (
	SELECT t.*
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_all_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				AND (
					t.main_cause_of_death_icd LIKE '8%'
					OR t.main_cause_of_death_icd LIKE '9%'
					)
				THEN 1
			ELSE 0
			END [mcod_eph_all_injury_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_intentional_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [mcod_eph_intentional_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_unintentional_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [mcod_eph_unintentional_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_undetermined_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [mcod_eph_undetermined_fl]
	FROM t5 t
	LEFT JOIN rodis.xwalk_icd_10_to_eph icd10 ON t.main_cause_of_death_icd LIKE icd10.icd_10_head + '%'
	)

-- Next we grow the list with secondary causes of death. As before, 
,t7 AS (
	SELECT t.*
		,CASE 
			WHEN t.has_death_record = 'no'
				THEN NULL
			ELSE codd.cd_cause_of_death
			END [other_cause_of_death_icd]
		,codo.cause_of_death_order [other_cause_of_death_order]
	FROM t6 t
	LEFT JOIN rodis_wh.death_fact df ON t.id_death = df.cd_death_fact
	LEFT JOIN rodis_wh.cause_of_death_m2m_fact codf ON df.id_death = codf.id_death
	LEFT JOIN rodis_wh.cause_of_death_dim codd ON codf.id_cause_of_death = codd.id_cause_of_death
	LEFT JOIN rodis_wh.cause_of_death_order_dim codo ON codf.id_cause_of_death_order = codo.id_cause_of_death_order
	)

-- We add how these secondary causes of death qualify in our
-- death flag system.
,t8 AS (
	SELECT t.*
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_all_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				AND (
					t.other_cause_of_death_icd LIKE '8%'
					OR t.other_cause_of_death_icd LIKE '9%'
					)
				THEN 1
			ELSE 0
			END [ocod_eph_all_injury_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_intentional_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [ocod_eph_intentional_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_unintentional_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [ocod_eph_unintentional_fl]
		,CASE 
			WHEN t.cause_of_death_icd_type IS NULL
				THEN NULL
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.cause_of_death_icd_type = 'ICD-10'
				THEN icd10.eph_undetermined_injury_fl
			WHEN t.cause_of_death_icd_type = 'ICD-9'
				THEN NULL
			END [ocod_eph_undetermined_fl]
	FROM t7 t
	LEFT JOIN rodis.xwalk_icd_10_to_eph icd10 ON t.other_cause_of_death_icd LIKE icd10.icd_10_head + '%'
	)

-- Next we build our rollup death flags for each child. 
-- First we build a supporting temp table to assess each child's 
-- collection of secondary causes of death.
,ocod_counts AS (
	SELECT t.id_death
		,SUM(t.ocod_eph_all_injury_fl) [eph_all_injury_count]
		,SUM(t.ocod_eph_intentional_fl) [eph_intentional_count]
		,SUM(t.ocod_eph_unintentional_fl) [eph_unintentional_count]
		,SUM(t.ocod_eph_undetermined_fl) [eph_undetermined_count]
	FROM t8 t
	WHERE t.has_death_record = 'yes'
	GROUP BY t.id_death
    )

-- Now we use both our main cause of death flags and
-- our other cause of death counts to build the rollup
-- death flags.
,t9 AS (
	SELECT t.*
		,CASE 
			WHEN has_death_record = 'no'
				THEN NULL
			WHEN ocod.eph_all_injury_count > 0
				OR t.mcod_eph_all_injury_fl > 0
				THEN 1
			ELSE 0
			END [rollup_eph_all_injury_fl]
		,CASE 
			WHEN has_death_record = 'no'
				THEN NULL
			WHEN ocod.eph_intentional_count > 0
				OR t.mcod_eph_intentional_fl > 0
				THEN 1
			ELSE 0
			END [rollup_eph_intentional_fl]
		,CASE 
			WHEN has_death_record = 'no'
				THEN NULL
			WHEN ocod.eph_unintentional_count > 0
				OR t.mcod_eph_unintentional_fl > 0
				THEN 1
			ELSE 0
			END [rollup_eph_unintentional_fl]
		,CASE 
			WHEN has_death_record = 'no'
				THEN NULL
			WHEN ocod.eph_undetermined_count > 0
				OR t.mcod_eph_undetermined_fl > 0
				THEN 1
			ELSE 0
			END [rollup_eph_undetermined_fl]
	FROM t8 t
	LEFT JOIN ocod_counts ocod ON t.id_death = ocod.id_death
	)

-- Now we populate our permanent target table. As part of
-- this process, we move other cause of death to the front
-- of the table to be grouped with the other members of
-- the composite primary key.
-- Note that this code should be run so that the composite
-- primary key columns have their NULLs switched to 0s.
INSERT rodis.birth_child_death (
	id_birth
	,id_child
	,id_death
	,death_secondary_cause_order
	,has_birth_record
	,has_ca_record
	,has_death_record
	,has_birth_and_ca_records
	,has_all_records
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,child_fatal_injury_date
	,child_death_date
	,days_birth_to_fatal_injury
	,days_birth_to_death
	,any_intakes_after_birth_before_fatal_injury
	,any_intakes_after_birth_before_death
	,cd_residence_county
	,residence_county
	,cd_death_county
	,death_county
	,cause_of_death_icd_type
	,main_cause_of_death_icd
	,mcod_eph_all_injury_fl
	,mcod_eph_intentional_fl
	,mcod_eph_unintentional_fl
	,mcod_eph_undetermined_fl
	,other_cause_of_death_icd
	,ocod_eph_all_injury_fl
	,ocod_eph_intentional_fl
	,ocod_eph_unintentional_fl
	,ocod_eph_undetermined_fl
	,rollup_eph_all_injury_fl
	,rollup_eph_intentional_fl
	,rollup_eph_unintentional_fl
	,rollup_eph_undetermined_fl
	)
SELECT ISNULL(id_birth, 0)
	,ISNULL(id_child, 0)
	,ISNULL(id_death, 0)
	,ISNULL(other_cause_of_death_order, 1)
	,has_birth_record
	,has_ca_record
	,has_death_record
	,has_birth_and_ca_records
	,has_all_records
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,child_fatal_injury_date
	,child_death_date
	,days_birth_to_fatal_injury
	,days_birth_to_death
	,any_intakes_after_birth_before_fatal_injury
	,any_intakes_after_birth_before_death
	,cd_residence_county
	,residence_county
	,cd_death_county
	,death_county
	,cause_of_death_icd_type
	,main_cause_of_death_icd
	,mcod_eph_all_injury_fl
	,mcod_eph_intentional_fl
	,mcod_eph_unintentional_fl
	,mcod_eph_undetermined_fl
	,other_cause_of_death_icd
	,ocod_eph_all_injury_fl
	,ocod_eph_intentional_fl
	,ocod_eph_unintentional_fl
	,ocod_eph_undetermined_fl
	,rollup_eph_all_injury_fl
	,rollup_eph_intentional_fl
	,rollup_eph_unintentional_fl
	,rollup_eph_undetermined_fl
FROM t9
