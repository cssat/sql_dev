CREATE PROCEDURE [prtl].[sp_ia_trends_rates] (
	@age_grouping_cd VARCHAR(30)
	,@race_cd VARCHAR(30)
	,@cd_county VARCHAR(1000)
	,@cd_reporter_type VARCHAR(100)
	,@filter_access_type VARCHAR(30)
	,@filter_allegation VARCHAR(30)
	,@filter_finding VARCHAR(30)
	)
AS
SET NOCOUNT ON

EXEC prtl.build_cache_ia_trends_aggr @age_grouping_cd
	,@race_cd
	,@cd_county
	,@cd_reporter_type
	,@filter_access_type
	,@filter_allegation
	,@filter_finding;

DECLARE @mindate DATETIME
	,@maxdate DATETIME
	,@maxdateyear DATETIME

SELECT @mindate = min_date_any
	,@maxdate = max_date_any
	,@maxdateyear = max_date_yr
FROM ref.lookup_max_date
WHERE id = 18


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
FROM prtl.fn_ReturnStrTableFromList(@filter_access_type, 1)

INSERT @allegation (cd_allegation)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@filter_allegation, 0)

INSERT @finding (cd_finding)
SELECT CONVERT(INT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@filter_finding, 1)

SELECT a.qry_type [qry_type_poc2]
	,a.date_type
	,a.start_date [Date]
	,a.age_sib_group_cd [age_grouping_cd]
	,a.age_sib_group [Age Grouping]
	,a.cd_race_census [ethnicity_cd]
	,a.tx_race_census [Race/Ethnicity]
	,a.cd_county [county_cd]
	,a.county_desc [County]
	,a.cd_reporter_type
	,a.tx_reporter_type [Reporter Desc]
	,a.cd_access_type
	,a.tx_access_type [Access type desc]
	,a.cd_allegation
	,a.tx_allegation [Allegation]
	,a.cd_finding
	,a.tx_finding [Finding]
	,ROUND(a.Opened / (pop.population_count * 1.00) * 1000, 2) [Opened Investigations & Assessments]
	,ROUND(
		CASE 
			WHEN a.Reported + a.Opened < a.Closed
				THEN a.Reported + a.Opened
			ELSE a.Closed
			END / (pop.population_count * 1.00) * 1000, 2) [Closed Investigations & Assessments]
FROM (
	SELECT m.qry_type
		,m.date_type
		,m.start_date
		,demog.age_sib_group_cd
		,age.age_sib_group
		,demog.cd_race_census
		,eth.tx_race_census
		,geog.cd_county
		,cnty.county_desc
		,ia.cd_reporter_type
		,rpt.tx_reporter_type
		,ia.cd_access_type
		,acc.tx_access_type
		,ia.cd_allegation
		,alg.tx_allegation
		,ia.cd_finding
		,fnd.tx_finding
		,m.start_year
		,CASE 
			WHEN m.cnt_start_date > 0 
				THEN CASE 
						WHEN prtl.fnc_jitter(m.cnt_start_date, m.x1, m.x2) < 1
							THEN 1
						ELSE prtl.fnc_jitter(m.cnt_start_date, m.x1, m.x2)
						END
			ELSE m.cnt_start_date
			END [Reported]
		,CASE 
			WHEN m.cnt_opened > 0
				THEN CASE 
					WHEN prtl.fnc_jitter(m.cnt_opened, m.x1, m.x2) < 1
						THEN 1
					ELSE prtl.fnc_jitter(m.cnt_opened, m.x1, m.x2)
					END
			ELSE m.cnt_opened
			END [Opened]
		,CASE 
			WHEN m.cnt_closed > 0 /* jitter all above 0 */
				THEN CASE 
						WHEN prtl.fnc_jitter(m.cnt_closed, m.x1, m.x2) < 1
							THEN 1
						ELSE prtl.fnc_jitter(m.cnt_closed, m.x1, m.x2)
						END
			ELSE m.cnt_closed
			END [Closed]
	FROM prtl.cache_ia_trends_aggr m
		INNER JOIN (
			SELECT ia.ia_param_key
				,ia.cd_reporter_type
				,ia.cd_access_type
				,ia.cd_allegation
				,ia.cd_finding
			FROM prtl.param_sets_ia ia
			INNER JOIN @reporter_type rt ON rt.cd_reporter_type = ia.cd_reporter_type
			INNER JOIN @access_type at ON at.cd_access_type = ia.cd_access_type
			INNER JOIN @allegation al ON al.cd_allegation = ia.cd_allegation
			INNER JOIN @finding f ON f.cd_finding = ia.cd_finding
			) ia ON ia.ia_param_key = m.ia_param_key
		INNER JOIN (
			SELECT demog.demog_param_key
				,demog.age_sib_group_cd
				,demog.cd_race_census
			FROM prtl.param_sets_demog demog
			INNER JOIN @age a ON a.age_grouping_cd = demog.age_sib_group_cd
			INNER JOIN @ethnicity e ON e.cd_race = demog.cd_race_census
			WHERE demog.age_census_cd = 0
				AND demog.age_dev_cd = 0
				AND demog.age_grouping_cd = 0
				AND demog.pk_gender = 0
			) demog ON demog.demog_param_key = m.demog_param_key
		INNER JOIN (
			SELECT geog.geog_param_key
				,geog.cd_county
			FROM prtl.param_sets_geog geog
			INNER JOIN @county c ON c.cd_county = geog.cd_county
			WHERE geog.cd_region_three = 0
				AND geog.cd_region_six = 0
			) geog ON geog.geog_param_key = m.geog_param_key
	INNER JOIN ref.lookup_age_sib_group age ON age.age_sib_group_cd = demog.age_sib_group_cd
	INNER JOIN ref.lookup_ethnicity_census eth ON eth.cd_race_census = demog.cd_race_census
	INNER JOIN ref.lookup_county cnty ON cnty.cd_county = geog.cd_county
	INNER JOIN ref.filter_reporter_type rpt ON rpt.cd_reporter_type = ia.cd_reporter_type
	INNER JOIN ref.filter_access_type acc ON acc.cd_access_type = ia.cd_access_type
	INNER JOIN ref.filter_allegation alg ON alg.cd_allegation = ia.cd_allegation
	INNER JOIN ref.filter_finding fnd ON fnd.cd_finding = ia.cd_finding
	WHERE m.start_date BETWEEN @mindate AND IIF(m.date_type = 2, @maxdateyear, @maxdate)
		AND m.fl_include_perCapita = 1
) a
INNER JOIN ref.match_census_population_household pop ON pop.measurement_year = a.start_year 
	AND pop.age_sib_group_cd = a.age_sib_group_cd 
	AND pop.cd_race_census = a.cd_race_census 
	AND pop.cd_county = a.cd_county 
	AND pop.population_count != 0
ORDER BY a.qry_type
	,a.date_type
	,a.start_date
	,a.age_sib_group_cd
	,a.cd_race_census
	,a.cd_county
	,a.cd_reporter_type
	,a.cd_access_type
	,a.cd_allegation
	,a.cd_finding;
