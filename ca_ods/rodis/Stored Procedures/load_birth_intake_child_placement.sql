CREATE PROCEDURE [rodis].[load_birth_intake_child_placement]
AS
/* 
SCRIPT TO CREATE A BIRTH-CHILD-INTAKE-PLACEMENT 
COLLECTION OF RECORDS SUITED FOR DUPLICATING EPH'S WORK 

V.1 
*/

/*
our goal is to create a table where each row is a unique
record of a birth-child-intake-placement, coupled with a
family of variables useful for POC data projects
(especially birth record work)

this table and its construction are identical to
`rodis.child_intake_children` except that we adjust
the logic to retain even the birth records without
a CA link

our first major step is getting all of the unique
child-intake-placement events available in our CA data

there are three sources of data for these records:
- base.rptIntake_children: this is supposed to be all
	unique child-intake events but often misses children
	who were in a reported home - and thus eventually
	part of the intake - but not part of the initial
	report
- base.tbl_household_children: this captures more than
	base.rptIntake_children but still misses a few that
	base.rptIntake_children has
- base.rptPlacement: this can be used to determine if
	a child-intake event is associated with a placement;
	it also includes child IDs that are not linked to
	an intake ID in either base.rptIntake_children or
	base.tbl_household_children; we can assume that
	intakes occurred for these children, making this
	also a source of some missed intakes

later, we will expand this to be all birth-child-intake-placement
events by joining to:
- rodis_wh.birth_fact

once these tables are joined, every birth-child-intake-placement
ID combination should be unique - in other words those
columns should be usable as a composite primary key

we will enforce that primary key logic and then gather
the variables we want associated with each record from
both CA data and birth record data
*/

-- selecting target cols from rptIntake_children
-- and getting ID_INTAKE_FACT from INTAKE_FACT so
-- that we can join to tbl_household_children (note
-- that we exclude reports that don't have a valid
-- person ID)
SELECT 
	rp.VICS_ID_CHILDREN AS id_child_ic,
	infa.ID_INTAKE_FACT AS id_intake_ic,
	rp.ID_ACCESS_REPORT AS id_access_report
INTO #clean_ic
FROM base.rptIntake_children AS rp
LEFT JOIN dbo.INTAKE_FACT AS infa
	ON rp.ID_ACCESS_REPORT = infa.ID_ACCESS_REPORT
WHERE rp.VICS_ID_CHILDREN <> 0

-- the full join between the selected cols from
-- rptIntake_children and tbl_household_children -
-- the shared cols are retained and will need to 
-- be compared and merged
SELECT 
	ic.id_child_ic AS id_child_ic,
	hc.id_prsn_child AS id_child_hc,
	ic.id_intake_ic AS id_intake_ic,
	hc.id_intake_fact AS id_intake_hc,
	ic.id_access_report AS id_access_report
INTO #raw_ic_hc
FROM base.tbl_household_children AS hc
FULL OUTER JOIN #clean_ic AS ic
	ON hc.id_prsn_child = ic.id_child_ic
		AND hc.id_intake_fact = ic.id_intake_ic

-- create a new column to track the source of
-- the IDs we are going to retain (did we get the
-- child-intake from rptIntake_children, 
-- tbl_household_children, or both?)

-- also can be used to check for conflicts arising
-- during the join, but these should not actually
-- happen (and did not when I inspected the data)
SELECT	ih.*,
		(
		CASE
			WHEN id_child_ic IS NOT NULL
				AND id_child_hc IS NOT NULL
				AND id_child_ic = id_child_hc
			THEN 'match'
			WHEN id_child_ic IS NOT NULL
				AND id_child_hc IS NOT NULL
				AND id_child_ic <> id_child_hc
			THEN 'mismatch'
			WHEN id_child_ic IS NOT NULL
				AND id_child_hc IS NULL
			THEN 'ic_only'
			WHEN id_child_ic IS NULL
				AND id_child_hc IS NOT NULL
			THEN 'hc_only'
		END
		) AS ic_hc_selection
INTO #trans_ic_hc
FROM #raw_ic_hc as ih

-- merge the shared columns using COALESCE - this
-- will retain the first value if the two columns
-- both have values but will otherwise retain
-- whichever value is NOT NULL
SELECT 
	COALESCE(id_child_ic, id_child_hc) AS id_child,
	COALESCE(id_intake_ic, id_intake_hc) AS id_intake,
	ic_hc_selection
INTO #clean_ic_hc
FROM #trans_ic_hc

-- now we do the full join to rptPlacement to get
-- our placement linkings for our current child-intake
-- records; this will also add some more child IDs -
-- those children that were linked to a placement but
-- did not have their intake recorded; we assume that
-- an intake must have taken place and so retain these
SELECT
	ih.*,
	p.id_placement_fact AS id_placement,
	p.child AS id_child_p
INTO #raw_ic_hc_p
FROM #clean_ic_hc AS ih
FULL OUTER JOIN base.rptPlacement AS p
	ON ih.id_child = p.child
		AND ih.id_intake = p.id_intake_fact

-- again we need to COALESCE to merge shared cols and
-- we also finalize our data source tracking based
-- on the ic_hc_selection col
SELECT 
	COALESCE(id_child, id_child_p) AS id_child,
	id_intake,
	id_placement,
	(
	CASE
		WHEN ic_hc_selection = 'match'
		THEN 'intake and household'
		WHEN ic_hc_selection = 'ic_only'
		THEN 'intake'
		WHEN ic_hc_selection = 'hc_only'
		THEN 'household'
		WHEN ic_hc_selection IS NULL
		THEN 'inferred from placement'
	END
	) AS record_source
