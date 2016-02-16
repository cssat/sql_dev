CREATE VIEW [dbo].[cube_prtl_poc1ab_fact]
AS
SELECT ROW_NUMBER() OVER (
		ORDER BY int_param_key
			,qry_type
			,date_type
			,start_date
			,bin_dep_cd
			,bin_los_cd
			,bin_placement_cd
			,bin_ihs_svc_cd
			,cd_reporter_type
			,cd_access_type
			,cd_allegation
			,cd_finding
		) [pk_key]
	,qry_type
	,date_type
	,start_date
	,bin_dep_cd
	,bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,age_grouping_cd
	,cd_race
	,pk_gndr
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,cd_access_type
	,cd_allegation
	,cd_finding
	,int_param_key
	,cnt_start_date
FROM prtl.cache_poc1ab_aggr;
