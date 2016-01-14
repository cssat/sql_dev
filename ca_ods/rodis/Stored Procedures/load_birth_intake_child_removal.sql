CREATE PROCEDURE [rodis].[load_birth_child_intake_removal]
AS
/* 
Script to create rodis.birth_child_intake_removal (BCIR).

12-1-2015 
*/

/*
DESCRIPTION

The purpose of this script is to create a table where each row is a 
unique record of a birth-child-intake-removal, coupled with
record variables identified as useful to POC analysis projects
(especially replications of work by Emily Putnam-Hornstein and
other analyses of child risk over time).

The table draws from both WA birth records and WA child welfare
data and constitutes a full outer join between that data. In other
words, every child with a Washington (WA) birth record and/or 
Washington Child Adminstration (CA) record is included.
*/

/*
SCRIPT OVERVIEW

The first major step in creating BCIR is getting all of the unique 
child-intake-removal events available in the CA data.

There are three sources of data for these CA records:
- base.rptIntake_children: This is supposed to be all
	unique child-intake events but often misses children
	who were in a reported home - and thus eventually
	part of the intake - but not part of the initial
	report
- base.tbl_household_children: This captures more than
	base.rptIntake_children but still misses a few that
	base.rptIntake_children has.
- base.rptPlacement: This can be used to determine if
	a child-intake event is associated with a removal.
	It also includes child IDs that are not linked to
	an intake ID in either base.rptIntake_children or
	base.tbl_household_children - we will assume that
	intakes occurred for these children, making this
	also a source of some intake records not included
    in either base.rptIntake_children or 
    base.tbl_household_children.

Later, we will expand this to be all birth-child-intake-removal
events by joining to:
- rodis_wh.birth_fact: This is the fact table for the POC
    WA birth record data warehouse. It should have a record
    for every child born in WA from 1999 to the last
    time the data was updated.

Once these tables are joined, every birth-child-intake-removal
ID combination should be unique - in other words those
columns should be usable as a composite primary key.

We will enforce that primary key logic and then gather
the variables we want associated with each record from
both CA data and birth record data.
*/

-- First stop: select the target cols from rptIntake_children
-- (supported by INTAKE_FACT to get ID_INTAKE_FACT - a
-- foreign key needed to join to tbl_household_children).
-- Note that only reports with a valid (not zero) person ID
-- are included as we will be unable to link invalid person IDs
-- to any of our other target tables.
SELECT 
	rp.VICS_ID_CHILDREN AS id_child_ic,
	infa.ID_INTAKE_FACT AS id_intake_ic,
	rp.ID_ACCESS_REPORT AS id_access_report
INTO #ic
FROM base.rptIntake_children AS rp
LEFT JOIN dbo.INTAKE_FACT AS infa
	ON rp.ID_ACCESS_REPORT = infa.ID_ACCESS_REPORT
WHERE rp.VICS_ID_CHILDREN <> 0

-- Next we do the full join between rptIntake_children and
-- tbl_household_children, selecting just the key ID
-- cols we need to identify child-intake events. This 
-- initially produces some redundant columns/date that will
-- need to be compared and merged.
SELECT 
	ic.id_child_ic AS id_child_ic,
	hc.id_prsn_child AS id_child_hc,
	ic.id_intake_ic AS id_intake_ic,
	hc.id_intake_fact AS id_intake_hc
INTO #raw_ic_hc
FROM base.tbl_household_children AS hc
FULL OUTER JOIN #ic AS ic
	ON hc.id_prsn_child = ic.id_child_ic
		AND hc.id_intake_fact = ic.id_intake_ic

-- Next we create a new column to track the source of
-- the IDs we are going to retain. Did we get the
-- child-intake from rptIntake_children, 
-- tbl_household_children, or both?

-- Note: This is also a good spot to check for ID conflicts 
-- arising during the join, but these should not actually
-- happen (and did not when I inspected the data).
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

-- Now we merge the shared columns using COALESCE - this
-- will retain the first value if the two columns
-- both have values but will otherwise retain
-- whichever value is NOT NULL.
SELECT 
	COALESCE(id_child_ic, id_child_hc) AS id_child,
	COALESCE(id_intake_ic, id_intake_hc) AS id_intake,
	ic_hc_selection
INTO #ic_hc
FROM #trans_ic_hc

-- Now we do the full join to rptPlacement to get
-- our removal linkings for our current child-intake
-- records. This will also add some more child IDs -
-- those children that were linked to a removal but
-- did not have their intake recorded. We assume that
-- an intake must have taken place and so retain these
-- records. This will again produce a redundant ID
-- column that will need comparison and merging.
SELECT
	ih.*,
	p.id_placement_fact AS id_removal,
	p.child AS id_child_p
INTO #raw_ic_hc_p
FROM #ic_hc AS ih
FULL OUTER JOIN base.rptPlacement AS p
	ON ih.id_child = p.child
		AND ih.id_intake = p.id_intake_fact

-- We again COALESCE the redundant ID columns. We also
-- finalize our description of where each child-intake-removal
-- record came from.
SELECT
	COALESCE(id_child, id_child_p) AS id_child,
	id_intake,
	id_removal,
	(
	CASE
		WHEN ic_hc_selection = 'match'
		THEN 'intake and household'
		WHEN ic_hc_selection = 'ic_only'
		THEN 'intake'
		WHEN ic_hc_selection = 'hc_only'
		THEN 'household'
		WHEN ic_hc_selection IS NULL
		THEN 'inferred from removal'
	END
	) AS ca_record_source
INTO #ic_hc_p
FROM #raw_ic_hc_p

-- At this point we have all our known child-intake-removal
-- records - all children who have had an observed interaction
-- with CA are represented.

-- Our last key step in creating BCIR is to add the B(irth).
-- This will give us a table of all children with a WA birth
-- record (in our record time range) and their known 
-- intake-removal interactions (or lack of thereof) with CA.

-- We also add a pair of flags allowing us to quickly
-- assess whether a child has a CA record and/or a
-- a birth record.
SELECT
	bf.cd_birth_fact AS id_birth,
	cip.*,
    (
    CASE
        WHEN cip.ca_record_source IS NOT NULL
        THEN 'yes'
        ELSE 'no'
    END
    ) AS has_ca_record,
    (
    CASE
        WHEN bf.cd_birth_fact IS NOT NULL
        THEN 'yes'
        ELSE 'no'
    END
    ) AS has_birth_record,
    (
    CASE
        WHEN cip.ca_record_source IS NOT NULL 
            AND bf.cd_birth_fact IS NOT NULL
        THEN 'yes'
        ELSE 'no'
            
    END
    ) has_ca_and_birth_record
INTO #raw_BCIR
FROM #ic_hc_p AS cip
FULL OUTER JOIN rodis_wh.birth_fact AS bf
	ON cip.id_child = bf.id_prsn_child

/*
TRANSITION

This completes our birth-child-intake-removal record creation.
Now we need to flesh out the records with the variables we
want to work with.

We will initially focus on building variables describing when
our key events (birth, intake, removal) occurred. Then we will
build variables desribe CA events and child birth context 
in more details.
*/

