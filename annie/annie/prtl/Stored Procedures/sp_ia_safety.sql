CREATE PROCEDURE [prtl].[sp_ia_safety] (
	@date VARCHAR(3000)
	,@age_grouping_cd VARCHAR(30)
	,@race_cd VARCHAR(30)
	,@cd_county VARCHAR(1000)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	)
AS
EXEC prtl.build_cache_ia_safety_aggr @age_grouping_cd
	,@race_cd
	,@cd_county
	,@cd_reporter_type
	,@cd_access_type
	,@cd_allegation
	,@cd_finding

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

SELECT m.month [Months]
	,m.qry_type
	,m.start_year [Year]
	,demog.age_sib_group_cd [age_grouping_cd]
	,ref_age.age_sib_group [Age Grouping]
	,demog.cd_race_census [ethnicity_cd]
	,ref_eth.tx_race_census [Race/Ethnicity]
	,geog.cd_county [county_cd]
	,ref_cnty.county_desc [County]
	,ia.cd_reporter_type
	,ref_rpt.tx_reporter_type [Reporter Desc]
	,ia.cd_access_type
	,ref_acc.tx_access_type [Access type desc]
	,ia.cd_allegation
	,ref_alg.tx_allegation [Allegation]
	,ia.cd_finding
	,ref_fnd.tx_finding [Finding]
	,among_first_cmpt_rereferred [Among first referrals, percent that are re-referred]
FROM prtl.cache_ia_safety_aggr m
INNER JOIN (
	SELECT ia.*
	FROM prtl.param_sets_ia ia
	INNER JOIN @reporter_type rt ON rt.cd_reporter_type = ia.cd_reporter_type
	INNER JOIN @access_type at ON at.cd_access_type = ia.cd_access_type
	INNER JOIN @allegation al ON al.cd_allegation = ia.cd_allegation
	INNER JOIN @finding f ON f.cd_finding = ia.cd_finding
	) ia ON ia.ia_param_key = m.ia_param_key
INNER JOIN (
	SELECT demog.*
	FROM prtl.param_sets_demog demog
	INNER JOIN @age a ON a.age_grouping_cd = demog.age_sib_group_cd
	INNER JOIN @ethnicity e ON e.cd_race = demog.cd_race_census
	WHERE demog.age_census_cd = 0
		AND demog.age_dev_cd = 0
		AND demog.age_grouping_cd = 0
		AND demog.pk_gender = 0
	) demog ON demog.demog_param_key = m.demog_param_key
INNER JOIN (
	SELECT geog.*
	FROM prtl.param_sets_geog geog
	INNER JOIN @county c ON c.cd_county = geog.cd_county
	WHERE geog.cd_region_three = 0
		AND geog.cd_region_six = 0
	) geog ON geog.geog_param_key = m.geog_param_key
INNER JOIN ref.lookup_ethnicity_census ref_eth ON ref_eth.cd_race_census = demog.cd_race_census
INNER JOIN ref.filter_allegation ref_alg ON ref_alg.cd_allegation = ia.cd_allegation
INNER JOIN ref.filter_finding ref_fnd ON ref_fnd.cd_finding = ia.cd_finding
INNER JOIN ref.lookup_age_sib_group ref_age ON ref_age.age_sib_group_cd = demog.age_sib_group_cd
INNER JOIN ref.lookup_county ref_cnty ON ref_cnty.cd_county = geog.cd_county
INNER JOIN ref.filter_reporter_type ref_rpt ON ref_rpt.cd_reporter_type = ia.cd_reporter_type
INNER JOIN ref.filter_access_type ref_acc ON ref_acc.cd_access_type = ia.cd_access_type
CROSS JOIN ref.last_dw_transfer dw
WHERE DATEADD(MONTH, 12 + m.month, m.start_date) <= dw.cutoff_date
ORDER BY m.qry_type
	,m.start_year
	,demog.age_sib_group_cd
	,demog.cd_race_census
	,geog.cd_county
	,ia.cd_access_type
	,ia.cd_reporter_type
	,ia.cd_allegation
	,ia.cd_finding
	,m.month
