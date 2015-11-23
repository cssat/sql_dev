CREATE PROCEDURE [prtl].[sp_ooh_flow_entries_rates] (
	@date VARCHAR(3000)
	,@age_grouping_cd VARCHAR(20)
	,@pk_gender VARCHAR(10)
	,@cd_race_census VARCHAR(30)
	,@initial_cd_placement_setting VARCHAR(50)
	,@longest_cd_placement_setting VARCHAR(50)
	,@cd_county VARCHAR(200)
	,@bin_los_cd VARCHAR(30)
	,@bin_placement_cd VARCHAR(30)
	,@bin_ihs_service_cd VARCHAR(30)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)
	,@bin_dependency_cd VARCHAR(20)
	)
AS
EXEC prtl.log_query_ooh_flow_entries @age_grouping_cd
	,@pk_gender
	,@cd_race_census
	,@initial_cd_placement_setting
	,@longest_cd_placement_setting
	,@cd_county
	,@bin_los_cd
	,@bin_placement_cd
	,@bin_ihs_service_cd
	,@cd_reporter_type
	,@cd_access_type
	,@cd_allegation
	,@cd_finding
	,@bin_dependency_cd
	,0 -- is_counts

EXEC prtl.build_ooh_flow_entries_cache @age_grouping_cd
	,@pk_gender
	,@cd_race_census
	,@initial_cd_placement_setting
	,@longest_cd_placement_setting
	,@cd_county
	,@bin_los_cd
	,@bin_placement_cd
	,@bin_ihs_service_cd
	,@cd_reporter_type
	,@cd_access_type
	,@cd_allegation
	,@cd_finding
	,@bin_dependency_cd

DECLARE @min_filter_date DATETIME = prtl.min_ooh_filter_date(@cd_access_type, @cd_allegation, @cd_finding, @bin_dependency_cd)
DECLARE @age TABLE (age_grouping_cd TINYINT)
DECLARE @gender TABLE (pk_gender TINYINT)
DECLARE @race_census TABLE (cd_race_census TINYINT)
DECLARE @initial_placement_setting TABLE (cd_placement_setting TINYINT)
DECLARE @longest_placement_setting TABLE (cd_placement_setting TINYINT)
DECLARE @county TABLE (cd_county TINYINT)
DECLARE @bin_los TABLE (bin_los_cd TINYINT)
DECLARE @bin_placement TABLE (bin_placement_cd TINYINT)
DECLARE @bin_ihs_service TABLE (bin_ihs_service_cd TINYINT)
DECLARE @reporter_type TABLE (cd_reporter_type TINYINT)
DECLARE @access_type TABLE (cd_access_type TINYINT)
DECLARE @allegation TABLE (cd_allegation TINYINT)
DECLARE @finding TABLE (cd_finding TINYINT)
DECLARE @bin_dependency TABLE (bin_dependency_cd TINYINT)
DECLARE @parameters TABLE (
	age_grouping_cd TINYINT
	,pk_gender TINYINT
	,cd_race_census TINYINT
	,initial_cd_placement_setting TINYINT
	,longest_cd_placement_setting TINYINT
	,cd_county TINYINT
	,bin_los_cd TINYINT
	,bin_placement_cd TINYINT
	,bin_ihs_service_cd TINYINT
	,cd_reporter_type TINYINT
	,cd_access_type TINYINT
	,cd_allegation TINYINT
	,cd_finding TINYINT
	,bin_dependency_cd TINYINT
	,UNIQUE(
		bin_dependency_cd
		,age_grouping_cd
		,pk_gender
		,cd_race_census
		,initial_cd_placement_setting
		,longest_cd_placement_setting
		,cd_county
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_service_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		)
	)

INSERT @age (age_grouping_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@age_grouping_cd, 0)

INSERT @gender (pk_gender)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@pk_gender, 0)

INSERT @race_census (cd_race_census)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_race_census, 0)

INSERT @initial_placement_setting (cd_placement_setting)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@initial_cd_placement_setting, 0)

