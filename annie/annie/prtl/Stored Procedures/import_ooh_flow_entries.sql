CREATE PROCEDURE [prtl].[import_ooh_flow_entries]
AS
TRUNCATE TABLE prtl.ooh_flow_entries

INSERT prtl.ooh_flow_entries (
	qry_type
	,date_type
	,start_date
	,bin_dep_cd
	,age_grouping_cd
	,pk_gndr
	,cd_race
	,census_hispanic_latino_origin_cd
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,max_bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cnt_entries
	)
SELECT CONVERT(TINYINT, qry_type)
	,CONVERT(TINYINT, date_type)
	,CONVERT(DATE, start_date)
	,CONVERT(TINYINT, bin_dep_cd)
	,CONVERT(TINYINT, age_grouping_cd)
	,CONVERT(TINYINT, pk_gndr)
	,CONVERT(TINYINT, cd_race)
	,CONVERT(TINYINT, census_hispanic_latino_origin_cd)
	,CONVERT(TINYINT, init_cd_plcm_setng)
	,CONVERT(TINYINT, long_cd_plcm_setng)
	,CONVERT(SMALLINT, county_cd)
	,CONVERT(TINYINT, max_bin_los_cd)
	,CONVERT(TINYINT, bin_placement_cd)
	,CONVERT(TINYINT, bin_ihs_svc_cd)
	,CONVERT(SMALLINT, cd_reporter_type)
	,filter_access_type
	,filter_allegation
	,filter_finding
	,cnt_entries
FROM ca_ods.prtl.prtl_poc1ab_entries

UPDATE STATISTICS prtl.ooh_flow_entries

TRUNCATE TABLE prtl.ooh_flow_entries_params

INSERT prtl.ooh_flow_entries_params (
	age_grouping_cd
	,cd_race_census
	,pk_gender
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
	,cd_race_census
	,pk_gndr
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
FROM ca_ods.prtl.cache_poc1ab_entries_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_flow_entries_params

TRUNCATE TABLE prtl.ooh_flow_entries_cache_query

INSERT prtl.ooh_flow_entries_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_poc1ab_entries

UPDATE STATISTICS prtl.ooh_flow_entries_cache_query

TRUNCATE TABLE prtl.ooh_flow_entries_cache

INSERT prtl.ooh_flow_entries_cache (
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
	,cnt_entries
	,x1
	,x2
	,jit_entries
	,fl_include_perCapita
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
	,cnt_entries
	,x1
	,x2
	,prtl.fnc_jitter(cnt_entries, x1, x2) [jit_entries]
	,CONVERT(BIT, fl_include_perCapita)
FROM ca_ods.prtl.cache_poc1ab_entries_aggr

UPDATE STATISTICS prtl.ooh_flow_entries_cache

UPDATE ooh
SET rate_entries = ROUND(ooh.jit_entries / (cp.population_count * 1.00) * 1000, 2)
FROM prtl.ooh_flow_entries_cache ooh
INNER JOIN ref.match_census_population cp ON cp.measurement_year = YEAR(ooh.start_date)
	AND cp.age_grouping_cd = ooh.age_grouping_cd
	AND cp.pk_gender = ooh.pk_gender
	AND cp.cd_race_census = ooh.cd_race_census
	AND cp.cd_county = ooh.cd_county
	AND cp.population_count != 0

UPDATE STATISTICS prtl.ooh_flow_entries_cache
