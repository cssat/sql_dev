CREATE PROCEDURE [prtl].[import_ooh_outcomes]
AS
TRUNCATE TABLE prtl.ooh_outcomes

INSERT prtl.ooh_outcomes (
	cohort_entry_date
	,qry_type
	,date_type
	,age_grouping_cd
	,pk_gndr
	,cd_race_census
	,census_Hispanic_Latino_Origin_cd
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,Removal_County_Cd
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
SELECT CONVERT(DATE, cohort_entry_date)
	,CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(TINYINT, age_grouping_cd)
	,CONVERT(TINYINT, pk_gndr)
	,CONVERT(TINYINT, cd_race_census)
	,CONVERT(TINYINT, census_Hispanic_Latino_Origin_cd)
	,CONVERT(TINYINT, init_cd_plcm_setng)
	,CONVERT(TINYINT, long_cd_plcm_setng)
	,CONVERT(SMALLINT, Removal_County_Cd)
	,CONVERT(TINYINT, bin_dep_cd)
	,CONVERT(TINYINT, max_bin_los_cd)
	,CONVERT(TINYINT, bin_placement_cd)
	,CONVERT(TINYINT, bin_ihs_svc_cd)
	,CONVERT(SMALLINT, cd_reporter_type)
	,filter_access_type
	,filter_allegation
	,filter_finding
	,CONVERT(TINYINT, cd_discharge_type)
	,CONVERT(TINYINT, mnth)
	,discharge_count
	,cohort_count
FROM ca_ods.prtl.prtl_outcomes

UPDATE STATISTICS prtl.ooh_outcomes

TRUNCATE TABLE prtl.ooh_outcomes_params

INSERT prtl.ooh_outcomes_params (
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
	,cnt_qry_outcomes
	,cnt_qry_outcomes_3m
	,cnt_qry_outcomes_12m
	,cnt_qry_outcomes_24m
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
	,0 [cnt_qry_outcomes]
	,0 [cnt_qry_outcomes_3m]
	,0 [cnt_qry_outcomes_12m]
	,0 [cnt_qry_outcomes_24m]
	,last_run_date
FROM ca_ods.prtl.cache_outcomes_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_outcomes_params

TRUNCATE TABLE prtl.ooh_outcomes_cache_query

INSERT prtl.ooh_outcomes_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_outcomes

UPDATE STATISTICS prtl.ooh_outcomes_cache_query

TRUNCATE TABLE prtl.ooh_outcomes_cache

INSERT prtl.ooh_outcomes_cache (
	qry_type
	,date_type
	,cohort_entry_date
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
	,month
	,discharge_count
	,cohort_count
	,rate
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, cohort_entry_date)
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
	,CONVERT(TINYINT, month)
	,discharge_count
	,cohort_count
	,CONVERT(DECIMAL(9, 2), rate)
FROM ca_ods.prtl.cache_outcomes_aggr

UPDATE STATISTICS prtl.ooh_outcomes_cache