INTO #clean_ic_hc_p
FROM #raw_ic_hc_p

-- this completes our child-intake-placement record creation - 
-- now we need to flesh out the created records with the 
-- variables we want to work with

-- we'll start by building all our variables that only require
-- CA data and then we'll expand to variables that require
-- joins to our birth data

-- our first CA data stop is getting intake dates and locations; 
-- since some intakes are inferred from placement, we also
-- infer our date/location from placement record where
-- appropriate

-- intake_date
SELECT
	ihp.*,
	(
	CASE
		WHEN ihp.record_source = 'inferred from placement'
		THEN p_date.CALENDAR_DATE
		ELSE i_date.CALENDAR_DATE
	END
	) AS intake_date
INTO #raw_ci1
FROM #clean_ic_hc_p AS ihp
LEFT JOIN INTAKE_FACT AS i
	ON ihp.id_intake = i.ID_INTAKE_FACT
LEFT JOIN dbo.PLACEMENT_FACT AS p
	ON ihp.id_placement = p.ID_PLACEMENT_FACT
LEFT JOIN dbo.CALENDAR_DIM AS i_date
	ON i.ID_CALENDAR_DIM_ACCESS_RCVD = i_date.ID_CALENDAR_DIM
LEFT JOIN dbo.CALENDAR_DIM AS p_date
	ON p.ID_CALENDAR_DIM_RMVL = p_date.ID_CALENDAR_DIM

-- intake_location
SELECT
	rc.*,
	(
	CASE
		WHEN rc.record_source = 'inferred from placement' 
			AND rp.worker_office IS NOT NULL
			AND rp.worker_office <> 'Failed'
			AND rp.worker_office <> '-'
		THEN rp.worker_office
		WHEN ric.FIRST_WORKER_OFFICE = '' 
			OR ric.FIRST_WORKER_OFFICE = 'Failed'
			OR ric.FIRST_WORKER_OFFICE IS NULL
		THEN 'unknown'
		ELSE ric.FIRST_WORKER_OFFICE
	END
	) AS intake_office
INTO #raw_ci2
FROM #raw_ci1 AS rc
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON rc.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN base.rptIntakes_CA AS ric
	ON inf.ID_ACCESS_REPORT = ric.ID_ACCESS_REPORT
LEFT JOIN base.rptPlacement AS rp
	ON rc.id_placement = rp.id_placement_fact

