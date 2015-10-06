CREATE PROCEDURE [prtl].[import_ooh_flow_exits]
AS
TRUNCATE TABLE prtl.ooh_flow_exits

INSERT prtl.ooh_flow_exits (
	qry_type
	,date_type
	,start_date
	,age_grouping_cd
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
	,cd_discharge_type
	,cnt_exits
	)
SELECT CONVERT(TINYINT, qry_type) [qry_type]
	,CONVERT(TINYINT, date_type) [date_type]
	,CONVERT(DATE, start_date) [start_date]
	,CONVERT(TINYINT, age_grouping_cd) [age_grouping_cd]
	,CONVERT(TINYINT, pk_gndr) [pk_gndr]
	,CONVERT(TINYINT, cd_race) [cd_race]
	,CONVERT(TINYINT, census_hispanic_latino_origin_cd) [census_hispanic_latino_origin_cd]
	,CONVERT(TINYINT, init_cd_plcm_setng) [init_cd_plcm_setng]
	,CONVERT(TINYINT, long_cd_plcm_setng) [long_cd_plcm_setng]
	,CONVERT(SMALLINT, county_cd) [county_cd]
	,CONVERT(TINYINT, bin_dep_cd) [bin_dep_cd]
	,CONVERT(TINYINT, max_bin_los_cd) [max_bin_los_cd]
	,CONVERT(TINYINT, bin_placement_cd) [bin_placement_cd]
	,CONVERT(TINYINT, bin_ihs_svc_cd) [bin_ihs_svc_cd]
	,CONVERT(SMALLINT, cd_reporter_type) [cd_reporter_type]
	,filter_access_type
	,filter_allegation
	,filter_finding
	,CONVERT(TINYINT, cd_discharge_type) [cd_discharge_type]
	,cnt_exits
FROM ca_ods.prtl.prtl_poc1ab_exits

UPDATE STATISTICS prtl.ooh_flow_exits

TRUNCATE TABLE prtl.ooh_flow_exits_params

INSERT prtl.ooh_flow_exits_params (
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
FROM ca_ods.prtl.cache_poc1ab_exits_params
ORDER BY qry_ID

UPDATE STATISTICS prtl.ooh_flow_exits_params

TRUNCATE TABLE prtl.ooh_flow_exits_cache_query

INSERT prtl.ooh_flow_exits_cache_query (
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
FROM ca_ods.prtl.cache_qry_param_poc1ab_exits

UPDATE STATISTICS prtl.ooh_flow_exits_cache_query

TRUNCATE TABLE prtl.ooh_flow_exits_cache

INSERT prtl.ooh_flow_exits_cache (
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
	,cd_discharge_type
	,cnt_exits
	,x1
	,x2
	,jit_exits
	)
SELECT qry_type
	,date_type
	,start_date
	,age_grouping_cd
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
	,cd_discharge_type
	,cnt_exits
	,x1
	,x2
	,prtl.fnc_jitter(cnt_exits, x1, x2) [jit_exits]
FROM ca_ods.prtl.cache_poc1ab_exits_aggr

UPDATE STATISTICS prtl.ooh_flow_entries_cache
