CREATE PROCEDURE [prtl].[build_cache_ia_safety_aggr] (
	@age_grouping_cd VARCHAR(30)
	,@race_cd VARCHAR(30)
	,@cd_county VARCHAR(1000)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	)
AS
/*
DECLARE @age_grouping_cd VARCHAR(30) = '0,1,2,3,4'
	,@race_cd VARCHAR(30) = '0,1'
	,@cd_county VARCHAR(1000) = '0'
	,@cd_reporter_type VARCHAR(100) ='0'
	,@cd_access_type VARCHAR(30) = '0'
	,@cd_allegation VARCHAR(30) = '0'
	,@cd_finding VARCHAR(30) = '0'
--*/
SET NOCOUNT ON

DECLARE @qry_id BIGINT
	,@min_date DATETIME
	,@max_date DATETIME
	,@max_month_start DATETIME
	,@min_month_start DATETIME
	,@x1 FLOAT
	,@x2 FLOAT;

SET @x1 = RAND();
SET @x2 = RAND();

DECLARE @tblqryid TABLE (qry_id INT);

SELECT @min_date = min_date_any
	,@max_date = max_date_any
	,@min_month_start = min_date_any
	,@max_month_start = max_date_any
FROM ref.lookup_max_date
WHERE [procedure_name] = 'sp_ia_safety';

SET @qry_id = (
		SELECT TOP 1 qry_id
		FROM prtl.cache_ia_safety_params
		WHERE age_grouping_cd = LEFT(@age_grouping_cd, 20)
			AND cd_race_census = LEFT(@race_cd, 30)
			AND cd_county = LEFT(@cd_county, 250)
			AND cd_reporter_type = LEFT(@cd_reporter_type, 100)
			AND filter_access_type = LEFT(@cd_access_type, 30)
			AND filter_allegation = LEFT(@cd_allegation, 30)
			AND filter_finding = LEFT(@cd_finding, 30)
		ORDER BY qry_ID DESC
		);

IF @qry_Id IS NULL
BEGIN
	INSERT INTO prtl.cache_ia_safety_params (
		age_grouping_cd
		,cd_race_census
		,cd_county
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		)
	OUTPUT inserted.qry_id
	INTO @tblqryid
	SELECT @age_grouping_cd
		,@race_cd
		,@cd_county
		,@cd_reporter_type
		,@cd_access_type
		,@cd_allegation
		,@cd_finding
		,@min_month_start
		,@max_month_start
		,1
		,GETDATE();

	SELECT @qry_id = qry_id
	FROM @tblqryid;
END
ELSE
BEGIN
	UPDATE prtl.cache_ia_safety_params
	SET cnt_qry = cnt_qry + 1
	WHERE qry_id = @qry_id;
END

DECLARE @age TABLE (age_grouping_cd INT)
DECLARE @ethnicity TABLE (cd_race INT)
DECLARE @county TABLE (cd_county INT)
DECLARE @reporter_type TABLE (cd_reporter_type INT)
DECLARE @access_type TABLE (cd_access_type INT)
DECLARE @allegation TABLE (cd_allegation INT)
DECLARE @finding TABLE (cd_finding INT)

INSERT @age (age_grouping_cd)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@age_grouping_cd, 0)

INSERT @ethnicity (cd_race)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@race_cd, 0)

INSERT @county (cd_county)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_county, 0)

INSERT @reporter_type (cd_reporter_type)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_reporter_type, 0)

INSERT @access_type (cd_access_type)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_access_type, 0)

INSERT @allegation (cd_allegation)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_allegation, 0)

INSERT @finding (cd_finding)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_finding, 0)

IF OBJECT_ID('tempDB..#not_in_cache_sets') IS NOT NULL
	DROP TABLE #not_in_cache_sets

SELECT ia.ia_param_key
	,demog.demog_param_key
	,geog.geog_param_key
INTO #not_in_cache_sets
FROM (
	SELECT ia.ia_param_key
	FROM prtl.param_sets_ia ia
	INNER JOIN @reporter_type rt ON rt.cd_reporter_type = ia.cd_reporter_type
	INNER JOIN @access_type at ON at.cd_access_type = ia.cd_access_type
	INNER JOIN @allegation al ON al.cd_allegation = ia.cd_allegation
	INNER JOIN @finding f ON f.cd_finding = ia.cd_finding
	WHERE NOT EXISTS (
			SELECT *
			FROM prtl.cache_ia_safety_aggr m
			WHERE ia.ia_param_key = m.ia_param_key
			)
	) ia
CROSS JOIN (
	SELECT demog.demog_param_key
	FROM prtl.param_sets_demog demog
	INNER JOIN @age a ON a.age_grouping_cd = demog.age_sib_group_cd
	INNER JOIN @ethnicity e ON e.cd_race = demog.cd_race_census
	WHERE demog.age_grouping_cd = 0
		AND demog.age_census_cd = 0
		AND demog.age_dev_cd = 0
		AND demog.pk_gender = 0
		AND NOT EXISTS (
			SELECT *
			FROM prtl.cache_ia_safety_aggr m
			WHERE demog.demog_param_key = m.demog_param_key
			)
	) demog
