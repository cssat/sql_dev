CREATE PROCEDURE [prtl].[import_ia_trends]
AS
TRUNCATE TABLE prtl.ia_trends

INSERT prtl.ia_trends (
	qry_type
	,date_type
	,start_date
    ,start_year
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cd_sib_age_group
	,cd_race_census
	,census_hispanic_latino_origin_cd
	,county_cd
	,cnt_start_date
	,cnt_opened
	,cnt_closed
	)
SELECT qry_type
	,date_type
	,start_date
    ,start_year
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cd_sib_age_group
	,cd_race_census
	,census_hispanic_latino_origin_cd
	,county_cd
	,cnt_start_date
	,cnt_opened
    ,cnt_closed
FROM ca_ods.prtl.prtl_poc2ab

UPDATE STATISTICS prtl.ia_trends