-- next we get the reporter type for the intake,
-- along with their legal reporting mandate (reporting
-- mandate crosswalk was constructed from this online
-- resource: https://www.dshs.wa.gov/altsa/home-and-community-services/mandatory-reporters)
SELECT
	rc.*,
	(
	CASE
		WHEN iad.TX_RPTR_DSCR IS NULL
		THEN 'unknown'
		ELSE LOWER(iad.TX_RPTR_DSCR)
	END
	) AS intake_reporter_type,
	(
	CASE
		WHEN rmx.tx_rptr_mandate IS NULL
		THEN 'unknown'
		ELSE LOWER(rmx.tx_rptr_mandate)
	END
	) AS intake_reporter_mandate
INTO #raw_ci3
FROM #raw_ci2 AS rc
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON rc.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN dbo.INTAKE_ATTRIBUTE_DIM AS iad
	ON inf.ID_ACCESS_REPORT = iad.ID_ACCESS_REPORT
LEFT JOIN ref.reporter_mandate_xwalk AS rmx
	ON iad.CD_RPTR_DSCR = rmx.cd_rptr_dscr

-- now we want to assess intake screening, allegations,
-- investigation, and findings

-- first we'll pull together another temp table with flags for the 
-- allegation, investigation, and finding elements we want to work with...
SELECT
	af.ID_PRSN_VICTIM AS child_id,
	af.ID_INTAKE_FACT AS intake_id,
	COUNT(*) AS number_allegations,
	SUM(IIF(atd.TX_ALLEGATION = 'Abandonment', 1, 0)) AS abandonment,
	SUM(IIF(atd.TX_ALLEGATION = 'Negligent Treatment or Maltreatment', 1, 0)) AS neglect,
	SUM(IIF(atd.TX_ALLEGATION = 'Physical Abuse', 1, 0)) AS physical_abuse,
	SUM(IIF(atd.TX_ALLEGATION = 'Sexual Abuse', 1, 0)) AS sexual_abuse,
	SUM(IIF(atd.TX_ALLEGATION = 'Sexual Exploitation', 1, 0)) AS sexual_exploitation,
	SUM(IIF(atd.TX_ALLEGATION = 'Death Caused by Neglect/Abuse', 1, 0)) AS intake_death,
	SUM(IIF(atd.TX_ALLEGATION = 'Emotional Abuse', 1, 0)) AS emotional_abuse,
	SUM(IIF(atd.TX_ALLEGATION = 'Exploitation', 1, 0)) AS exploitation,
	SUM(IIF(atd.TX_ALLEGATION = 'Medical Neglect', 1, 0)) AS medical_neglect,
	SUM(IIF(atd.TX_ALLEGATION = 'Mental Injury', 1, 0)) AS mental_injury,
	SUM(IIF(atd.TX_ALLEGATION = 'Prenatal Injury', 1, 0)) AS prenatal_injury,
	SUM(IIF(af.ID_INVESTIGATION_ASSESSMENT_FACT IS NOT NULL, 1, 0)) AS investigations,
	SUM(IIF(fd.CD_FINDING IN(11), 1, 0)) AS duplicate_allegation,
	SUM(IIF(fd.CD_FINDING IN(6), 1, 0)) AS pending,
	SUM(IIF(fd.CD_FINDING IN(1, 2, 3, 4, 9), 1, 0)) AS no_finding,
	SUM(IIF(fd.CD_FINDING IN(10), 1, 0)) AS inconclusive,
	SUM(IIF(fd.CD_FINDING IN(7, 8), 1, 0)) AS unfounded,
	SUM(IIF(fd.CD_FINDING IN(5), 1, 0)) AS founded
INTO #allegations_findings
FROM dbo.ALLEGATION_FACT AS af
LEFT JOIN dbo.ABUSE_TYPE_DIM AS atd
	ON af.ID_ABUSE_TYPE_DIM = atd.ID_ABUSE_TYPE_DIM
LEFT JOIN dbo.FINDINGS_DIM AS fd
	ON af.ID_FINDINGS_DIM = fd.ID_FINDINGS_DIM
GROUP BY
	af.ID_PRSN_VICTIM,
	af.ID_INTAKE_FACT

-- now we join against this table and produce the 
-- less-fined-grained flags we're actually hunting
-- for, also tossing in our screening variable
SELECT
	rc.*,
	(
	CASE
		WHEN record_source = 'inferred from placement'
		THEN 'screen in'
		ELSE LOWER(ric.SCREEN_DCSN)
	END
	) AS screen_decision,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.physical_abuse > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_phys_abuse,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.sexual_abuse > 0
			OR af.sexual_exploitation > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_sex_abuse,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.physical_abuse > 0
			OR af.sexual_abuse > 0
			OR af.sexual_exploitation > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_phys_or_sex_abuse,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.abandonment > 0
			OR af.neglect > 0
			OR af.exploitation > 0
			OR af.medical_neglect > 0
			OR af.prenatal_injury > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_neglect,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.emotional_abuse > 0
			OR af.mental_injury > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_emotional_abuse,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.number_allegations > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS any_allegation,
	(
	CASE
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.investigations > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS any_investigation,
	(
	CASE
		WHEN (af.number_allegations = 0
				OR af.number_allegations IS NULL)
			AND (af.pending > 0
				OR af.no_finding > 0
				OR af.inconclusive > 0
				OR af.unfounded > 0
				OR af.founded > 0)
		THEN 'findings without allegations'
		WHEN af.number_allegations = 0
			AND af.pending = 0
			AND af.no_finding = 0
			AND af.inconclusive = 0
			AND af.unfounded = 0
			AND af.founded = 0
		THEN 'no allegations or findings'
		WHEN af.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN af.investigations = 0
		THEN 'no investigation record'
		WHEN af.number_allegations = af.founded
		THEN 'all founded'
		WHEN af.number_allegations = af.inconclusive
		THEN 'all inconclusive'
		WHEN af.number_allegations = af.no_finding
		THEN 'all no finding'
		WHEN af.number_allegations = af.unfounded
		THEN 'all unfounded'
		WHEN af.number_allegations = af.pending
		THEN 'all pending'
		WHEN af.number_allegations = af.duplicate_allegation
		THEN 'all duplicate allegations'
		WHEN af.founded > 0
		THEN 'founded mix'
		WHEN af.inconclusive > 0
		THEN 'inconclusive mix'
		WHEN af.no_finding > 0
		THEN 'no finding mix'
		WHEN af.unfounded > 0
		THEN 'unfounded mix'
		WHEN af.pending > 0
		THEN 'pending mix'
		WHEN af.number_allegations > 0
			AND af.investigations = 0
		THEN 'not investigated'
		ELSE 'all no finding'
	END
	) AS overall_findings
INTO #raw_ci4
FROM #raw_ci3 AS rc
LEFT JOIN #allegations_findings AS af
	ON rc.id_child = af.child_id
	AND rc.id_intake = af.intake_id
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON rc.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN base.rptIntakes_CA AS ric
	ON inf.ID_ACCESS_REPORT = ric.ID_ACCESS_REPORT

-- the above joins reveal an unusual data practice:
-- there are a number of records without a recorded
-- investigation that have had their allegations flagged
-- as unfounded or pending... it seems better to flag
-- these as 'not investigated'

-- we adjust the cases with no recorded investigation
-- to have findings of 'not investigated'
UPDATE #raw_ci4
SET overall_findings = any_investigation
WHERE any_investigation IN('no allegation record', 'no investigation record')

-- next we build a simplified findings column to correspond with our
-- replication objectives
SELECT
	rc.*,
	(
	CASE
		WHEN overall_findings IN('no allegation record', 'no investigation record')
		THEN overall_findings
		WHEN overall_findings in('all founded', 'founded mix')
		THEN 'substantiated'
		WHEN overall_findings in('all inconclusive', 'inconclusive mix',
			'all pending', 'pending mix', 'all no finding', 'no finding mix')
		THEN 'inconclusive/no finding/pending'
		WHEN overall_findings in('all unfounded', 'unfounded mix')
		THEN 'unfounded'
		WHEN overall_findings in('all duplicate allegations')
		THEN 'duplicate intake'
	END
	) AS simple_findings
INTO #raw_ci5
FROM #raw_ci4 AS rc

-- new we join to get the relationship between intakes and 
-- in-house services (IHS)
SELECT
	rc.*,
	(
	CASE
		WHEN ihs.id_intake_fact IS NOT NULL
		THEN 'yes'
		WHEN ihs.id_intake_fact IS NULL
			AND rc.id_intake IS NOT NULL
		THEN 'no'
		WHEN rc.id_intake IS NULL
		THEN 'unknown'
	END
	) AS ihs_provided,
	ihs.first_ihs_date AS ihs_start_date
INTO #raw_ci6
FROM #raw_ci5 AS rc
LEFT JOIN 
	(
	SELECT DISTINCT 
		id_intake_fact,
		first_ihs_date
	FROM base.tbl_ihs_episodes
	) AS ihs
	ON rc.id_intake = ihs.id_intake_fact

-- now we add a pair of columns for the relationship between
-- intake and out-of-home (OOH) services
SELECT
	rc.*,
	(
	CASE
		WHEN rc.id_placement IS NOT NULL
		THEN 'yes'
		WHEN rc.id_placement IS NULL
		THEN 'no'
	END
	) AS ooh_provided,
	rp.removal_dt AS ooh_start_date
INTO #raw_ci7
FROM #raw_ci6 AS rc
LEFT JOIN base.rptPlacement AS rp
	ON rc.id_placement = rp.id_placement_fact

-- now we add a column that summarizes the intake outcome
SELECT
	rc.*,
	(
	CASE
		WHEN rc.ooh_provided = 'yes'
			AND rc.ihs_provided = 'yes'
			AND rc.ihs_start_date < rc.ooh_start_date
		THEN 'ihs and ooh'
		WHEN rc.ooh_provided = 'yes'
			AND rc.ihs_provided = 'yes'
			AND rc.ihs_start_date >= rc.ooh_start_date
		THEN 'ooh only'
		WHEN rc.ooh_provided = 'no'
			AND rc.ihs_provided = 'yes'
		THEN 'ihs only'
		WHEN rc.ooh_provided = 'yes'
			AND rc.ihs_provided = 'no'
		THEN 'ooh only'
		WHEN rc.ooh_provided = 'yes'
			AND rc.ihs_provided = 'unknown'
		THEN 'ihs unknown - ooh provided'
		WHEN rc.ooh_provided = 'no'
			AND rc.ihs_provided = 'no'
		THEN 'no ihs or ooh'
		WHEN rc.ooh_provided = 'no'
			AND rc.ihs_provided = 'unknown'
		THEN 'ihs unknown - no ooh'
	END
	) AS overall_services
INTO #raw_ci8
FROM #raw_ci7 AS rc

-- and quickly tag on a simplified version of the
-- intake outcome (OOH, IHS, OOH/IHS, none)
SELECT
	rc.*,
	(
	CASE
		WHEN rc.overall_services IN('ihs and ooh', 'ihs only',
			'ooh only', 'no ihs or ooh')
		THEN rc.overall_services
		WHEN rc.overall_services = 'ihs unknown - ooh provided'
		THEN 'ooh only'
		WHEN rc.overall_services = 'ihs unknown - no ooh'
		THEN 'no ihs or ooh'
	END
	) AS simple_services
INTO #raw_ci9
FROM #raw_ci8 AS rc

-- now we start grabbing our child-focused data, starting
-- with the variables we can build from our CA data alone

-- we want birth date, race/ethnicity, and permanency outcomes
-- (for those kids that were placed)

-- first birth date and race/ethncity, with ethnicity being
-- simplified so that it is not hispanic-centric
SELECT
	rc.*,
	pd.DT_BIRTH AS child_CA_birth_date,
	(
	CASE
		WHEN pd.tx_race_census IS NULL
		THEN 'Unknown'
		ELSE pd.tx_race_census
	END
	) AS child_census_race,
	(
	CASE
		WHEN hlc.census_hispanic_latino_origin = 'Hispanic or Latino'
		THEN 'hispanic'
		WHEN hlc.census_hispanic_latino_origin = 'Non-Hispanic, White Alone'
		THEN 'white'
		WHEN hlc.census_hispanic_latino_origin = 'Non-Hispanic, Black or African American Alone'
		THEN 'black'
		ELSE 'other/unknown'
	END
	) AS child_census_ethnicity
INTO #raw_ca1
FROM #raw_ci9 AS rc
LEFT JOIN dbo.PEOPLE_DIM AS pd
	ON rc.id_child = pd.ID_PRSN
	AND pd.IS_CURRENT = 1
LEFT JOIN dbo.ref_lookup_hispanic_latino_census AS hlc
	ON pd.census_Hispanic_Latino_Origin_cd = hlc.census_hispanic_latino_origin_cd

-- now we build a simplified version of race using
-- the closest possible approximation to logic we'll
-- use later when we simplify maternal race information obtained
-- from birth records
SELECT
	rc.*,
	(
	CASE
		WHEN rc.child_census_race IN('White/Caucasian')
		THEN
			CASE
				WHEN rc.child_census_ethnicity 
					IN('other/unknown','white')
				THEN 'white'
				ELSE rc.child_census_ethnicity
			END
		WHEN rc.child_census_race 
			IN('Other Race', 'Unknown')
		THEN
			CASE
				WHEN rc.child_census_ethnicity 
					IN('hispanic', 'black', 'white')
				THEN rc.child_census_ethnicity
				ELSE 'other/unknown'
			END
		WHEN rc.child_census_race
			IN('Multiracial')
		THEN 'multiracial'
		WHEN rc.child_census_race 
			IN('Black/African American')
		THEN 'black'
		WHEN rc.child_census_race
			IN('Asian', 'Native Hawaiian/Other Pacific Islander')
		THEN 'asian/pacific islander'
		WHEN rc.child_census_race IN('American Indian/Alaskan Native')
		THEN 'native american'
		ELSE 'other/unknown'
	END
	) AS child_simple_race_ethnicity
INTO #raw_ca2
FROM #raw_ca1 AS rc

-- for our last CA pull, we grab permanency outcomes
-- associated with any child-intake-placements that have
-- a valid placement link
SELECT
	rc.*,
	(
	CASE
		WHEN alt_discharge_type IS NULL
		THEN 'no placement'
		ELSE LOWER(alt_discharge_type)
	END
	) AS placement_outcome
INTO #raw_ca3
FROM #raw_ca2 AS rc
LEFT JOIN base.rptPlacement rp
	ON rc.id_placement = rp.id_placement_fact
LEFT JOIN dbo.ref_lookup_cd_discharge_type_exits dte
	ON rp.cd_discharge_type = dte.cd_discharge_type

-- now we start grabbing our child-focused data that
-- requires a join to birth records; this will produce
-- a lot of NULLs as many of our children will not have
-- a link to a birth record because either
-- (a) they were born prior to 1999 (start of birth records) or
-- (b) we failed to link the CA record to a birth record

-- our first grab is simply to construct a flag for those
-- children that have a birth record link

-- unlike rodis.child_intake_placement,
-- we do a full outer join so that we retain ALL the birth records 
-- rather than dropping those birth records that don't have 
-- a link to a CA child ID
SELECT
	bf.cd_birth_fact AS id_birth,
	rc.*,
	(
	CASE
		WHEN bf.id_prsn_child IS NOT NULL
		THEN 'yes'
		WHEN rc.id_child IS NULL
		THEN 'no - birth record only'
		WHEN rc.id_child IS NOT NULL
			AND bf.id_prsn_child IS NULL
		THEN 'no - CA record only'
	END
	) AS birth_record_link
INTO #raw_b1
FROM #raw_ca3 AS rc
FULL OUTER JOIN rodis_wh.birth_fact AS bf
	ON rc.id_child = bf.id_prsn_child

-- we also take a moment to update our record_source
-- column - any birth record only child-intakes will
-- be NULL there and we replace that with something
-- more informative
UPDATE #raw_b1
SET record_source = 'birth record only'
WHERE record_source IS NULL

-- next we'll grab all of our birth basics:
-- date, weight, weight category (EPH definition), and sex
-- cutoff for unusually low child weights based on this:
-- http://www.cbsnews.com/pictures/worlds-tiniest-babies-how-are-they-now/2/
SELECT
	rb.*,
	cd.CALENDAR_DATE AS child_birth_date,
	bf.qt_child_weight AS child_birth_weight,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN bf.qt_child_weight = 9999
			OR bf.qt_child_weight < 260
			OR bf.qt_child_weight IS NULL
		THEN 'unknown'
		WHEN bf.qt_child_weight >= 2500
		THEN 'normal'
		WHEN bf.qt_child_weight < 2500
		THEN 'low'
	END
	) AS child_birth_weight_category,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN bad.tx_child_sex = '9 - undefined'
			OR bad.tx_child_sex IS NULL
		THEN 'unknown'
		ELSE LOWER(bad.tx_child_sex) 
	END 
	) AS child_birth_sex
