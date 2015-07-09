CREATE PROCEDURE [prtl].[build_cache_ia_trends_aggr] (
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
DECLARE @age_grouping_cd VARCHAR(30) = '0'
	,@race_cd VARCHAR(30) = '0'
	,@cd_county VARCHAR(1000) = '0'
	,@cd_reporter_type VARCHAR(100) ='0'
	,@cd_access_type VARCHAR(30) = '0'
	,@cd_allegation VARCHAR(30) = '0'
	,@cd_finding VARCHAR(30) = '0,1,2,3,4'
--*/
SET NOCOUNT ON

DECLARE @qry_id BIGINT
	,@mindate DATETIME
	,@maxdate DATETIME
	,@maxmonthstart DATETIME
	,@minmonthstart DATETIME
	,@x1 FLOAT
	,@x2 FLOAT
DECLARE @tblqryid TABLE (qry_id INT);

SET @x1 = RAND()
SET @x2 = RAND()

SELECT @mindate = min_date_any
	,@maxdate = max_date_any
	,@minmonthstart = min_date_any
	,@maxmonthstart = max_date_any
FROM ref.lookup_max_date
WHERE id = 18

SET @qry_id = (
		SELECT TOP 1 qry_id
		FROM prtl.cache_ia_trends_params
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
	INSERT INTO prtl.cache_ia_trends_params (
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
	OUTPUT inserted.qry_ID
	INTO @tblqryid
	SELECT @age_grouping_cd
		,@race_cd
		,@cd_county
		,@cd_reporter_type
		,@cd_access_type
		,@cd_allegation
		,@cd_finding
		,@minmonthstart
		,@maxmonthstart
		,1
		,GETDATE()

	SELECT @qry_id = qry_id
	FROM @tblqryid;
END
ELSE
BEGIN
	UPDATE prtl.cache_ia_trends_params
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
FROM prtl.fn_ReturnStrTableFromList(@age_grouping_cd, 1)

INSERT @ethnicity (cd_race)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@race_cd, 1)

INSERT @county (cd_county)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_county, 0)

INSERT @reporter_type (cd_reporter_type)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_reporter_type, 0)

INSERT @access_type (cd_access_type)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_access_type, 1)

INSERT @allegation (cd_allegation)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_allegation, 0)

INSERT @finding (cd_finding)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_finding, 1)

IF object_ID('tempDB..#not_in_cache_sets') IS NOT NULL
	DROP TABLE #not_in_cache_sets

CREATE TABLE #not_in_cache_sets (
	id INT
	,ia_param_key INT
	,demog_param_key INT
	,geog_param_key INT
)

INSERT #not_in_cache_sets (
	id
	,ia_param_key
	,demog_param_key
	,geog_param_key
)
SELECT ROW_NUMBER() OVER(ORDER BY ia.ia_param_key, demog.demog_param_key, geog.geog_param_key)
	,ia.ia_param_key
	,demog.demog_param_key
	,geog.geog_param_key
FROM (
	SELECT ia.ia_param_key
	FROM prtl.param_sets_ia ia
	INNER JOIN @reporter_type rt ON rt.cd_reporter_type = ia.cd_reporter_type
	INNER JOIN @access_type at ON at.cd_access_type = ia.cd_access_type
	INNER JOIN @allegation al ON al.cd_allegation = ia.cd_allegation
	INNER JOIN @finding f ON f.cd_finding = ia.cd_finding
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
	) demog
CROSS JOIN (
	SELECT geog.geog_param_key
	FROM prtl.param_sets_geog geog
	INNER JOIN @county c ON c.cd_county = geog.cd_county
	WHERE geog.cd_region_three = 0 
		AND geog.cd_region_six = 0
	) geog
WHERE NOT EXISTS (
		SELECT *
		FROM prtl.cache_ia_trends_aggr m
		WHERE m.ia_param_key = ia.ia_param_key 
			AND m.demog_param_key = demog.demog_param_key 
			AND m.geog_param_key = geog.geog_param_key
		);