-- Our first stop will be determining when a a child was born.
-- We grab the birth dates from both CA and birth tables. We also
-- create a single birth date variable merging the CA and birth
-- versions, prioritizing the birth version where it is
-- available (as it is likely to be more accurate and precise).
SELECT
    rb.*,
    pd.DT_BIRTH AS child_birth_date_ca,
    br_date.CALENDAR_DATE AS child_birth_date_br,
    (
    CASE
        WHEN br_date.CALENDAR_DATE IS NOT NULL
        THEN br_date.CALENDAR_DATE
        ELSE pd.DT_BIRTH
    END
    ) child_birth_date
INTO #t1
FROM #raw_BCIR AS rb
LEFT JOIN dbo.PEOPLE_DIM AS pd
    ON rb.id_child = pd.ID_PRSN
    AND pd.IS_CURRENT = 1
LEFT JOIN rodis_wh.birth_fact AS bf
    ON rb.id_birth = bf.cd_birth_fact
LEFT JOIN dbo.CALENDAR_DIM AS br_date
    ON bf.id_calendar_dim_birth_child = br_date.ID_CALENDAR_DIM

-- Next we assess when the current intake occurred and when
-- any associated removal occurred. For children
-- whose intakes were inferred from a removal record, we treat
-- the intakes as occurring on the same date as the removal.
SELECT
    t.*,
    (
	CASE
		WHEN t.ca_record_source = 'inferred from removal'
		THEN p_date.CALENDAR_DATE
		ELSE i_date.CALENDAR_DATE
	END
	) AS intake_date,
    p_date.CALENDAR_DATE AS removal_date
INTO #t2
FROM #t1 AS t
LEFT JOIN INTAKE_FACT AS i
	ON t.id_intake = i.ID_INTAKE_FACT
LEFT JOIN dbo.PLACEMENT_FACT AS p
	ON t.id_removal = p.ID_PLACEMENT_FACT
LEFT JOIN dbo.CALENDAR_DIM AS i_date
	ON i.ID_CALENDAR_DIM_ACCESS_RCVD = i_date.ID_CALENDAR_DIM
LEFT JOIN dbo.CALENDAR_DIM AS p_date
	ON p.ID_CALENDAR_DIM_RMVL = p_date.ID_CALENDAR_DIM

-- For each child, we also want to know some relative information
-- about their intakes and removals: the order of the intake-removal
-- record, the cumulative number of intakes (aka - the intake order),
-- the cumulative number of removals (aka - the removal order),
-- the date of the previous intake, the date of the previous removal,
-- time (in days) since the child was born and time (in days)
-- since the previous intake/removal.

-- First we determine order for each child-intake-removal. This
-- is can be thought of as the order in which any major event occurred
-- for the child (intake? new event. removal? new event.). We also
-- determine order by intake and by removal separately. We ignore
-- records where the field(s) of interest are NULL, setting the 
-- corresponding rank column(s) to NULL (i.e., children without a intake
-- should have all the intake/removal columns as NULL and
-- intakes without a removal should have all the removal columns
-- as NULL).
SELECT
	*,
    (
    CASE
        WHEN has_ca_record = 'no'
        THEN NULL
	    ELSE DENSE_RANK() OVER(PARTITION BY id_child, id_birth ORDER BY intake_date)
    END
    ) AS intake_order,
    (
    CASE
        WHEN has_ca_record = 'no'
            OR id_removal IS NULL
        THEN NULL
        ELSE DENSE_RANK() 
            OVER(PARTITION BY id_child, id_birth 
            -- This a little bit of SQL black magic to avoid having NULL results
            -- counted as the first event when we are sorting removal.
            -- Credit to Stack Overflow post: http://goo.gl/V8WeF1
            ORDER BY 
                CASE 
                    WHEN removal_date IS NULL
                    THEN 1
                    ELSE 0
                END,
            removal_date ASC
            ) 
    END
    ) AS removal_order,
    (
    CASE
        WHEN has_ca_record = 'no'
        THEN NULL
        ELSE DENSE_RANK() OVER(
            PARTITION BY id_child, id_birth 
            ORDER BY intake_date, id_intake, removal_date
        ) 
    END
    ) AS intake_removal_order
INTO #t3
FROM #t2

-- Next we work towards the previous intake and removal dates. Along
-- the way, we'll also get cumulative intakes and cumulative removals.

-- Because children may have a variable number of records for each intake - 
-- and a variable number of intakes without a removal - getting the last 
-- intake date is tricky. The solution we used is modeled on one
-- presented here: https://blog.oraylis.de/2015/01/t-sql-last-non-empty/

-- We'll solve the problem by building our way through a sequence of
-- common table expressions, with each one adding columns closer to
-- what we need.
;WITH temp1 AS
(
SELECT
     t.*,
     -- For our first step, we simply add a flag to indicate whether
     -- the record is associated with a new intake.
     IIF(ISNULL(intake_date, 0) 
        <> ISNULL(lag(intake_date, 1) 
            OVER(PARTITION BY id_birth, id_child 
            -- We order by intake_removal_order to make sure we
            -- correctly break any ties that occur when there are
            -- multiple record with the same intake ID or date.
            ORDER BY intake_order, intake_removal_order), 0), 
     1, 0) AS new_intake,
     -- Or a new removal.
     IIF(ISNULL(removal_date, 0) 
        <> ISNULL(lag(removal_date, 1) 
            OVER(PARTITION BY id_birth, id_child 
            ORDER BY removal_order, intake_removal_order), 0), 
     1, 0) AS new_removal
FROM #t3 AS t
),
temp2 AS
(
SELECT
    t.*,
    -- Then we count how many intakes have occurred and use
    -- this as a way of grouping our intakes.
    SUM(new_intake) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY intake_removal_order
    ) AS cumulative_intakes,
    -- And the same for removals.
    SUM(new_removal) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY intake_removal_order
    ) AS cumulative_removals
FROM temp1 AS t
),
temp3 AS
(
SELECT
    t.*,
    -- Now we assign row numbers relative to our intake
    -- groups. These are equivalent to how many records we
    -- need to lag to get the last intake.
    ROW_NUMBER() OVER(
        PARTITION BY id_birth, id_child, cumulative_intakes
        ORDER BY intake_removal_order
    ) AS last_intake_lag,
    -- And the same for removals. Note, however, that this
    -- isn't quite what we want for removals, because - unlike
    -- the intake events - there can be records with NULL
    -- removal history. We'll fix this in a moment.
    ROW_NUMBER() OVER(
        PARTITION BY id_birth, id_child, cumulative_removals 
        ORDER BY intake_removal_order
    ) AS bad_removal_lag
FROM temp2 AS t
),
temp4 AS
(
SELECT
    t.*,
    -- We add a removal lag column that behaves properly. A record
    -- with no associated removal will lag back as far as the most
    -- recent associated removal (the first removal in the
    -- cumulative removal grouping). A record with an associated
    -- removal will lag back as far as the final removal in
    -- the last cumulative removal (i.e., to get the first
    -- record from the previous grouping).
    (
    CASE
        WHEN new_removal = 1
        THEN LAG(bad_removal_lag, 1) OVER(
            PARTITION BY id_birth, id_child
            ORDER BY intake_removal_order
        )
        WHEN new_removal = 0
        THEN bad_removal_lag - 1
    END
    ) last_removal_lag
FROM temp3 AS t
)
-- Finally we grab the results and use the lag columns to
-- create new columns with the previous intake and
-- removal dates.
SELECT
    t.id_birth,
    t.id_child,
    t.id_intake,
    t.id_removal,
    t.has_ca_record,
    t.has_birth_record,
    t.has_ca_and_birth_record,
    t.ca_record_source,
    t.child_birth_date_ca,
    t.child_birth_date_br,
    t.child_birth_date,
    t.intake_date,
    t.removal_date,
    LAG(intake_date, last_intake_lag) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY intake_removal_order
    ) AS previous_intake_date,
    LAG(removal_date, last_removal_lag) OVER(
        PARTITION BY id_birth, id_child
        ORDER BY intake_removal_order
    ) AS previous_removal_date,
        t.intake_order,
    t.removal_order,
    t.intake_removal_order,
    t.cumulative_intakes,
    t.cumulative_removals