INTO #raw_b2
FROM #raw_b1 as rb
LEFT JOIN rodis_wh.birth_fact AS bf
	ON rb.id_birth = bf.cd_birth_fact
LEFT JOIN dbo.CALENDAR_DIM AS cd
	ON bf.id_calendar_dim_birth_child = cd.ID_CALENDAR_DIM
LEFT JOIN rodis_wh.birth_administration_dim AS bad
	ON bf.id_birth_administration = bad.id_birth_administration

-- now some more detailed birth variables: congenital abnormalities,
-- prenatal care, birth payment, and birth order

-- parts of this join are relatively complex (compared to most
-- of my joins), so I have tucked in a few extra notes inside
-- the SELECT statement
SELECT
	rb.*,
	(
	CASE
		-- there are flags for a bunch of issues observed
		-- at birth, I attempted to identify (via my
		-- limited knowledge and Google) which were 
		-- congenital issues (i.e., more than just a
		-- a circumstantial issues, like a baby getting
		-- dropped)
		-- 0, 9, or NULL count as failure to observe a condition
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN (
				IIF(bccd.fl_anencephaly = 9
					OR bccd.fl_anencephaly = 0
					OR bccd.fl_anencephaly IS NULL,
					0, 1) +
				IIF(bccd.fl_chromosome_anomaly = 9
					OR bccd.fl_chromosome_anomaly = 0
					OR bccd.fl_chromosome_anomaly IS NULL,
					0, 1) +
				IIF(bccd.fl_orofacial_cleft = 9
					OR bccd.fl_orofacial_cleft = 0
					OR bccd.fl_orofacial_cleft IS NULL,
					0, 1) +
				IIF(bccd.fl_diaphragmic_hernia = 9
					OR bccd.fl_diaphragmic_hernia = 0
					OR bccd.fl_diaphragmic_hernia IS NULL,
					0, 1) +
				IIF(bccd.fl_downs_syndrome = 9
					OR bccd.fl_downs_syndrome = 0
					OR bccd.fl_downs_syndrome IS NULL,
					0, 1) +
				IIF(bccd.fl_heart_malformations = 9
					OR bccd.fl_heart_malformations = 0
					OR bccd.fl_heart_malformations IS NULL,
					0, 1) +
				IIF(bccd.fl_omphalocele = 9
					OR bccd.fl_omphalocele = 0
					OR bccd.fl_omphalocele IS NULL,
					0, 1) +
				IIF(bccd.fl_spinabifida = 9
					OR bccd.fl_spinabifida = 0
					OR bccd.fl_spinabifida IS NULL,
					0, 1)
			) > 0
		THEN 'yes'
		ELSE 'none recorded'
	END
	) AS any_congenital_abnormality,
	bad.dt_prenatal_care_start AS prenatal_care_start_month,
	-- NOTE: trimester splits based on info from 
	--	http://americanpregnancy.org/while-pregnant/fetal-development/
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN bad.dt_prenatal_care_start = 99
			OR bad.dt_prenatal_care_start = 999
		THEN 'no prenatal care recorded'
		WHEN bad.dt_prenatal_care_start < 3
		THEN 'first'
		WHEN bad.dt_prenatal_care_start >= 3
			AND bad.dt_prenatal_care_start < 6
		THEN 'second'
		WHEN bad.dt_prenatal_care_start >= 6
			AND bad.dt_prenatal_care_start < 15
		THEN 'third'
	END
	) AS prenatal_care_start_trimester,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN b.PARITY = 0
		THEN 'first born'
		WHEN b.PARITY = 1
		THEN 'second born'
		WHEN b.PARITY > 1
			AND b.PARITY < 30
		THEN 'third born or later'
		ELSE 'birth order not recorded'
	END
	) AS birth_order,
	-- to see the logic for public v. private insurance,
	-- look at rodis.ref_delivpay
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN rd.Code IN(1, 4, 5, 6)
		THEN 'public insurance'
		WHEN rd.Code IN(2, 3)
		THEN 'private insurance'
		WHEN (rd.Code IN(8, 9) OR rd.Code IS NULL)
		THEN 'payment type not recorded'
	END
	) AS birth_payment_category