INSERT @longest_placement_setting (cd_placement_setting)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@longest_cd_placement_setting, 0)

INSERT @county (cd_county)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@cd_county, 0)

INSERT @bin_los (bin_los_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@bin_los_cd, 0)

INSERT @bin_placement (bin_placement_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@bin_placement_cd, 0)

INSERT @bin_ihs_service (bin_ihs_service_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@bin_ihs_service_cd, 0)

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

INSERT @bin_dependency (bin_dependency_cd)
SELECT CONVERT(TINYINT, arrValue)
FROM prtl.fn_ReturnStrTableFromList(@bin_dependency_cd, 0)

INSERT @parameters (
	age_grouping_cd
	,pk_gender
	,cd_race_census
	,initial_cd_placement_setting
	,longest_cd_placement_setting
	,cd_county
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_service_cd
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	,bin_dependency_cd
	)
SELECT a.age_grouping_cd
	,g.pk_gender
	,rc.cd_race_census
	,ips.cd_placement_setting
	,lps.cd_placement_setting
	,c.cd_county
	,los.bin_los_cd
	,bp.bin_placement_cd
	,ihs.bin_ihs_service_cd
	,rt.cd_reporter_type
	,at.cd_access_type
	,al.cd_allegation
	,f.cd_finding
	,bd.bin_dependency_cd
FROM @age a
CROSS JOIN @gender g
CROSS JOIN @race_census rc
CROSS JOIN @initial_placement_setting ips
CROSS JOIN @longest_placement_setting lps
CROSS JOIN @county c
CROSS JOIN @bin_los los
CROSS JOIN @bin_placement bp
CROSS JOIN @bin_ihs_service ihs
CROSS JOIN @reporter_type rt
CROSS JOIN @access_type at
CROSS JOIN @allegation al
CROSS JOIN @finding f
CROSS JOIN @bin_dependency bd

SELECT m.qry_type [qry_type_poc2]
	,m.date_type
	,m.start_date
	,m.age_grouping_cd
	,m.pk_gender
	,m.cd_race_census
	,m.initial_cd_placement_setting
	,m.longest_cd_placement_setting
	,m.cd_county
	,m.bin_los_cd
	,m.bin_placement_cd
	,m.bin_ihs_service_cd
	,m.cd_reporter_type
	,m.cd_access_type
	,m.cd_allegation
	,m.cd_finding
	,m.bin_dependency_cd
	,m.rate_entries [Rate of Entries]
FROM prtl.ooh_flow_entries_cache m
INNER JOIN @parameters p ON p.bin_dependency_cd = m.bin_dependency_cd
	AND p.age_grouping_cd = m.age_grouping_cd
	AND p.pk_gender = m.pk_gender
	AND p.cd_race_census = m.cd_race_census
	AND p.initial_cd_placement_setting = m.initial_cd_placement_setting
	AND p.longest_cd_placement_setting = m.longest_cd_placement_setting
	AND p.cd_county = m.cd_county
	AND p.bin_los_cd = m.bin_los_cd
	AND p.bin_placement_cd = m.bin_placement_cd
	AND p.bin_ihs_service_cd = m.bin_ihs_service_cd
	AND p.cd_reporter_type = m.cd_reporter_type
	AND p.cd_access_type = m.cd_access_type
	AND p.cd_allegation = m.cd_allegation
	AND p.cd_finding = m.cd_finding
WHERE m.start_date >= @min_filter_date
	AND m.fl_include_perCapita = 1
ORDER BY m.bin_dependency_cd
	,m.qry_type
	,m.date_type
	,m.start_date
	,m.age_grouping_cd
	,m.pk_gender
	,m.cd_race_census
	,m.initial_cd_placement_setting
	,m.longest_cd_placement_setting
	,m.cd_county
	,m.bin_los_cd
	,m.bin_placement_cd
	,m.bin_ihs_service_cd
	,m.cd_reporter_type
	,m.cd_access_type
	,m.cd_allegation
	,m.cd_finding