INTO #t4
FROM temp4 AS t

-- Next we add some "first" date columns - first intake and first removal.
SELECT
    t.*,
    FIRST_VALUE(intake_date) OVER(
        PARTITION BY id_birth, id_child
        ORDER BY intake_order
    ) AS first_intake_date,
    FIRST_VALUE(removal_date) OVER(
        PARTITION BY id_birth, id_child
        -- We reuse some of our black magic sauce from above to insure
        -- that NULLs are counted last - we want the first not NULL
        -- removal date.
        ORDER BY
            CASE 
                WHEN removal_order IS NULL
                THEN 1
                ELSE 0
            END,
            removal_order ASC 
    ) AS first_removal_date
INTO #t5
FROM #t4 AS t

-- Next we convert our dates into a few measures of time (in days).
-- Days since birth and days since previous intake are our primary
-- focus.
SELECT
    t.*,
    DATEDIFF(DAY, child_birth_date, first_intake_date) AS days_birth_to_first_intake,
    DATEDIFF(DAY, child_birth_date, first_removal_date) AS days_birth_to_first_removal,
    DATEDIFF(DAY, child_birth_date, intake_date) AS days_birth_to_intake,
    DATEDIFF(DAY, child_birth_date, removal_date) AS days_birth_to_removal,
    DATEDIFF(DAY, first_intake_date, intake_date) AS days_first_intake_to_intake,
    DATEDIFF(DAY, previous_intake_date, intake_date) AS days_previous_intake_to_intake,
    DATEDIFF(DAY, intake_date, removal_date) AS days_intake_to_removal,
    DATEDIFF(DAY, previous_removal_date, removal_date) AS days_previous_removal_to_removal
INTO #t6
FROM #t5 AS t

-- At this point, we have all of the relative comparisons we need - most
-- importantly the dates of previous key events relative to the current
-- event.

-- Next we will expand the table with variables providing birth details
-- for the current child, along with details for the current intake
-- and removal.

-- We focus first on gather relevant details about the child's birth,
-- the child, and the child's family.

-- Birth weight, weight category (EPH definition), and observed child
-- sex. We do a cutoff for unusually low child weights based on this:
-- http://www.cbsnews.com/pictures/worlds-tiniest-babies-how-are-they-now/2/
SELECT
	t.*,
	bf.qt_child_weight AS child_birth_weight_grams,
	(
	CASE
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN bf.qt_child_weight = 9999
            -- Here is where we exclude improbably low birth weights.
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
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN bad.tx_child_sex = '9 - undefined'
			OR bad.tx_child_sex IS NULL
		THEN 'unknown'
		ELSE LOWER(bad.tx_child_sex) 
	END 
	) AS child_birth_sex
INTO #t7
FROM #t6 as t
LEFT JOIN rodis_wh.birth_fact AS bf
	ON t.id_birth = bf.cd_birth_fact
LEFT JOIN rodis_wh.birth_administration_dim AS bad
	ON bf.id_birth_administration = bad.id_birth_administration

-- Now some more detailed birth variables: congenital abnormalities,
-- birth order, prenatal care, and birth payment.