INTO #raw_b3
FROM #raw_b2 AS rb
LEFT JOIN rodis_wh.birth_fact AS bf
	ON rb.id_birth = bf.cd_birth_fact
LEFT JOIN rodis_wh.birth_administration_dim AS bad
	ON bf.id_birth_administration = bad.id_birth_administration
LEFT JOIN rodis_wh.birth_child_condition_dim AS bccd
	ON bf.birth_administration_id_birth_child_condition = bccd.id_birth_child_condition
LEFT JOIN rodis.berd AS b
	ON rb.id_birth = b.bc_uni
LEFT JOIN rodis.ref_delivpay AS rd
	ON b.delivpay = rd.Code

-- next we grab some parent-focused variables: paternity,
-- maternal age, and our first pass at maternal race
-- NOTE: matnernal age upper limit based on wiki listing of
-- 'oldest births', which suggests that births over 58 are
-- pretty unlikely
-- https://en.wikipedia.org/wiki/Pregnancy_over_age_50#Cases_of_pregnancy_over_50
SELECT
	rb.*,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN (b.dadbirst = 99 OR b.dadbirst IS NULL)
			AND (b.dadrace = 99 OR b.dadrace IS NULL)
			AND (b.dadhisp = 9 OR b.dadhisp IS NULL)
			AND (b.dadocc = 999 OR b.dadocc IS NULL)
		THEN 'missing'
		ELSE 'established'
	END
	) AS paternity_established,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN rb.birth_record_link = 'yes' 
			AND bf.qt_maternal_age IS NULL
		THEN 99
		ELSE bf.qt_maternal_age
	END
	) AS maternal_age,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN bf.qt_maternal_age > 58
			OR bf.qt_maternal_age IS NULL
		THEN 'invalid age or no age recorded'
		WHEN bf.qt_maternal_age <= 19
		THEN '19 or younger'
		WHEN bf.qt_maternal_age > 19
			AND bf.qt_maternal_age < 25
		THEN '20 to 24'
		WHEN bf.qt_maternal_age > 24
			AND bf.qt_maternal_age < 30
		THEN '25 to 29'
		WHEN bf.qt_maternal_age >= 30
		THEN '30 or older'
	END
	) AS maternal_age_category,
	bfd.tx_race_census AS maternal_census_race,
	bfd.tx_ethnicity_census AS maternal_census_ethnicity