-- see if results are in cache as a subset of previously run query
IF (
		SELECT COUNT(*)
		FROM #not_in_cache_sets
		) != 0
BEGIN
	CREATE NONCLUSTERED INDEX idx_not_in_cache_sets ON #not_in_cache_sets (
		id
		,ia_param_key
		,demog_param_key
		,geog_param_key
		);

	UPDATE STATISTICS #not_in_cache_sets;

	DECLARE @id INT;

	SET @id = (
			SELECT TOP 1 id
			FROM #not_in_cache_sets
			ORDER BY id
			);

	WHILE @id IS NOT NULL
	BEGIN
		INSERT INTO prtl.cache_ia_trends_aggr (
			qry_type
			,date_type
			,start_date
			,ia_param_key
			,demog_param_key
			,geog_param_key
			,cnt_start_date
			,cnt_opened
			,cnt_closed
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
			,ia.start_date
			,cache.ia_param_key
			,cache.demog_param_key
			,cache.geog_param_key
			,ISNULL(SUM(ia.cnt_start_date), 0) [cnt_start_date]
			,ISNULL(SUM(ia.cnt_opened), 0) [cnt_opened]
			,ISNULL(SUM(ia.cnt_closed), 0) [cnt_closed]
			,@minmonthstart
			,@maxmonthstart
			,@x1
			,@x2
			,GETDATE() [insert_date]
			,@qry_id
			,ia.start_year
		FROM #not_in_cache_sets cache
		INNER JOIN prtl.param_match_ia mia ON mia.ia_param_key = cache.ia_param_key
		INNER JOIN prtl.param_match_demog md ON md.demog_param_key = cache.demog_param_key
		INNER JOIN prtl.param_match_geog mg ON mg.geog_param_key = cache.geog_param_key
		INNER JOIN prtl.ia_trends ia ON ia.cd_reporter_type = mia.cd_reporter_type 
			AND ia.filter_access_type = mia.filter_access_type 
			AND ia.filter_allegation = mia.filter_allegation 
			AND ia.filter_finding = mia.filter_finding 
			AND ia.cd_sib_age_group = md.age_sib_group_cd 
			AND ia.cd_race_census = md.cd_race_census 
			AND ia.county_cd = mg.cd_county 
			AND ia.start_date BETWEEN @mindate AND @maxdate
		WHERE cache.id = @id
		GROUP BY ia.qry_type
			,ia.date_type
			,ia.start_date
			,ia.start_year
			,cache.ia_param_key
			,cache.demog_param_key
			,cache.geog_param_key

		UPDATE ia_aggr
		SET fl_include_perCapita = 0
		FROM prtl.cache_ia_trends_aggr ia_aggr
		INNER JOIN #not_in_cache_sets cache ON cache.id = @id 
			AND cache.ia_param_key = ia_aggr.ia_param_key 
			AND cache.demog_param_key = ia_aggr.demog_param_key 
			AND cache.geog_param_key = ia_aggr.geog_param_key
		INNER JOIN prtl.param_sets_demog demog ON demog.demog_param_key = ia_aggr.demog_param_key
		INNER JOIN prtl.param_sets_geog geog ON geog.geog_param_key = ia_aggr.geog_param_key
		INNER JOIN ref.match_census_population_household cph ON cph.measurement_year = ia_aggr.start_year 
			AND cph.age_sib_group_cd = demog.age_sib_group_cd
			AND cph.cd_race_census = demog.cd_race_census 
			AND cph.cd_county = geog.cd_county 
			AND (
				ia_aggr.cnt_start_date * 1.00 > cph.population_count * .35 
				OR ia_aggr.cnt_opened * 1.00 > cph.population_count * .35 
				OR ia_aggr.cnt_closed * 1.00 > cph.population_count * .35
				);

		UPDATE STATISTICS prtl.cache_poc2ab_aggr;

		SET @id = (
				SELECT TOP 1 id
				FROM #not_in_cache_sets
				WHERE id > @id
				ORDER BY id
				);
	END
END -- not in cache
