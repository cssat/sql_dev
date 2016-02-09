-- =============================================
-- Author:		Brian Waismeyer
-- Create date: 1-27-2016
-- Description:	Script to populate rodis.birth_child_hospital (BCH).
-- =============================================
CREATE PROCEDURE [rodis].[load_birth_child_hospital]
AS
/*
The purpose of this script is to create a table where each row is a 
unique record of a birth-child-hospital event, coupled with
record variables identified as useful to POC analysis projects.

The table is initially constructed from a full outer join between
WA birth records and WA hospital records. This base data is then
expanded with a full outer join to WA child administration (CA) data. 

In other words, any observed child may have any combination of birth, 
welfare, or hospital records. However, children (who experienced a
hospitalization) with a birth record are highly likely to have a hospital 
record and vice versa.

The end result is that most children have a single row in the
table. However, children with WA hospital record will have as many
rows as they have hospitalizations.
*/

-- We construct a base table with full outer joins between WA birth
-- and WA hospital records.
TRUNCATE TABLE rodis.birth_child_hospital

-- NOTE: We use cd_birth_fact as birth identifier and bc_uni as
-- our hospital identifier
-- because they can be used to link to either the rodis_wh.* fact 
-- tables or to the rodis.* source tables (it corresponds to
-- bc_uni).
;WITH raw_bh AS (
	SELECT bf.cd_birth_fact [id_birth]
		,haf.bc_uni [id_hospitalization]
		,haf.id_hospital_admission [id_hospital_admission]
		,bf.id_prsn_child [id_child_birth]
		,haf.id_prsn_child [id_child_hospital]
	FROM rodis_wh.birth_fact bf
	FULL OUTER JOIN rodis_wh.hospital_admission_fact haf ON bf.cd_birth_fact = haf.bc_uni
	)

-- Sometimes the birth record is associated with a CA
-- child ID, sometimes the hospital record is, and sometimes
-- both are. When both birth and hospital record are associated
-- with a CA ID, they always agree as to which ID they are
-- associated with. We coalesce the id_child columns into
-- a single column so we can use it as our foreign key for linking
-- to CA records.
,clean_bh AS (
	SELECT bh.id_birth
		,bh.id_hospitalization
		,bh.id_hospital_admission
		,ISNULL(bh.id_child_birth, bh.id_child_hospital) [id_child]
	FROM raw_bh bh
	)

-- Now we make the link to our CA records, resulting in the
-- most barebones version of our BCH table.
,clean_bch AS (
	SELECT bh.id_birth
		,pd.ID_PRSN [id_child]
		,bh.id_hospitalization
		,bh.id_hospital_admission
	FROM clean_bh bh
	FULL OUTER JOIN dbo.PEOPLE_DIM pd ON bh.id_child = pd.ID_PRSN
	WHERE pd.IS_CURRENT = 1
		OR (
			pd.IS_CURRENT IS NULL
			AND bh.id_child IS NULL
			)
	)

/*
TRANSITION

At this point we have our barebones dataframe. Given the events 
we have collected thus far, every row can be thought of as 
representing a single child hospital admission. In other words,
every birth--child--hospitalization link should be unique and 
BCH links may be associated with 0 or more admissions.

This is probably not quite true as we know there was some error
in the CA--WA record matching process. But since we can't identify
who is a failed match v. who has no link, its an assumption we'll 
proceed under.

It's time to attach some variables!
*/

-- We start by adding some flags to make it easy to subset
-- the data by what records are available.
, t1 AS (
	SELECT bch.*
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
			WHEN id_hospital_admission IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_hospital_record]
		,CASE 
			WHEN id_birth IS NOT NULL
				AND id_child IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_birth_and_ca_records]
		,CASE 
			WHEN id_birth IS NOT NULL
				AND id_child IS NOT NULL
				AND id_hospital_admission IS NOT NULL
				THEN 'yes'
			ELSE 'no'
			END [has_all_records]
	FROM clean_bch bch
	)