INTO #raw_b4
FROM #raw_b3 AS rb
LEFT JOIN rodis_wh.birth_fact AS bf
	ON rb.id_birth = bf.cd_birth_fact
LEFT JOIN rodis.berd AS b
	ON rb.id_birth = b.bc_uni
LEFT JOIN rodis_wh.birth_familial_dim AS bfd
	ON bf.birth_administration_id_birth_familial_maternal = bfd.id_birth_familial

-- now we apply some logic to get an approximation of
-- the maternal race categories used by EPH
SELECT
	rb.*,
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN rb.maternal_census_race 
			IN('White')
		THEN
			CASE
				WHEN rb.maternal_census_ethnicity 
					IN('Central or S. Am', 'Cuban',
					'Mexican', 'Puerto Rican')
				THEN 'hispanic'
				ELSE 'white'
			END
		WHEN rb.maternal_census_race 
			IN('Other Non-White', 'Unknown')
		THEN
			CASE
				WHEN rb.maternal_census_ethnicity 
					IN('Central or S. Am', 'Cuban',
					'Mexican', 'Puerto Rican')
				THEN 'hispanic'
				ELSE 'other/unknown'
			END
		WHEN rb.maternal_census_race 
			IN('Black')
		THEN 'black'
		WHEN rb.maternal_census_race 
			IN('Hispanic')
		THEN 'hispanic'
		WHEN rb.maternal_census_race 
			IN('Asian Indian', 'Chinese', 'Filipino',
			'Guamanian', 'Hawaiian', 'Japanese', 'Korean', 'Other Asian',
			'Samoan', 'Vietnamese')
		THEN 'asian/pacific islander'
		WHEN rb.maternal_census_race 
			IN('Native American')
		THEN 'native american'
		ELSE 'other/unknown'
	END
	) AS maternal_simple_race_ethnicity
