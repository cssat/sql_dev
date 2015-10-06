CREATE PROCEDURE [prtl].[sp_ia_trends_counts] (
	@age_sib_group_cd VARCHAR(20)
	,@cd_race_census VARCHAR(30)
	,@cd_county VARCHAR(250)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	)
AS
EXEC prtl.log_query_ia_trends @age_sib_group_cd
	,@cd_race_census
	,@cd_county
	,@cd_reporter_type
	,@cd_access_type
	,@cd_allegation
	,@cd_finding
	,1 -- is_counts

DECLARE @age TABLE (age_sib_group_cd TINYINT)
DECLARE @race_census TABLE (cd_race_census TINYINT)
DECLARE @county TABLE (cd_county TINYINT)
DECLARE @reporter_type TABLE (cd_reporter_type TINYINT)
DECLARE @access_type TABLE (cd_access_type TINYINT)
DECLARE @allegation TABLE (cd_allegation TINYINT)
DECLARE @finding TABLE (cd_finding TINYINT)
DECLARE @parameters TABLE (
	age_sib_group_cd TINYINT
	,cd_race_census TINYINT
	,cd_county TINYINT
	,cd_reporter_type TINYINT
	,cd_access_type TINYINT
	,cd_allegation TINYINT
	,cd_finding TINYINT
	,UNIQUE(
		age_sib_group_cd
		,cd_race_census
		,cd_county
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		)
	)

INSERT @age (age_sib_group_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@age_sib_group_cd, 0)

INSERT @race_census (cd_race_census)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_race_census, 0)

INSERT @county (cd_county)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_county, 0)

INSERT @reporter_type (cd_reporter_type)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_reporter_type, 0)

INSERT @access_type (cd_access_type)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_access_type, 0)

INSERT @allegation (cd_allegation)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_allegation, 0)

INSERT @finding (cd_finding)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_finding, 0)

INSERT @parameters (
	age_sib_group_cd
	,cd_race_census
	,cd_county
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	)
SELECT a.age_sib_group_cd
	,rc.cd_race_census
	,c.cd_county
	,rt.cd_reporter_type
	,at.cd_access_type
	,al.cd_allegation
	,f.cd_finding
FROM @age a
CROSS JOIN @race_census rc
CROSS JOIN @county c 
CROSS JOIN @reporter_type rt
CROSS JOIN @access_type at
CROSS JOIN @allegation al
CROSS JOIN @finding f

SELECT m.qry_type [qry_type_poc2]
	,m.date_type
	,m.start_date
	,m.age_sib_group_cd
	,m.cd_race_census
	,m.cd_county
	,m.cd_reporter_type
	,m.cd_access_type
	,m.cd_allegation
	,m.cd_finding
	,m.jit_start_date [Total Cases First Day]
	,m.jit_opened [Opened Cases]
FROM prtl.ia_trends_cache m
INNER JOIN @parameters p ON p.age_sib_group_cd = m.age_sib_group_cd
	AND p.cd_race_census = m.cd_race_census
	AND p.cd_county = m.cd_county
	AND p.cd_reporter_type = m.cd_reporter_type
	AND p.cd_access_type = m.cd_access_type
	AND p.cd_allegation = m.cd_allegation
	AND p.cd_finding = m.cd_finding
ORDER BY m.row_id