-- Parts of this join are relatively complex (compared to most
-- of my joins), so I have tucked in a few extra notes inside
-- the SELECT statement.
SELECT
	t.*,
	(
	CASE
		-- There are flags for a bunch of issues observed
		-- at birth. I attempted to identify (via my
		-- limited knowledge and Google) which were 
		-- congenital issues (i.e., more than just a
		-- a circumstantial issues, like a baby getting
		-- dropped). 0, 9, or NULL count as failure to observe 
        -- a condition.
		WHEN t.has_birth_record = 'no'
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
	(
	CASE
		WHEN t.has_birth_record = 'no'
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
    bad.dt_prenatal_care_start AS prenatal_care_start_month,
	-- NOTE: trimester splits based on info from 
	--	http://americanpregnancy.org/while-pregnant/fetal-development/
	(
	CASE
		WHEN t.has_birth_record = 'no'
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
	-- to see the logic for public v. private insurance,
	-- look at rodis.ref_delivpay
	(
	CASE
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN rd.Code IN(1, 4, 5, 6)
		THEN 'public insurance'
		WHEN rd.Code IN(2, 3)
		THEN 'private insurance'
		WHEN (rd.Code IN(8, 9) OR rd.Code IS NULL)
		THEN 'payment type not recorded'
	END
	) AS birth_payment_category
INTO #t8
FROM #t7 AS t
LEFT JOIN rodis_wh.birth_fact AS bf
	ON t.id_birth = bf.cd_birth_fact
LEFT JOIN rodis_wh.birth_administration_dim AS bad
	ON bf.id_birth_administration = bad.id_birth_administration
LEFT JOIN rodis_wh.birth_child_condition_dim AS bccd
	ON bf.birth_administration_id_birth_child_condition = bccd.id_birth_child_condition
LEFT JOIN rodis.berd AS b
	ON t.id_birth = b.bc_uni
LEFT JOIN rodis.ref_delivpay AS rd
	ON b.delivpay = rd.Code

-- Next parent-focused birth variables: paternity,
-- maternal age, and our first pass at maternal race.

-- NOTE: Maternal age upper limit based on wiki listing of
-- 'oldest births', which suggests that births over 58 are
-- pretty improbable.
-- https://en.wikipedia.org/wiki/Pregnancy_over_age_50#Cases_of_pregnancy_over_50
SELECT
	t.*,
	(
	CASE
		WHEN t.has_birth_record = 'no'
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
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN t.has_birth_record = 'yes'
			AND bf.qt_maternal_age IS NULL
		THEN 99
		ELSE bf.qt_maternal_age
	END
	) AS maternal_age,
	(
	CASE
		WHEN t.has_birth_record = 'no'
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
INTO #t9
FROM #t8 AS t
LEFT JOIN rodis_wh.birth_fact AS bf
	ON t.id_birth = bf.cd_birth_fact
LEFT JOIN rodis.berd AS b
	ON t.id_birth = b.bc_uni
LEFT JOIN rodis_wh.birth_familial_dim AS bfd
	ON bf.birth_administration_id_birth_familial_maternal = bfd.id_birth_familial

-- Now we apply some logic to get an approximation of
-- the maternal race categories used by EPH.
SELECT
	t.*,
	(
	CASE
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN t.maternal_census_race 
			IN('White')
		THEN
			CASE
				WHEN t.maternal_census_ethnicity 
					IN('Central or S. Am', 'Cuban',
					'Mexican', 'Puerto Rican')
				THEN 'hispanic'
				ELSE 'white'
			END
		WHEN t.maternal_census_race 
			IN('Other Non-White', 'Unknown')
		THEN
			CASE
				WHEN t.maternal_census_ethnicity 
					IN('Central or S. Am', 'Cuban',
					'Mexican', 'Puerto Rican')
				THEN 'hispanic'
				ELSE 'other/unknown'
			END
		WHEN t.maternal_census_race 
			IN('Black')
		THEN 'black'
		WHEN t.maternal_census_race 
			IN('Hispanic')
		THEN 'hispanic'
		WHEN t.maternal_census_race 
			IN('Asian Indian', 'Chinese', 'Filipino',
			'Guamanian', 'Hawaiian', 'Japanese', 'Korean', 'Other Asian',
			'Samoan', 'Vietnamese')
		THEN 'asian/pacific islander'
		WHEN t.maternal_census_race 
			IN('Native American')
		THEN 'native american'
		ELSE 'other/unknown'
	END
	) AS maternal_simple_race_ethnicity
INTO #t10
FROM #t9 AS t

-- We tag on the CA derived child race to contrast against birth-record derived 
-- maternal race. We follow a similar process as to when we built maternal race.
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN pd.tx_race_census IS NULL
		THEN 'Unknown'
		ELSE pd.tx_race_census
	END
	) AS child_census_race,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN hlc.census_hispanic_latino_origin = 'Hispanic or Latino'
		THEN 'hispanic'
		WHEN hlc.census_hispanic_latino_origin = 'Non-Hispanic, White Alone'
		THEN 'white'
		WHEN hlc.census_hispanic_latino_origin = 'Non-Hispanic, Black or African American Alone'
		THEN 'black'
		ELSE 'other/unknown'
	END
	) AS child_census_ethnicity
INTO #t11
FROM #t10 AS t
LEFT JOIN dbo.PEOPLE_DIM AS pd
	ON t.id_child = pd.ID_PRSN
	AND pd.IS_CURRENT = 1
LEFT JOIN dbo.ref_lookup_hispanic_latino_census AS hlc
	ON pd.census_Hispanic_Latino_Origin_cd = hlc.census_hispanic_latino_origin_cd

-- Now we build a simplified version of race/ethnicity using
-- the closest possible approximation to logic we used
-- for maternal race/ethnicity.
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN t.child_census_race IN('White/Caucasian')
		THEN
			CASE
				WHEN t.child_census_ethnicity 
					IN('other/unknown','white')
				THEN 'white'
				ELSE t.child_census_ethnicity
			END
		WHEN t.child_census_race 
			IN('Other Race', 'Unknown')
		THEN
			CASE
				WHEN t.child_census_ethnicity 
					IN('hispanic', 'black', 'white')
				THEN t.child_census_ethnicity
				ELSE 'other/unknown'
			END
		WHEN t.child_census_race
			IN('Multiracial')
		THEN 'multiracial'
		WHEN t.child_census_race 
			IN('Black/African American')
		THEN 'black'
		WHEN t.child_census_race
			IN('Asian', 'Native Hawaiian/Other Pacific Islander')
		THEN 'asian/pacific islander'
		WHEN t.child_census_race IN('American Indian/Alaskan Native')
		THEN 'native american'
		ELSE 'other/unknown'
	END
	) AS child_simple_race_ethnicity
INTO #t12
FROM #t11 AS t

-- A few more maternal varibles: maternal residence and
-- our first pass at maternal education; both are more complex
-- than one might expect.
SELECT
	t.*,
	-- We can get the maternal city of residence directly but our 
	-- preferred geography is county, so we get that where it
	-- is available.
	(
	CASE
		WHEN t.has_birth_record = 'no'
		THEN NULL
		WHEN ld.tx_county = '0 - Undefined'
			OR ld.tx_county = 'Unknown'
		THEN 'unknown'
		ELSE ld.tx_county
	END
	) AS maternal_residence,
	-- Education requires using different ref tables for 
	-- different cohorts due to some unusual data design from the
	-- fellow who did our data linkings.
	(
	CASE
		WHEN t.has_birth_record = 'no'
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
INTO #t13
FROM #t12 AS t
LEFT JOIN rodis_wh.birth_fact AS bf
	ON t.id_birth = bf.cd_birth_fact
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

-- As our last prep step, we create a simple version of maternal
-- education to match the EPH definition.
SELECT
	t.*,
	(
	CASE
		WHEN t.maternal_raw_education IS NULL
		THEN NULL
		WHEN t.maternal_raw_education IN('Unknown (09 or 99?)', 'Unknown/Not stated',
			'education not recorded or invalid')
		THEN 'unknown'
		WHEN t.maternal_raw_education IN('Associate degree', 'Bachelors degree',
			'College graduate', 'Completed 1 year of college', 'Completed 2 years of college',
			'Completed 3 years of college', 'Doctorate or Professional degree', 'Masters degree',
			'Post Graduate Work (< 2003)', 'Some college, no degree')
		THEN 'some college or more'
		ELSE 'high school degree or less'
	END
	) AS maternal_simple_education
INTO #t14
FROM #t13 AS t

-- Next we shift our focus to gathering relevant details about the intake,
-- starting with intake location (aka - the office that handled
-- the intake).
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        -- If the intake was inferred, we use the office that
        -- handled the removal (as long as there is a valid
        -- value for the removal worker office).
		WHEN t.ca_record_source = 'inferred from removal' 
			AND rp.worker_office IS NOT NULL
			AND rp.worker_office <> 'Failed'
			AND rp.worker_office <> '-'
		THEN rp.worker_office
        -- Otherwise, we simply use the intake office location
        -- (as long as there is a valid value for the intake
        -- worker office).
		WHEN ric.FIRST_WORKER_OFFICE = '' 
			OR ric.FIRST_WORKER_OFFICE = 'Failed'
			OR ric.FIRST_WORKER_OFFICE IS NULL
		THEN 'unknown'
		ELSE ric.FIRST_WORKER_OFFICE
	END
	) AS intake_office
INTO #t15
FROM #t14 AS t
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON t.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN base.rptIntakes_CA AS ric
	ON inf.ID_ACCESS_REPORT = ric.ID_ACCESS_REPORT
LEFT JOIN base.rptPlacement AS rp
	ON t.id_removal = rp.id_placement_fact

-- Now the reporter type for the intake,
-- along with their legal reporting mandate (reporting
-- mandate crosswalk was constructed from this online
-- resource: https://www.dshs.wa.gov/altsa/home-and-community-services/mandatory-reporters).
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN iad.TX_RPTR_DSCR IS NULL
		THEN 'unknown'
		ELSE LOWER(iad.TX_RPTR_DSCR)
	END
	) AS intake_reporter_type,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN rmx.tx_rptr_mandate IS NULL
		THEN 'unknown'
		ELSE LOWER(rmx.tx_rptr_mandate)
	END
	) AS intake_reporter_mandate
INTO #t16
FROM #t15 AS t
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON t.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN dbo.INTAKE_ATTRIBUTE_DIM AS iad
	ON inf.ID_ACCESS_REPORT = iad.ID_ACCESS_REPORT
LEFT JOIN ref.reporter_mandate_xwalk AS rmx
	ON iad.CD_RPTR_DSCR = rmx.cd_rptr_dscr

-- Next we want to assess intake screening, allegations,
-- investigation, and findings.

-- First we'll pull together another temp table with flags for the 
-- allegation, investigation, and finding elements we want to work with.
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
INTO #alleg_invest_find
FROM dbo.ALLEGATION_FACT AS af
LEFT JOIN dbo.ABUSE_TYPE_DIM AS atd
	ON af.ID_ABUSE_TYPE_DIM = atd.ID_ABUSE_TYPE_DIM