INTO #raw_b5
FROM #raw_b4 AS rb

-- and a few more maternal varibles: maternal residence and
-- our first pass at maternal education; both are more complex
-- than one would expect, so notes added into the SELECT
SELECT
	rb.*,
	-- we can get the maternal city of residence directly but our 
	-- preferred geography is county, so we get that where it
	-- is available
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN ld.tx_county = '0 - Undefined'
			OR ld.tx_county = 'Unknown'
		THEN 'unknown'
		ELSE ld.tx_county
	END
	) AS maternal_residence,
	-- education requires using different ref tables for 
	-- different cohorts due to some unusual data design from the
	-- fellow who did our data linkings
	(
	CASE
		WHEN rb.birth_record_link = 'no - CA record only'
		THEN NULL
		WHEN YEAR(cd.CALENDAR_DATE) < 2003
			AND rm.Value IS NOT NULL
		THEN rm.Value
		WHEN YEAR(cd.CALENDAR_DATE) >= 2003
			AND YEAR(cd.CALENDAR_DATE) < 2200
			AND rm03.Value IS NOT NULL
		THEN rm03.Value
		ELSE 'education not recorded or invalid'
	END
	) AS maternal_raw_education
INTO #raw_b6
FROM #raw_b5 AS rb
LEFT JOIN rodis_wh.birth_fact AS bf
	ON rb.id_birth = bf.cd_birth_fact
LEFT JOIN rodis_wh.birth_familial_dim AS bfd
	ON bf.birth_administration_id_birth_familial_maternal = bfd.id_birth_familial
LEFT JOIN rodis_wh.location_dim AS ld
	ON bfd.id_city_current = ld.id_city
LEFT JOIN dbo.CALENDAR_DIM AS cd
	ON bf.id_calendar_dim_birth_child = cd.ID_CALENDAR_DIM
LEFT JOIN rodis_wh.education_dim AS ed
	ON bf.birth_administration_maternal_birth_familial_id_education = ed.id_education
LEFT JOIN rodis.ref_momedu AS rm
	ON ed.cd_education = rm.Code
LEFT JOIN rodis.ref_Momedu03 AS rm03
	ON ed.cd_education = rm03.Code

-- as our last prep step, we create a simple version of maternal
-- education to match the EPH definition
SELECT
	rb.*,
	(
	CASE
		WHEN rb.maternal_raw_education IS NULL
		THEN NULL
		WHEN rb.maternal_raw_education IN('Unknown (09 or 99?)', 'Unknown/Not stated',
			'education not recorded or invalid')
		THEN 'unknown'
		WHEN rb.maternal_raw_education IN('Associate degree', 'Bachelors degree',
			'College graduate', 'Completed 1 year of college', 'Completed 2 years of college',
			'Completed 3 years of college', 'Doctorate or Professional degree', 'Masters degree',
			'Post Graduate Work (< 2003)', 'Some college, no degree')
		THEN 'some college or more'
		ELSE 'high school degree or less'
	END
	) AS maternal_simple_education
INTO #raw_b7
FROM #raw_b6 AS rb

-- next we slap on some flag columns to make
-- sorting/selecting easy and/or to make Gregor
-- happy inside
SELECT
	rb.*,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.intake_reporter_mandate = 'mandatory'
		THEN 1
		ELSE 0
	END
	) AS mandatory_reporter_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.screen_decision = 'screen in'
		THEN 1
		ELSE 0
	END
	) AS screen_in_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.alleged_phys_abuse = 'yes'
		THEN 1
		ELSE 0
	END
	) AS alleged_phys_abuse_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.alleged_sex_abuse = 'yes'
		THEN 1
		ELSE 0
	END
	) AS alleged_sex_abuse_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.alleged_neglect = 'yes'
		THEN 1
		ELSE 0

	END
	) AS alleged_neglect_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.any_allegation = 'yes'
		THEN 1
		ELSE 0
	END
	) AS any_allegation_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.screen_decision <> 'screen in'
		THEN NULL
		WHEN rb.any_investigation = 'yes'
		THEN 1
		ELSE 0
	END
	) AS any_investigation_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.screen_decision <> 'screen in'
			OR rb.any_investigation <> 'yes'
		THEN NULL
		WHEN rb.simple_findings = 'substantiated'
		THEN 1
		ELSE 0
	END
	) AS any_substantiated_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.screen_decision <> 'screen in'
		THEN NULL
		WHEN rb.ihs_provided = 'yes'
		THEN 1
		ELSE 0
	END
	) AS ihs_provided_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.screen_decision <> 'screen in'
		THEN NULL
		WHEN rb.id_placement IS NOT NULL
		THEN 1
		ELSE 0
	END
	) AS ooh_provided_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'no - birth record only'
		THEN NULL
		WHEN rb.id_placement IS NULL
		THEN NULL
		WHEN rb.placement_outcome = 'still in care'
		THEN 1
		ELSE 0
	END
	) AS still_in_care_fl,
	(
	CASE
		WHEN rb.birth_record_link = 'yes'
		THEN 1
		ELSE 0
	END
	) AS birth_record_link_fl