CROSS JOIN (
	SELECT geog.geog_param_key
	FROM prtl.param_sets_geog geog
	INNER JOIN @county c ON c.cd_county = geog.cd_county
	WHERE geog.cd_region_three = 0
		AND geog.cd_region_six = 0
		AND NOT EXISTS (
			SELECT *
			FROM prtl.cache_ia_safety_aggr m
			WHERE geog.geog_param_key = m.geog_param_key
			)
	) geog;

CREATE UNIQUE CLUSTERED INDEX [idx_not_in_cache_sets] ON #not_in_cache_sets (
	ia_param_key
	,demog_param_key
	,geog_param_key
	);;

-- see if results are in cache as a subset of previously run query
IF (
		SELECT COUNT(*)
		FROM #not_in_cache_sets
		) != 0
BEGIN
	IF OBJECT_ID('tempDB..#families') IS NOT NULL
		DROP TABLE #families

	SELECT ia.cohort_begin_date
		,ia.qry_type
		,cache.ia_param_key
		,cache.demog_param_key
		,cache.geog_param_key
		,SUM(cnt_case) [total_families]
	INTO #families
	FROM #not_in_cache_sets cache
	INNER JOIN prtl.param_match_ia mia ON mia.ia_param_key = cache.ia_param_key
	INNER JOIN prtl.param_match_demog md ON md.demog_param_key = cache.demog_param_key
	INNER JOIN prtl.param_match_geog mg ON mg.geog_param_key = cache.geog_param_key
	INNER JOIN prtl.ia_safety ia ON ia.cd_reporter_type = mia.cd_reporter_type
		AND ia.filter_access_type = mia.filter_access_type
		AND ia.filter_allegation = mia.filter_allegation
		AND ia.filter_finding = mia.filter_finding
		AND ia.cd_sib_age_grp = md.age_sib_group_cd
		AND ia.cd_race_census = md.cd_race_census
		AND ia.county_cd = mg.cd_county
	WHERE ia.cohort_ref_count = 1
	GROUP BY cohort_begin_date
		,ia.qry_type
		,cache.ia_param_key
		,cache.demog_param_key
		,cache.geog_param_key
	ORDER BY cohort_begin_date
		,qry_type
		,ia_param_key
		,demog_param_key
		,geog_param_key;

	CREATE UNIQUE CLUSTERED INDEX [idx_families] ON #families (
		cohort_begin_date
		,qry_type
		,ia_param_key
		,demog_param_key
		,geog_param_key
		);

	INSERT INTO prtl.cache_ia_safety_aggr (
		qry_type
		,date_type
		,start_date
		,ia_param_key
		,demog_param_key
		,geog_param_key
		,month
		,among_first_cmpt_rereferred
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,start_year
		)
	SELECT ia.qry_type
		,ia.date_type
		,ia.cohort_begin_date
		,cache.ia_param_key
		,cache.demog_param_key
		,cache.geog_param_key
		,n.mnth [Months]
		,SUM(IIF(q.total_families > 0 AND n.mnth IS NOT NULL, cnt_case, 0)) / (q.total_families * 1.0000) * 100 [rate]
		,@min_month_start [minmonthstart]
		,@max_month_start [maxmonthstart]
		,@x1
		,@x2
		,GETDATE() [insert_date]
		,@qry_id
		,YEAR(ia.cohort_begin_date) [cohort_year]
	FROM #not_in_cache_sets cache
	INNER JOIN prtl.param_match_ia mia ON mia.ia_param_key = cache.ia_param_key
	INNER JOIN prtl.param_match_demog md ON md.demog_param_key = cache.demog_param_key
	INNER JOIN prtl.param_match_geog mg ON mg.geog_param_key = cache.geog_param_key
	INNER JOIN prtl.ia_safety ia ON ia.cd_reporter_type = mia.cd_reporter_type
		AND ia.filter_access_type = mia.filter_access_type
		AND ia.filter_allegation = mia.filter_allegation
		AND ia.filter_finding = mia.filter_finding
		AND ia.cd_sib_age_grp = md.age_sib_group_cd
		AND ia.cd_race_census = md.cd_race_census
		AND ia.county_cd = mg.cd_county
		AND ia.cohort_ref_count = 1
		AND ia.cohort_begin_date BETWEEN @min_date AND @max_date
	INNER JOIN (
		SELECT DISTINCT number * 3 [mnth]
		FROM ref.numbers
		WHERE number BETWEEN 1 AND 16
		) n ON n.mnth >= ia.nxt_ref_within_min_month
	INNER JOIN #families q ON q.cohort_begin_date = ia.cohort_begin_date
		AND q.ia_param_key = cache.ia_param_key
		AND q.demog_param_key = cache.demog_param_key
		AND q.geog_param_key = cache.geog_param_key
		AND q.qry_type = ia.qry_type
	GROUP BY ia.qry_type
		,ia.date_type
		,ia.cohort_begin_date
		,cache.ia_param_key
		,cache.demog_param_key
		,cache.geog_param_key
		,n.mnth
		,q.total_families
	ORDER BY ia.qry_type
		,ia.date_type
		,ia.cohort_begin_date
		,cache.ia_param_key
		,cache.demog_param_key
		,cache.geog_param_key
		,n.mnth;

	UPDATE STATISTICS prtl.cache_ia_safety_aggr;
END -- not in cache