LEFT JOIN dbo.FINDINGS_DIM AS fd
	ON af.ID_FINDINGS_DIM = fd.ID_FINDINGS_DIM
GROUP BY
	af.ID_PRSN_VICTIM,
	af.ID_INTAKE_FACT

-- Now we join against this table and produce the 
-- less-fined-grained flags we're actually hunting
-- for, also tossing in our screening variable.
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		ELSE LOWER(ric.SCREEN_DCSN)
	END
	) AS screen_decision,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.physical_abuse > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_phys_abuse,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.sexual_abuse > 0
			OR aif.sexual_exploitation > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_sex_abuse,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.physical_abuse > 0
			OR aif.sexual_abuse > 0
			OR aif.sexual_exploitation > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_phys_or_sex_abuse,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.abandonment > 0
			OR aif.neglect > 0
			OR aif.exploitation > 0
			OR aif.medical_neglect > 0
			OR aif.prenatal_injury > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_neglect,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.emotional_abuse > 0
			OR aif.mental_injury > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS alleged_emotional_abuse,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN t.ca_record_source = 'inferred from removal'
            OR aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.number_allegations > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS any_allegation,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.investigations > 0
		THEN 'yes'
		ELSE 'no'
	END
	) AS any_investigation,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        WHEN t.ca_record_source = 'inferred from removal'
        THEN 'no allegations or findings'
		WHEN (aif.number_allegations = 0
				OR aif.number_allegations IS NULL)
			AND (aif.pending > 0
				OR aif.no_finding > 0
				OR aif.inconclusive > 0
				OR aif.unfounded > 0
				OR aif.founded > 0)
		THEN 'findings without allegations'
		WHEN aif.number_allegations = 0
			AND aif.pending = 0
			AND aif.no_finding = 0
			AND aif.inconclusive = 0
			AND aif.unfounded = 0
			AND aif.founded = 0
		THEN 'no allegations or findings'
		WHEN aif.number_allegations IS NULL
		THEN 'no allegation record'
		WHEN aif.investigations = 0
		THEN 'no investigation record'
		WHEN aif.number_allegations = aif.founded
		THEN 'all founded'
		WHEN aif.number_allegations = aif.inconclusive
		THEN 'all inconclusive'
		WHEN aif.number_allegations = aif.no_finding
		THEN 'all no finding'
		WHEN aif.number_allegations = aif.unfounded
		THEN 'all unfounded'
		WHEN aif.number_allegations = aif.pending
		THEN 'all pending'
		WHEN aif.number_allegations = aif.duplicate_allegation
		THEN 'all duplicate allegations'
		WHEN aif.founded > 0
		THEN 'founded mix'
		WHEN aif.inconclusive > 0
		THEN 'inconclusive mix'
		WHEN aif.no_finding > 0
		THEN 'no finding mix'
		WHEN aif.unfounded > 0
		THEN 'unfounded mix'
		WHEN aif.pending > 0
		THEN 'pending mix'
		WHEN aif.number_allegations > 0
			AND aif.investigations = 0
		THEN 'not investigated'
		ELSE 'all no finding'
	END
	) AS overall_findings
INTO #t17
FROM #t16 AS t
LEFT JOIN #alleg_invest_find AS aif
	ON t.id_child = aif.child_id
	AND t.id_intake = aif.intake_id
LEFT JOIN dbo.INTAKE_FACT AS inf
	ON t.id_intake = inf.ID_INTAKE_FACT
LEFT JOIN base.rptIntakes_CA AS ric
	ON inf.ID_ACCESS_REPORT = ric.ID_ACCESS_REPORT

-- The above joins reveal an unusual data practice:
-- there are a number of records without a recorded
-- investigation that have had their allegations flagged
-- as unfounded or pending... it seems better to flag
-- these as 'not investigated'.

-- We adjust the cases with no recorded investigation
-- to have findings of 'not investigated'.
UPDATE #t17
SET overall_findings = any_investigation
WHERE any_investigation IN('no allegation record', 'no investigation record')

-- Next we build a simplified findings column to correspond with our
-- replication objectives.
SELECT
	t.*,
	(
	CASE
        WHEN has_ca_record = 'no'
        THEN NULL
		WHEN overall_findings IN('no allegation record', 'no investigation record', 
            'no allegations or findings')
		THEN overall_findings
		WHEN overall_findings IN('all founded', 'founded mix')
		THEN 'substantiated'
		WHEN overall_findings IN('all inconclusive', 'inconclusive mix',
			'all pending', 'pending mix', 'all no finding', 'no finding mix')
		THEN 'inconclusive/no finding/pending'
		WHEN overall_findings IN('all unfounded', 'unfounded mix')
		THEN 'unfounded'
		WHEN overall_findings IN('all duplicate allegations')
		THEN 'duplicate intake'
	END
	) AS simple_findings
INTO #t18
FROM #t17 AS t

-- Now we join to get the relationship between intakes and 
-- in-house services (IHS).
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN ihs.id_intake_fact IS NOT NULL
		THEN 'yes'
		WHEN ihs.id_intake_fact IS NULL
			AND t.id_intake IS NOT NULL
		THEN 'no'
		WHEN t.id_intake IS NULL
		THEN 'unknown'
	END
	) AS ihs_provided,
	ihs.first_ihs_date AS ihs_start_date
INTO #t19
FROM #t18 AS t
LEFT JOIN 
	(
	SELECT DISTINCT 
		id_intake_fact,
		first_ihs_date
	FROM base.tbl_ihs_episodes
	) AS ihs
	ON t.id_intake = ihs.id_intake_fact

-- Now we add a pair of columns for the relationship between
-- intake and out-of-home (OOH) services.
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN t.id_removal IS NOT NULL
		THEN 'yes'
		WHEN t.id_removal IS NULL
		THEN 'no'
	END
	) AS ooh_provided,
	rp.removal_dt AS ooh_start_date
INTO #t20
FROM #t19 AS t
LEFT JOIN base.rptPlacement AS rp
	ON t.id_removal = rp.id_placement_fact

-- Now we add a column that summarizes the intake outcome.
SELECT
	t.*,
	(
	CASE
		WHEN t.ooh_provided = 'yes'
			AND t.ihs_provided = 'yes'
			AND t.ihs_start_date < t.ooh_start_date
		THEN 'ihs and ooh'
		WHEN t.ooh_provided = 'yes'
			AND t.ihs_provided = 'yes'
			AND t.ihs_start_date >= t.ooh_start_date
		THEN 'ooh only'
		WHEN t.ooh_provided = 'no'
			AND t.ihs_provided = 'yes'
		THEN 'ihs only'
		WHEN t.ooh_provided = 'yes'
			AND t.ihs_provided = 'no'
		THEN 'ooh only'
		WHEN t.ooh_provided = 'yes'
			AND t.ihs_provided = 'unknown'
		THEN 'ihs unknown - ooh provided'
		WHEN t.ooh_provided = 'no'
			AND t.ihs_provided = 'no'
		THEN 'no ihs or ooh'
		WHEN t.ooh_provided = 'no'
			AND t.ihs_provided = 'unknown'
		THEN 'ihs unknown - no ooh'
	END
	) AS overall_services
INTO #t21
FROM #t20 AS t