INTO #raw_b8
FROM #raw_b7 AS rb

-- at long last, we define our permanent target table
-- when we do this, we also drop those intakes we believe
-- are duplicates (fortunately very few records are lost:
-- 763)
TRUNCATE TABLE rodis.birth_child_intake_placement

INSERT rodis.birth_child_intake_placement (
	id_birth
	,id_child
	,id_intake
	,id_placement
	,record_source
	,intake_date
	,intake_office
	,intake_reporter_type
	,intake_reporter_mandate
	,screen_decision
	,alleged_phys_abuse
	,alleged_sex_abuse
	,alleged_phys_or_sex_abuse
	,alleged_neglect
	,alleged_emotional_abuse
	,any_allegation
	,any_investigation
	,overall_findings
	,simple_findings
	,ihs_provided
	,ihs_start_date
	,ooh_provided
	,ooh_start_date
	,overall_services
	,simple_services
	,child_CA_birth_date
	,child_census_race
	,child_census_ethnicity
	,child_simple_race_ethnicity
	,placement_outcome
	,birth_record_link
	,child_birth_date
	,child_birth_weight
	,child_birth_weight_category
	,child_birth_sex
	,any_congenital_abnormality
	,prenatal_care_start_month
	,prenatal_care_start_trimester
	,birth_order
	,birth_payment_category
	,paternity_established
	,maternal_age
	,maternal_age_category
	,maternal_census_race
	,maternal_census_ethnicity
	,maternal_simple_race_ethnicity
	,maternal_residence
	,maternal_raw_education
	,maternal_simple_education
	,mandatory_reporter_fl
	,screen_in_fl
	,alleged_phys_abuse_fl
	,alleged_sex_abuse_fl
	,alleged_neglect_fl
	,any_allegation_fl
	,any_investigation_fl
	,any_substantiated_fl
	,ihs_provided_fl
	,ooh_provided_fl
	,still_in_care_fl
	,birth_record_link_fl
	)
-- so that we can use child-intake-placement 
-- as a composite primary key, we'll replace any NULL values in
-- either id_placement (kids with an intake ID not
-- linked to a placement) or id_intake (kids with
-- a placement ID but no intake - our inferred
-- intakes) with 0
-- NOTE: I verified that 0 was not used naturally as a value
--	in either column
SELECT ISNULL(id_birth, 0)
	,ISNULL(id_child, 0)
	,ISNULL(id_intake, 0)
	,ISNULL(id_placement, 0)
	,record_source
	,intake_date
	,intake_office
	,intake_reporter_type
	,intake_reporter_mandate
	,screen_decision
	,alleged_phys_abuse
	,alleged_sex_abuse
	,alleged_phys_or_sex_abuse
	,alleged_neglect
	,alleged_emotional_abuse
	,any_allegation
	,any_investigation
	,overall_findings
	,simple_findings
	,ihs_provided
	,ihs_start_date
	,ooh_provided
	,ooh_start_date
	,overall_services
	,simple_services
	,child_CA_birth_date
	,child_census_race
	,child_census_ethnicity
	,child_simple_race_ethnicity
	,placement_outcome
	,birth_record_link
	,child_birth_date
	,child_birth_weight
	,child_birth_weight_category
	,child_birth_sex
	,any_congenital_abnormality
	,prenatal_care_start_month
	,prenatal_care_start_trimester
	,birth_order
	,birth_payment_category
	,paternity_established
	,maternal_age
	,maternal_age_category
	,maternal_census_race
	,maternal_census_ethnicity
	,maternal_simple_race_ethnicity
	,maternal_residence
	,maternal_raw_education
	,maternal_simple_education
	,mandatory_reporter_fl
	,screen_in_fl
	,alleged_phys_abuse_fl
	,alleged_sex_abuse_fl
	,alleged_neglect_fl
	,any_allegation_fl
	,any_investigation_fl
	,any_substantiated_fl
	,ihs_provided_fl
	,ooh_provided_fl
	,still_in_care_fl
	,birth_record_link_fl
FROM #raw_b8
WHERE simple_findings <> 'duplicate intake'
	OR birth_record_link = 'no - birth record only'

-- and clean up our temp tables
DROP TABLE #clean_ic
DROP TABLE #raw_ic_hc
DROP TABLE #trans_ic_hc
DROP TABLE #clean_ic_hc
DROP TABLE #raw_ic_hc_p
DROP TABLE #clean_ic_hc_p
DROP TABLE #raw_ci1
DROP TABLE #raw_ci2
DROP TABLE #raw_ci3
DROP TABLE #allegations_findings
DROP TABLE #raw_ci4
DROP TABLE #raw_ci5
DROP TABLE #raw_ci6
DROP TABLE #raw_ci7
DROP TABLE #raw_ci8
DROP TABLE #raw_ci9
DROP TABLE #raw_ca1
DROP TABLE #raw_ca2
DROP TABLE #raw_ca3
DROP TABLE #raw_b1
DROP TABLE #raw_b2
DROP TABLE #raw_b3
DROP TABLE #raw_b4
DROP TABLE #raw_b5
DROP TABLE #raw_b6
DROP TABLE #raw_b7
DROP TABLE #raw_b8
