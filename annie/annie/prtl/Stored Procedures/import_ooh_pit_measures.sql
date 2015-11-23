CREATE PROCEDURE [prtl].[import_ooh_pit_measures]
AS
TRUNCATE TABLE prtl.ooh_pit_measures

INSERT prtl.ooh_pit_measures (
	qry_type
	,date_type
	,start_date
	,age_grouping_cd_mix
	,age_grouping_cd_census
	,pk_gndr
	,cd_race
	,census_hispanic_latino_origin_cd
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,bin_dep_cd
	,max_bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,kincare
	,bin_sibling_group_size
	,cnt_child
	,fl_ooh_pit
	,cnt_child_unique
	,fl_ooh_wb_family_settings
	,family_setting_dcfs_cnt
	,family_setting_private_agency_cnt
	,relative_care
	,group_inst_care_cnt
	,fl_ooh_wb_siblings
	,all_sib_together
	,some_sib_together
	,no_sib_together
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, start_date)
	,CONVERT(TINYINT, age_grouping_cd_mix)
	,CONVERT(TINYINT, age_grouping_cd_census)
	,CONVERT(TINYINT, pk_gndr)
	,CONVERT(TINYINT, cd_race)
	,CONVERT(TINYINT, census_hispanic_latino_origin_cd)
	,CONVERT(TINYINT, init_cd_plcm_setng)
	,CONVERT(TINYINT, long_cd_plcm_setng)
	,CONVERT(SMALLINT, county_cd)
	,CONVERT(TINYINT, bin_dep_cd)
	,CONVERT(TINYINT, max_bin_los_cd)
	,CONVERT(TINYINT, bin_placement_cd)
	,CONVERT(TINYINT, bin_ihs_svc_cd)
	,CONVERT(SMALLINT, cd_reporter_type)
	,filter_access_type
	,filter_allegation
	,filter_finding
	,CONVERT(TINYINT, kincare)
	,CONVERT(TINYINT, bin_sibling_group_size)
	,CONVERT(TINYINT, cnt_child)
	,CONVERT(BIT, fl_poc1ab) [fl_ooh_pit]
	,CONVERT(TINYINT, cnt_child_unique)
	,CONVERT(BIT, fl_w3) [fl_ooh_wb_family_settings]
	,CONVERT(TINYINT, family_setting_DCFS_cnt)
	,CONVERT(TINYINT, family_setting_private_agency_cnt)
	,CONVERT(TINYINT, relative_care)
	,CONVERT(TINYINT, group_inst_care_cnt)
	,CONVERT(BIT, fl_w4) [fl_ooh_wb_siblings]
	,CONVERT(TINYINT, all_sib_together)
	,CONVERT(TINYINT, some_sib_together)
	,CONVERT(TINYINT, no_sib_together)
FROM ca_ods.prtl.ooh_point_in_time_measures

UPDATE STATISTICS prtl.ooh_pit_measures

TRUNCATE TABLE prtl.ooh_pit_params

INSERT prtl.ooh_pit_params (
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
	,cnt_qry_counts
	,cnt_qry_rates
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
	,0 [cnt_qry_counts]
	,0 [cnt_qry_rates]
	,last_run_date
FROM ca_ods.prtl.cache_poc1ab_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_pit_params

TRUNCATE TABLE prtl.ooh_pit_cache_query

INSERT prtl.ooh_pit_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_poc1ab

UPDATE STATISTICS prtl.ooh_pit_cache_query

TRUNCATE TABLE prtl.ooh_pit_cache

INSERT prtl.ooh_pit_cache (
	qry_type
	,date_type
	,start_date
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
	,cnt_start_date
	,x1
	,x2
	,jit_start_date
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, start_date)
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
	,cnt_start_date
	,x1
	,x2
	,prtl.fnc_jitter(cnt_start_date, x1, x2) [jit_start_date]
FROM ca_ods.prtl.cache_poc1ab_aggr

UPDATE STATISTICS prtl.ooh_pit_cache

UPDATE ooh
SET rate_start_date = ROUND(ooh.jit_start_date / (cp.population_count * 1.00) * 1000, 2)
FROM prtl.ooh_pit_cache ooh
INNER JOIN ref.match_census_population cp ON cp.measurement_year = YEAR(ooh.start_date)
	AND cp.age_grouping_cd = ooh.age_grouping_cd
	AND cp.pk_gender = ooh.pk_gender
	AND cp.cd_race_census = ooh.cd_race_census
	AND cp.cd_county = ooh.cd_county
	AND cp.population_count != 0

UPDATE STATISTICS prtl.ooh_pit_cache

TRUNCATE TABLE prtl.ooh_wb_family_settings_params

INSERT prtl.ooh_wb_family_settings_params (
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
FROM ca_ods.prtl.cache_pbcw3_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_wb_family_settings_params

TRUNCATE TABLE prtl.ooh_wb_family_settings_cache_query

INSERT prtl.ooh_wb_family_settings_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_pbcw3

UPDATE STATISTICS prtl.ooh_wb_family_settings_cache_query

TRUNCATE TABLE prtl.ooh_wb_family_settings_cache

INSERT prtl.ooh_wb_family_settings_cache (
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
	,family_setting_dcfs_percentage
	,family_setting_private_agency_percentage
	,relative_percentage
	,group_inst_care_percentage
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
	,family_setting_dcfs_prcntg
	,family_setting_private_agency_prcntg
	,relative_prcntg
	,group_inst_care_prcntg
FROM ca_ods.prtl.cache_pbcw3_aggr

UPDATE STATISTICS prtl.ooh_wb_family_settings_cache

TRUNCATE TABLE prtl.ooh_wb_siblings_params

INSERT prtl.ooh_wb_siblings_params (
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
FROM ca_ods.prtl.cache_pbcw4_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_wb_siblings_params

TRUNCATE TABLE prtl.ooh_wb_siblings_cache_query

INSERT prtl.ooh_wb_siblings_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_pbcw4

UPDATE STATISTICS prtl.ooh_wb_siblings_cache_query

TRUNCATE TABLE prtl.ooh_wb_siblings_cache

INSERT prtl.ooh_wb_siblings_cache (
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
	,kincare
	,bin_sibling_group_size
	,all_together
	,some_together
	,none_together
	,cnt_cohort
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
	,CONVERT(TINYINT, kincare)
	,CONVERT(TINYINT, bin_sibling_group_size)
	,all_together
	,some_together
	,none_together
	,cnt_cohort
FROM ca_ods.prtl.cache_pbcw4_aggr

UPDATE STATISTICS prtl.ooh_wb_siblings_cache