-- And we quickly tag on a simplified version of the
-- intake outcome (OOH, IHS, OOH/IHS, none)
SELECT
	t.*,
	(
	CASE
		WHEN t.overall_services IN('ihs and ooh', 'ihs only',
			'ooh only', 'no ihs or ooh')
		THEN t.overall_services
		WHEN t.overall_services = 'ihs unknown - ooh provided'
		THEN 'ooh only'
		WHEN t.overall_services = 'ihs unknown - no ooh'
		THEN 'no ihs or ooh'
	END
	) AS simple_services
INTO #t22
FROM #t21 AS t

-- We grab permanency outcomes
-- associated with any child-intake-removals that have
-- a valid removal link
SELECT
	t.*,
	(
	CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
		WHEN dte.alt_discharge_type IS NULL
		THEN 'no removal'
		ELSE LOWER(alt_discharge_type)
	END
	) AS removal_outcome
INTO #t23
FROM #t22 AS t
LEFT JOIN base.rptPlacement rp
	ON t.id_removal = rp.id_placement_fact
LEFT JOIN dbo.ref_lookup_cd_discharge_type_exits dte
	ON rp.cd_discharge_type = dte.cd_discharge_type

-- At this point we're almost done. However, we need to apply some
-- crucial assumptions to our data logic. Specifically, we will assume
-- that any record that was inferred from a removal was screened
-- in, investigated, and had inconclusive findings. We will assume the
-- same for any intakes that received IHS but had a contradictory
-- screen decision, a contradictory investigation decisions, and/or 
-- were missing findings records.
UPDATE #t23
SET screen_decision = 'screen in'
WHERE 
    ca_record_source = 'inferred from removal'
    OR any_investigation = 'yes'
    OR (simple_findings NOT IN('no allegation record', 'no investigation record',
        'no allegations or findings') AND simple_findings IS NOT NULL)
    OR ihs_provided = 'yes'
    OR ooh_provided = 'yes'

UPDATE #t23
SET any_investigation = 'yes'
WHERE 
    ca_record_source = 'inferred from removal'
    OR (simple_findings NOT IN('no allegation record', 'no investigation record',
        'no allegations or findings') AND simple_findings IS NOT NULL)
    OR ihs_provided = 'yes'
    OR ooh_provided = 'yes'

UPDATE #t23
SET simple_findings = 'inconclusive/no finding/pending'
WHERE 
    ihs_provided = 'yes'
    OR ooh_provided = 'yes'
    AND simple_findings IN('no allegation record', 'no investigation record', 
            'no allegations or findings')

-- As our final table building step, we slap on some flag columns to make
-- sorting/selecting easy and/or to make Gregor happy inside.
SELECT
	t.*,
    (
    CASE
        WHEN t.has_ca_record = 'no'
		THEN NULL
        WHEN t.child_birth_date > t.intake_date
        THEN 1
        ELSE 0
    END
    ) AS intake_before_birth_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.intake_reporter_mandate = 'mandatory'
		THEN 1
		ELSE 0
	END
	) AS mandatory_reporter_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.screen_decision = 'screen in'
		THEN 1
		ELSE 0
	END
	) AS screen_in_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.alleged_phys_abuse = 'yes'
		THEN 1
		ELSE 0
	END
	) AS alleged_phys_abuse_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.alleged_sex_abuse = 'yes'
		THEN 1
		ELSE 0
	END
	) AS alleged_sex_abuse_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.alleged_neglect = 'yes'
		THEN 1
		ELSE 0

	END
	) AS alleged_neglect_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.any_allegation = 'yes'
		THEN 1
		ELSE 0
	END
	) AS any_allegation_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.screen_decision <> 'screen in'
		THEN NULL
		WHEN t.any_investigation = 'yes'
		THEN 1
		ELSE 0
	END
	) AS any_investigation_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.screen_decision <> 'screen in'
			OR t.any_investigation <> 'yes'
		THEN NULL
		WHEN t.simple_findings = 'substantiated'
		THEN 1
		ELSE 0
	END
	) AS any_substantiated_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.screen_decision <> 'screen in'
            OR t.any_investigation <> 'yes'
		THEN NULL
		WHEN t.ihs_provided = 'yes'
		THEN 1
		ELSE 0
	END
	) AS ihs_provided_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.screen_decision <> 'screen in'
            OR t.any_investigation <> 'yes'
		THEN NULL
		WHEN t.id_removal IS NOT NULL
		THEN 1
		ELSE 0
	END
	) AS ooh_provided_fl,
	(
	CASE
		WHEN t.has_ca_record = 'no'
		THEN NULL
		WHEN t.id_removal IS NULL
		THEN NULL
		WHEN t.removal_outcome = 'still in care'
		THEN 1
		ELSE 0
	END
	) AS still_in_care_fl,
	(
	CASE
		WHEN t.has_ca_and_birth_record = 'yes'
		THEN 1
		ELSE 0
	END
	) AS has_ca_and_birth_record_fl
INTO #t24
FROM #t23 AS t

/*
TRANSITION

This completes our table building. However, we have a tricky filtering issue
that would have been irritating to resolve at earlier stages of our table
building. Specifically, we have some child-intakes that occur within a week
of each other.

We will only consider an intake unique if there are no intakes within a 
week of it, it is associated with a service, or - if no services - it
is the earliest conflicting intake.
*/

