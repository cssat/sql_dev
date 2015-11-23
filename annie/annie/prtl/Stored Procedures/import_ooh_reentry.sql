CREATE PROCEDURE [prtl].[import_ooh_reentry]
AS
TRUNCATE TABLE prtl.ooh_reentry

INSERT prtl.ooh_reentry (
	qry_type
	,date_type
	,cohort_exit_year
	,age_grouping_cd
	,pk_gndr
	,cd_race_census
	,census_hispanic_latino_origin_cd
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,exit_county_cd
	,bin_dep_cd
	,max_bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cd_discharge_type
	,mnth
	,discharge_count
	,cohort_count
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, cohort_exit_year)
	,CONVERT(TINYINT, age_grouping_cd)
	,CONVERT(TINYINT, pk_gndr)
	,CONVERT(TINYINT, cd_race_census)
	,CONVERT(TINYINT, census_hispanic_latino_origin_cd)
	,CONVERT(TINYINT, init_cd_plcm_setng)
	,CONVERT(TINYINT, long_cd_plcm_setng)
	,CONVERT(SMALLINT, exit_county_cd)
	,CONVERT(TINYINT, bin_dep_cd)
	,CONVERT(TINYINT, max_bin_los_cd)
	,CONVERT(TINYINT, bin_placement_cd)
	,CONVERT(TINYINT, bin_ihs_svc_cd)
	,CONVERT(SMALLINT, cd_reporter_type)
	,filter_access_type
	,CONVERT(SMALLINT, filter_allegation)
	,CONVERT(SMALLINT, filter_finding)
	,CONVERT(TINYINT, cd_discharge_type)
	,CONVERT(TINYINT, mnth)
	,CONVERT(TINYINT, discharge_count)
	,CONVERT(TINYINT, cohort_count)
FROM ca_ods.prtl.prtl_pbcp5

UPDATE STATISTICS prtl.ooh_reentry

TRUNCATE TABLE prtl.ooh_reentry_params

INSERT prtl.ooh_reentry_params (
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
	,min_start_date
	,max_start_date
	,cnt_qry
	,last_run_date
	)
SELECT age_grouping_cd
	,pk_gndr
	,cd_race_census
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,bin_dep_cd
	,min_start_date
	,max_start_date
	,0 [cnt_qry]
	,last_run_date
FROM ca_ods.prtl.cache_pbcp5_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_reentry_params

TRUNCATE TABLE prtl.ooh_reentry_cache_query

INSERT prtl.ooh_reentry_cache_query (
	age_grouping_cd
	,pk_gender
	,cd_race_census
	,initial_cd_placement_setting
	,longest_cd_placement_setting
	,cd_county
	,bin_dependency_cd
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_service_cd
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	)
SELECT age_grouping_cd
	,pk_gndr
	,cd_race
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,bin_dep_cd
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
FROM ca_ods.prtl.cache_qry_param_pbcp5

UPDATE STATISTICS prtl.ooh_reentry_cache_query

TRUNCATE TABLE prtl.ooh_reentry_cache

INSERT prtl.ooh_reentry_cache (
	qry_type
	,date_type
	,cohort_exit_year
	,age_grouping_cd
	,pk_gender
	,cd_race_census
	,initial_cd_placement_setting
	,longest_cd_placement_setting
	,cd_county
	,bin_dependency_cd
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_service_cd
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	,cd_discharge_type
	,reentry_within_month
	,reentry_count
	,total_count
	,reentry_rate
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, cohort_exit_year)
	,CONVERT(TINYINT, age_grouping_cd)
	,CONVERT(TINYINT, pk_gndr)
	,CONVERT(TINYINT, cd_race)
	,CONVERT(TINYINT, init_cd_plcm_setng)
	,CONVERT(TINYINT, long_cd_plcm_setng)
	,CONVERT(TINYINT, county_cd)
	,CONVERT(TINYINT, bin_dep_cd)
	,CONVERT(TINYINT, bin_los_cd)
	,CONVERT(TINYINT, bin_placement_cd)
	,CONVERT(TINYINT, bin_ihs_svc_cd)
	,CONVERT(TINYINT, cd_reporter_type)
	,CONVERT(TINYINT, cd_access_type)
	,CONVERT(TINYINT, cd_allegation)
	,CONVERT(TINYINT, cd_finding)
	,CONVERT(TINYINT, cd_discharge_type)
	,CONVERT(TINYINT, reentry_within_month)
	,reentry_count
	,total_count
	,CONVERT(DECIMAL(9,2), reentry_rate)
FROM ca_ods.prtl.cache_pbcp5_aggr

UPDATE STATISTICS prtl.ooh_reentry_cache