-- Next we start adding dates of major events. First, birth!
-- We have two potential sources of birth data - CA records
-- and birth records. We pull from both and then create a
-- third column coalescing the two sources, favoring the birth
-- record when both sources are available.
,t2 AS (
	SELECT t.*
		,pd.DT_BIRTH [child_birth_date_ca]
		,br_date.CALENDAR_DATE [child_birth_date_br]
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

-- Next we add admission and discharge dates.
,t3 AS (
	SELECT t.*
		,cd_admit.CALENDAR_DATE [admission_date]
		,cd_dis.CALENDAR_DATE [discharge_date]
	FROM t2 t
	LEFT JOIN rodis_wh.hospital_admission_fact haf ON t.id_hospital_admission = haf.id_hospital_admission
	LEFT JOIN dbo.CALENDAR_DIM cd_admit ON haf.id_calendar_dim_admit = cd_admit.ID_CALENDAR_DIM
	LEFT JOIN dbo.CALENDAR_DIM cd_dis ON haf.id_calendar_dim_discharge = cd_dis.ID_CALENDAR_DIM
	)

-- Now calculate order of each admission for each child.
,t4 AS (
	SELECT t.*
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			ELSE DENSE_RANK() OVER (
					PARTITION BY id_birth
					,id_child
					,id_hospitalization ORDER BY admission_date
					)
			END [admission_order]
	FROM t3 t
	)

-- Next we grab some relative dates for each child: their
-- first and previous admissions.
,t5 AS (
	SELECT t.*
		,MIN(admission_date) OVER (
			PARTITION BY id_birth
			,id_child
			,id_hospitalization
			) [first_admission_date]
		,lag(admission_date, 1) OVER (
			PARTITION BY id_birth
			,id_child
			,id_hospitalization ORDER BY admission_order
			) [previous_admission_date]
	FROM t4 t
	)

-- Next we calculate some key durations.
,t6 AS (
	SELECT t.*
		,DATEDIFF(DAY, t.child_birth_date, t.first_admission_date) [days_birth_to_first_admission]
		,DATEDIFF(DAY, t.child_birth_date, t.admission_date) [days_birth_to_admission]
		,DATEDIFF(DAY, t.first_admission_date, t.admission_date) [days_first_admission_to_admission]
		,DATEDIFF(DAY, t.previous_admission_date, t.admission_date) [days_previous_admission_to_admission]
		,DATEDIFF(DAY, t.admission_date, t.discharge_date) [days_admission_to_discharge]
	FROM t5 t
	)

-- Now we expand the table with variables describing the
-- hospital admission context.
,t7 AS (
	SELECT t.*
		,had.id_facility
		,had.cd_facility
		,had.tx_admission_source [admission_point_of_entry]
		,had.tx_admission_reason [admission_reason]
		,pd_first.cd_payment [primary_payment_cd]
		,pd_first.tx_payment [primary_payment_category]
		,pd_second.cd_payment [secondary_payment_cd]
		,pd_second.tx_payment [secondary_payment_category]
		,CASE 
			WHEN has_hospital_record = 'no'
				THEN NULL
			WHEN (
					pd_first.cd_payment IN (1, 2)
					AND ISNULL(pd_second.cd_payment, 0) NOT IN (4, 6, 610, 625, 630, 8, 9)
					)
				OR (
					pd_second.cd_payment IN (1, 2)
					AND ISNULL(pd_first.cd_payment, 0) NOT IN (4, 6, 610, 625, 630, 8, 9)
					)
				THEN 'public insurance only'
			WHEN (
					pd_first.cd_payment IN (4, 6, 610, 625, 630, 8, 9)
					AND ISNULL(pd_second.cd_payment, 0) NOT IN (1, 2)
					)
				OR (
					pd_second.cd_payment IN (4, 6, 610, 625, 630, 8, 9)
					AND ISNULL(pd_first.cd_payment, 0) NOT IN (1, 2)
					)
				THEN 'private insurance only'
			WHEN (
					pd_first.cd_payment IN (1, 2)
					AND pd_second.cd_payment IN (4, 6, 610, 625, 630, 8, 9)
					)
				OR (
					pd_second.cd_payment IN (1, 2)
					AND pd_first.cd_payment IN (4, 6, 610, 625, 630, 8, 9)
					)
				THEN 'public and private insurance'
			ELSE 'payment type not recorded'
			END [joint_payment_category]
		,haf.am_hospital_charges [dollars_hospital_charges]
	FROM t6 t
	LEFT JOIN rodis_wh.hospital_admission_fact haf ON t.id_hospital_admission = haf.id_hospital_admission
	LEFT JOIN rodis_wh.hospital_admission_dim had ON t.id_hospital_admission = had.id_hospital_admission
	LEFT JOIN rodis_wh.payment_dim pd_first ON had.id_payment_primary = pd_first.id_payment
	LEFT JOIN rodis_wh.payment_dim pd_second ON had.id_payment_secondary = pd_second.id_payment
	)

-- For our next step, we observe what type of ICD code 
-- was used (based on admission date) and collect the 
-- ICD code associated with the admission.
,t8 AS (
	SELECT t.*
		,(
			CASE 
				WHEN t.has_hospital_record = 'no'
					THEN NULL
				WHEN t.admission_date >= '10/1/2015'
					THEN 'ICD-10'
				ELSE 'ICD-9'
				END
			) [admission_icd_type]
		,dod.cd_diagnosis_order [admission_icd_order]
		,dm.cd_diagnosis [admission_icd]
	FROM t7 t
	LEFT JOIN rodis_wh.hospital_admission_dim had ON t.id_hospital_admission = had.id_hospital_admission
	LEFT JOIN rodis_wh.diagnosis_m2m_fact dmf ON t.id_hospital_admission = dmf.id_hospital_admission
	LEFT JOIN rodis_wh.diagnosis_dim dm ON dmf.id_diagnosis = dm.id_diagnosis
	LEFT JOIN rodis_wh.diagnosis_order_dim dod ON dmf.id_diagnosis_order = dod.id_diagnosis_order
	)

-- Next we create the EPH injury flags. In the original data,
-- we only observe ICD-9 codes. However, the logic has been
-- prepared to handle 9 or 10 codes as needed.
,t9 AS (
	SELECT t.*
		,CASE 
			WHEN t.admission_icd_type IS NULL
				THEN NULL
			WHEN t.admission_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.admission_icd_type = 'ICD-10'
				THEN icd10.eph_all_injury_fl
			WHEN t.admission_icd_type = 'ICD-9'
				AND (
					t.admission_icd LIKE '8%'
					OR t.admission_icd LIKE '9%'
					)
				THEN 1
			ELSE 0
			END [icd_eph_all_injury_fl]
		,CASE 
			WHEN t.admission_icd_type IS NULL
				THEN NULL
			WHEN t.admission_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.admission_icd_type = 'ICD-10'
				THEN icd10.eph_intentional_injury_fl
			WHEN t.admission_icd_type = 'ICD-9'
				THEN NULL
			END [icd_eph_intentional_fl]
		,CASE 
			WHEN t.admission_icd_type IS NULL
				THEN NULL
			WHEN t.admission_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.admission_icd_type = 'ICD-10'
				THEN icd10.eph_unintentional_injury_fl
			WHEN t.admission_icd_type = 'ICD-9'
				THEN NULL
			END [icd_eph_unintentional_fl]
		,CASE 
			WHEN t.admission_icd_type IS NULL
				THEN NULL
			WHEN t.admission_icd_type = 'ICD-10'
				AND icd10.icd_10_head IS NULL
				THEN 0
			WHEN t.admission_icd_type = 'ICD-10'
				THEN icd10.eph_undetermined_injury_fl
			WHEN t.admission_icd_type = 'ICD-9'
				THEN NULL
			END [icd_eph_undetermined_fl]
	FROM t8 t
	LEFT JOIN rodis.xwalk_icd_10_to_eph icd10 ON t.admission_icd LIKE icd10.icd_10_head + '%'
	)

-- Next we build our rollup injury flags for each child. 

-- First we build a supporting temp table to assess each child's
-- per admission collection of injury flags.
,visit_counts AS (
	SELECT t.id_hospitalization
		,t.id_hospital_admission
		,SUM(t.icd_eph_all_injury_fl) [eph_all_injury_count]
		,SUM(t.icd_eph_intentional_fl) [eph_intentional_count]
		,SUM(t.icd_eph_unintentional_fl) [eph_unintentional_count]
		,SUM(t.icd_eph_undetermined_fl) [eph_undetermined_count]
	FROM t9 t
	WHERE t.has_hospital_record = 'yes'
	GROUP BY t.id_hospitalization
		,t.id_hospital_admission
	)

-- Then we build a supporting temp table to assess each child's 
-- global collection of injury flags.
,global_counts AS (
	SELECT t.id_hospitalization
		,SUM(t.icd_eph_all_injury_fl) [eph_all_injury_count]
		,SUM(t.icd_eph_intentional_fl) [eph_intentional_count]
		,SUM(t.icd_eph_unintentional_fl) [eph_unintentional_count]
		,SUM(t.icd_eph_undetermined_fl) [eph_undetermined_count]
	FROM t9 t
	WHERE t.has_hospital_record = 'yes'
	GROUP BY t.id_hospitalization
	)

-- And we join our main table to the temp tables to get
-- the rollups for each child.
,t10 AS (
	SELECT t.*
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN vc.eph_all_injury_count > 0
				THEN 1
			ELSE 0
			END [admission_eph_all_injury_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN vc.eph_intentional_count > 0
				THEN 1
			ELSE 0
			END [admission_eph_intentional_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN vc.eph_unintentional_count > 0
				THEN 1
			ELSE 0
			END [admission_eph_unintentional_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN vc.eph_undetermined_count > 0
				THEN 1
			ELSE 0
			END [admission_eph_undetermined_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN gc.eph_all_injury_count > 0
				THEN 1
			ELSE 0
			END [ever_eph_all_injury_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN gc.eph_intentional_count > 0
				THEN 1
			ELSE 0
			END [ever_eph_intentional_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN gc.eph_unintentional_count > 0
				THEN 1
			ELSE 0
			END [ever_eph_unintentional_fl]
		,CASE 
			WHEN t.has_hospital_record = 'no'
				THEN NULL
			WHEN gc.eph_undetermined_count > 0
				THEN 1
			ELSE 0
			END [ever_eph_undetermined_fl]
	FROM t9 t
	LEFT JOIN visit_counts vc ON t.id_hospitalization = vc.id_hospitalization
		AND t.id_hospital_admission = vc.id_hospital_admission
	LEFT JOIN global_counts gc ON t.id_hospitalization = gc.id_hospitalization
	)

-- Now we populate our permanent target table. As part of
-- this process, we move admission_icd_order to the front
-- of the table to be grouped with the other members of
-- the composite primary key.
-- Note that this code should be run so that the composite
-- primary key columns have their NULLs switched to 0s.

INSERT rodis.birth_child_hospital (
	id_birth
	,id_child
	,id_hospitalization
	,id_hospital_admission
	,admission_icd_order
	,has_birth_record
	,has_ca_record
	,has_hospital_record
	,has_birth_and_ca_records
	,has_all_records
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,admission_date
	,discharge_date
	,admission_order
	,first_admission_date
	,previous_admission_date
	,days_birth_to_first_admission
	,days_birth_to_admission
	,days_first_admission_to_admission
	,days_previous_admission_to_admission
	,days_admission_to_discharge
	,id_facility
	,cd_facility
	,admission_point_of_entry
	,admission_reason
	,primary_payment_cd
	,primary_payment_category
	,secondary_payment_cd
	,secondary_payment_category
	,joint_payment_category
	,dollars_hospital_charges
	,admission_icd_type
	,admission_icd
	,icd_eph_all_injury_fl
	,icd_eph_intentional_fl
	,icd_eph_unintentional_fl
	,icd_eph_undetermined_fl
	,admission_eph_all_injury_fl
	,admission_eph_intentional_fl
	,admission_eph_unintentional_fl
	,admission_eph_undetermined_fl
	,ever_eph_all_injury_fl
	,ever_eph_intentional_fl
	,ever_eph_unintentional_fl
	,ever_eph_undetermined_fl
	)
SELECT ISNULL(id_birth, 0)
	,ISNULL(id_child, 0)
	,ISNULL(id_hospitalization, 0)
	,ISNULL(id_hospital_admission, 0)
	,ISNULL(admission_icd_order, 1)
	,has_birth_record
	,has_ca_record
	,has_hospital_record
	,has_birth_and_ca_records
	,has_all_records
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,admission_date
	,discharge_date
	,admission_order
	,first_admission_date
	,previous_admission_date
	,days_birth_to_first_admission
	,days_birth_to_admission
	,days_first_admission_to_admission
	,days_previous_admission_to_admission
	,days_admission_to_discharge
	,id_facility
	,cd_facility
	,admission_point_of_entry
	,admission_reason
	,primary_payment_cd
	,primary_payment_category
	,secondary_payment_cd
	,secondary_payment_category
	,joint_payment_category
	,dollars_hospital_charges
	,admission_icd_type
	,admission_icd
	,icd_eph_all_injury_fl
	,icd_eph_intentional_fl
	,icd_eph_unintentional_fl
	,icd_eph_undetermined_fl
	,admission_eph_all_injury_fl
	,admission_eph_intentional_fl
	,admission_eph_unintentional_fl
	,admission_eph_undetermined_fl
	,ever_eph_all_injury_fl
	,ever_eph_intentional_fl
	,ever_eph_unintentional_fl
	,ever_eph_undetermined_fl
FROM t10