-- As our first step, we will build a supporting table which will identify
-- which records should be dropped. We'll again work through a series of
-- common table expressions to build the supporting table.
;WITH temp1 AS
(
SELECT
    t.*,
    (
    CASE
        WHEN t.has_ca_record = 'no'
            OR t.intake_order = 1
        THEN NULL
        ELSE LAG(t.id_intake, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS previous_id_intake,
    (
    CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        ELSE LEAD(t.id_intake, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS next_id_intake,
    (
    CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        ELSE LEAD(t.days_previous_intake_to_intake, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS days_intake_to_next_intake,
    (
    CASE
        WHEN t.has_ca_record = 'no'
            OR t.intake_order = 1
        THEN NULL
        ELSE LAG(t.ihs_provided, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS previous_ihs_provided,
    (
    CASE
        WHEN t.has_ca_record = 'no'
            OR t.intake_order = 1
        THEN NULL
        ELSE LAG(t.ooh_provided, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS previous_ooh_provided,
    (
    CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        ELSE LEAD(t.ihs_provided, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS next_ihs_provided,
    (
    CASE
        WHEN t.has_ca_record = 'no'
        THEN NULL
        ELSE LEAD(t.ooh_provided, 1) OVER(
            PARTITION BY t.id_birth, t.id_child
            ORDER BY t.intake_order
        )
    END
    ) AS next_ooh_provided
FROM #t24 AS t
),
temp2 AS
(
SELECT
    *,
    (
    CASE
        WHEN days_previous_intake_to_intake <= 7
            AND (previous_ihs_provided = 'yes' OR previous_ooh_provided = 'yes')
            AND (ihs_provided IN('no', 'unknown') AND ooh_provided = 'no')
        THEN 1
        WHEN days_previous_intake_to_intake <= 7
            AND (previous_ihs_provided IN('no', 'unknown') AND previous_ooh_provided = 'no')
            AND (ihs_provided IN('no', 'unknown') AND ooh_provided = 'no')
        THEN 1
        ELSE 0
    END
    ) AS drop_for_previous,
    (
    CASE
        WHEN days_intake_to_next_intake <= 7
            AND (next_ihs_provided = 'yes' OR next_ooh_provided = 'yes')
            AND (ihs_provided IN('no', 'unknown') AND ooh_provided = 'no')
        THEN 1
        ELSE 0
    END
    ) AS drop_for_next
FROM temp1
)
SELECT *
INTO #drops
FROM temp2

-- We drop those intake records which fall within a week of another record
-- without any evidence they are unique intakes (i.e., without evidence of
-- a service associated with the intake or of being the first of several
-- duplicate intakes).

-- We also drop any remaining intakes which are explicitly flagged in their
-- findings as duplicates.
SELECT
    *
INTO #t25
FROM #drops
WHERE (drop_for_next <> 1 AND drop_for_previous <> 1)
    AND (simple_findings <> 'duplicate intake' OR has_birth_record = 'yes')

-- This action makes our current intake, removal, and intake_removal order
-- variables - and all the variables that depend on them - inconsistent.
-- We rebuild them.

-- First the order variables...
SELECT
	*,
    (
    CASE
        WHEN has_ca_record = 'no'
        THEN NULL
	    ELSE DENSE_RANK() OVER(PARTITION BY id_child, id_birth ORDER BY intake_date)
    END
    ) AS new_intake_order,
    (
    CASE
        WHEN has_ca_record = 'no'
            OR id_removal IS NULL
        THEN NULL
        ELSE DENSE_RANK() 
            OVER(PARTITION BY id_child, id_birth 
            -- This a little bit of SQL black magic to avoid having NULL results
            -- counted as the first event when we are sorting removal.
            -- Credit to Stack Overflow post: http://goo.gl/V8WeF1
            ORDER BY 
                CASE 
                    WHEN removal_date IS NULL
                    THEN 1
                    ELSE 0
                END,
            removal_date ASC
            ) 
    END
    ) AS new_removal_order,
    (
    CASE
        WHEN has_ca_record = 'no'
        THEN NULL
        ELSE DENSE_RANK() OVER(
            PARTITION BY id_child, id_birth 
            ORDER BY intake_date, id_intake, removal_date
        ) 
    END
    ) AS new_intake_removal_order
INTO #t26
FROM #t25

-- Then the date and cumulative variables...
;WITH temp1 AS
(
SELECT
     t.*,
     -- For our first step, we simply add a flag to indicate whether
     -- the record is associated with a new intake.
     IIF(ISNULL(intake_date, 0) 
        <> ISNULL(lag(intake_date, 1) 
            OVER(PARTITION BY id_birth, id_child 
            -- We order by intake_removal_order to make sure we
            -- correctly break any ties that occur when there are
            -- multiple record with the same intake ID or date.
            ORDER BY new_intake_order, new_intake_removal_order), 0), 
     1, 0) AS new_intake,
     -- Or a new removal.
     IIF(ISNULL(removal_date, 0) 
        <> ISNULL(lag(removal_date, 1) 
            OVER(PARTITION BY id_birth, id_child 
            ORDER BY new_removal_order, new_intake_removal_order), 0), 
     1, 0) AS new_removal
FROM #t26 AS t
),
temp2 AS
(
SELECT
    t.*,
    -- Then we count how many intakes have occurred and use
    -- this as a way of grouping our intakes.
    SUM(new_intake) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY new_intake_removal_order
    ) AS new_cumulative_intakes,
    -- And the same for removals.
    SUM(new_removal) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY new_intake_removal_order
    ) AS new_cumulative_removals
FROM temp1 AS t
),
temp3 AS
(
SELECT
    t.*,
    -- Now we assign row numbers relative to our intake
    -- groups. These are equivalent to how many records we
    -- need to lag to get the last intake.
    ROW_NUMBER() OVER(
        PARTITION BY id_birth, id_child, new_cumulative_intakes
        ORDER BY new_intake_removal_order
    ) AS last_intake_lag,
    -- And the same for removals. Note, however, that this
    -- isn't quite what we want for removals, because - unlike
    -- the intake events - there can be records with NULL
    -- removal history. We'll fix this in a moment.
    ROW_NUMBER() OVER(
        PARTITION BY id_birth, id_child, new_cumulative_removals 
        ORDER BY new_intake_removal_order
    ) AS bad_removal_lag
FROM temp2 AS t
),
temp4 AS
(
SELECT
    t.*,
    -- We add a removal lag column that behaves properly. A record
    -- with no associated removal will lag back as far as the most
    -- recent associated removal (the first removal in the
    -- cumulative removal grouping). A record with an associated
    -- removal will lag back as far as the final removal in
    -- the last cumulative removal (i.e., to get the first
    -- record from the previous grouping).
    (
    CASE
        WHEN new_removal = 1
        THEN LAG(bad_removal_lag, 1) OVER(
            PARTITION BY id_birth, id_child
            ORDER BY new_intake_removal_order
        )
        WHEN new_removal = 0
        THEN bad_removal_lag - 1
    END
    ) last_removal_lag
FROM temp3 AS t
)
-- Finally we grab the results and use the lag columns to
-- create new columns with the previous intake and
-- removal dates.
SELECT
    t.*,
    LAG(intake_date, last_intake_lag) OVER(
        PARTITION BY id_birth, id_child 
        ORDER BY new_intake_removal_order
    ) AS new_previous_intake_date,
    LAG(removal_date, last_removal_lag) OVER(
        PARTITION BY id_birth, id_child
        ORDER BY new_intake_removal_order
    ) AS new_previous_removal_date
INTO #t27
FROM temp4 AS t

-- Now the new "first" date columns - first intake and first removal.
SELECT
    t.*,
    FIRST_VALUE(intake_date) OVER(
        PARTITION BY id_birth, id_child
        ORDER BY new_intake_order
    ) AS new_first_intake_date,
    FIRST_VALUE(removal_date) OVER(
        PARTITION BY id_birth, id_child
        -- We reuse some of our black magic sauce from above to insure
        -- that NULLs are counted last - we want the first not NULL
        -- removal date.
        ORDER BY
            CASE 
                WHEN new_removal_order IS NULL
                THEN 1
                ELSE 0
            END,
            new_removal_order ASC 
    ) AS new_first_removal_date
INTO #t28
FROM #t27 AS t

-- Finally we convert our dates into a few measures of time (in days).
-- Days since birth and days since previous intake are our primary
-- focus.
SELECT
    t.*,
    DATEDIFF(DAY, child_birth_date, new_first_intake_date) AS new_days_birth_to_first_intake,
    DATEDIFF(DAY, child_birth_date, new_first_removal_date) AS new_days_birth_to_first_removal,
    DATEDIFF(DAY, child_birth_date, intake_date) AS new_days_birth_to_intake,
    DATEDIFF(DAY, child_birth_date, removal_date) AS new_days_birth_to_removal,
    DATEDIFF(DAY, new_first_intake_date, intake_date) AS new_days_first_intake_to_intake,
    DATEDIFF(DAY, new_previous_intake_date, intake_date) AS new_days_previous_intake_to_intake,
    DATEDIFF(DAY, intake_date, removal_date) AS new_days_intake_to_removal,
    DATEDIFF(DAY, new_previous_removal_date, removal_date) AS new_days_previous_removal_to_removal
INTO #t29
FROM #t28 AS t

-- At last, we perform our final variable selection and ordering.
SELECT
    id_birth,
    id_child,
    id_intake,
    id_removal,
    has_ca_record,
    ca_record_source,
    has_birth_record,
    has_ca_and_birth_record,
    child_birth_date_ca,
    child_birth_date_br,
    child_birth_date,
    intake_date,
    removal_date,
    new_intake_order AS intake_order,
    new_removal_order AS removal_order,
    new_intake_removal_order AS intake_removal_order,
    new_cumulative_intakes AS cumulative_intakes,
    new_cumulative_removals AS cumulative_removals,
    new_first_intake_date AS first_intake_date,
    new_first_removal_date AS first_removal_date,
    new_previous_intake_date AS previous_intake_date,
    new_previous_removal_date AS previous_removal_date,
    new_days_birth_to_first_intake AS days_birth_to_first_intake,
    new_days_birth_to_first_removal AS days_birth_to_first_removal,
    new_days_birth_to_intake AS days_birth_to_intake,
    new_days_birth_to_removal AS days_birth_to_removal,
    new_days_first_intake_to_intake AS days_first_intake_to_intake,
    new_days_previous_intake_to_intake AS days_previous_intake_to_intake,
    new_days_intake_to_removal AS days_intake_to_removal,
    new_days_previous_removal_to_removal AS days_previous_removal_to_removal,
    prenatal_care_start_month,
    prenatal_care_start_trimester,
    birth_payment_category,
    birth_order,
    child_birth_weight_grams,
    child_birth_weight_category,
    child_birth_sex,
    child_census_race,
    child_census_ethnicity,
    child_simple_race_ethnicity,
    any_congenital_abnormality,    
    maternal_age,
    maternal_age_category,
    maternal_census_race,
    maternal_census_ethnicity,
    maternal_simple_race_ethnicity,
    maternal_residence,
    maternal_raw_education,
    maternal_simple_education,
    paternity_established,
    intake_office,
    intake_reporter_type,
    intake_reporter_mandate,
    screen_decision,
    alleged_phys_abuse,
    alleged_sex_abuse,
    alleged_phys_or_sex_abuse,
    alleged_neglect,
    alleged_emotional_abuse,
    any_allegation,
    any_investigation,
    overall_findings,
    simple_findings,
    ihs_provided,
    ihs_start_date,
    ooh_provided,
    ooh_start_date,
    overall_services,
    simple_services,
    removal_outcome,
    intake_before_birth_fl,
    mandatory_reporter_fl,
    screen_in_fl,
    alleged_phys_abuse_fl,
    alleged_sex_abuse_fl,
    alleged_neglect_fl,
    any_allegation_fl,
    any_investigation_fl,
    any_substantiated_fl,
    ihs_provided_fl,
    ooh_provided_fl,
    still_in_care_fl,
    has_ca_and_birth_record_fl
INTO #t30
FROM #t29 AS t

-- At long last, we define our permanent target table.
TRUNCATE TABLE rodis.birth_child_intake_removal

INSERT rodis.birth_child_intake_removal (
	id_birth
	,id_child
	,id_intake
	,id_removal
	,has_ca_record
	,ca_record_source
	,has_birth_record
	,has_ca_and_birth_record
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,intake_date
	,removal_date
	,intake_order
	,removal_order
	,intake_removal_order
	,cumulative_intakes
	,cumulative_removals
	,first_intake_date
	,first_removal_date
	,previous_intake_date
	,previous_removal_date
	,days_birth_to_first_intake
	,days_birth_to_first_removal
	,days_birth_to_intake
	,days_birth_to_removal
	,days_first_intake_to_intake
	,days_previous_intake_to_intake
	,days_intake_to_removal
	,days_previous_removal_to_removal
	,prenatal_care_start_month
	,prenatal_care_start_trimester
	,birth_payment_category
	,birth_order
	,child_birth_weight_grams
	,child_birth_weight_category
	,child_birth_sex
	,child_census_race
	,child_census_ethnicity
	,child_simple_race_ethnicity
	,any_congenital_abnormality
	,maternal_age
	,maternal_age_category
	,maternal_census_race
	,maternal_census_ethnicity
	,maternal_simple_race_ethnicity
	,maternal_residence
	,maternal_raw_education
	,maternal_simple_education
	,paternity_established
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
	,removal_outcome
	,intake_before_birth_fl
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
	,has_ca_and_birth_record_fl
	)
-- So that we can use child-intake-removal
-- as a composite primary key, we'll replace any NULL values in
-- either id_removal (kids with an intake ID not
-- linked to a removal) or id_intake (kids with
-- a removal ID but no intake - our inferred
-- intakes) with 0.

-- NOTE: I verified that 0 was not used naturally as a value
-- in either column
SELECT ISNULL(id_birth, 0)
	,ISNULL(id_child, 0)
	,ISNULL(id_intake, 0)
	,ISNULL(id_removal, 0)
	,has_ca_record
	,ca_record_source
	,has_birth_record
	,has_ca_and_birth_record
	,child_birth_date_ca
	,child_birth_date_br
	,child_birth_date
	,intake_date
	,removal_date
	,intake_order
	,removal_order
	,intake_removal_order
	,cumulative_intakes
	,cumulative_removals
	,first_intake_date
	,first_removal_date
	,previous_intake_date
	,previous_removal_date
	,days_birth_to_first_intake
	,days_birth_to_first_removal
	,days_birth_to_intake
	,days_birth_to_removal
	,days_first_intake_to_intake
	,days_previous_intake_to_intake
	,days_intake_to_removal
	,days_previous_removal_to_removal
	,prenatal_care_start_month
	,prenatal_care_start_trimester
	,birth_payment_category
	,birth_order
	,child_birth_weight_grams
	,child_birth_weight_category
	,child_birth_sex
	,child_census_race
	,child_census_ethnicity
	,child_simple_race_ethnicity
	,any_congenital_abnormality
	,maternal_age
	,maternal_age_category
	,maternal_census_race
	,maternal_census_ethnicity
	,maternal_simple_race_ethnicity
	,maternal_residence
	,maternal_raw_education
	,maternal_simple_education
	,paternity_established
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
	,removal_outcome
	,intake_before_birth_fl
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
	,has_ca_and_birth_record_fl
FROM #t30

DROP TABLE #ic
DROP TABLE #raw_ic_hc
DROP TABLE #trans_ic_hc
DROP TABLE #ic_hc
DROP TABLE #raw_ic_hc_p
DROP TABLE #ic_hc_p
DROP TABLE #raw_BCIR
DROP TABLE #t1
DROP TABLE #t2
DROP TABLE #t3
DROP TABLE #t4
DROP TABLE #t5
DROP TABLE #t6
DROP TABLE #t7
DROP TABLE #t8
DROP TABLE #t9
DROP TABLE #t10
DROP TABLE #t11
DROP TABLE #t12
DROP TABLE #t13
DROP TABLE #t14
DROP TABLE #t15
DROP TABLE #t16
DROP TABLE #alleg_invest_find
DROP TABLE #t17
DROP TABLE #t18
DROP TABLE #t19
DROP TABLE #t20
DROP TABLE #t21
DROP TABLE #t22
DROP TABLE #t23
DROP TABLE #t24
DROP TABLE #drops
DROP TABLE #t25
DROP TABLE #t26
DROP TABLE #t27
DROP TABLE #t28
DROP TABLE #t29
DROP TABLE #t30
