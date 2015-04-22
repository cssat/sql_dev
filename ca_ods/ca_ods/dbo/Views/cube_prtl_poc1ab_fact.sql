

create view [dbo].[cube_prtl_poc1ab_fact]
as

select  
	ROW_NUMBER() over ( order by int_match_param_key
											,qry_type
											,date_type
											,start_date
											,bin_dep_cd
											,los.bin_los_cd
											,bin_placement_cd
											,bin_ihs_svc_cd
											,cd_reporter_type
											,poc1ab.filter_access_type
										   ,poc1ab.filter_allegation
										   ,poc1ab.filter_finding
										   ,poc1ab.filter_service_category
										   ,poc1ab.filter_service_budget) [pk_key]
	,qry_type
	,date_type
	,start_date
	,bin_dep_cd
	,los.bin_los_cd
	,bin_placement_cd
	,bin_ihs_svc_cd
	,cd_reporter_type
	,age_grouping_cd
	,cd_race
	,census_hispanic_latino_origin_cd
	,pk_gndr
	,init_cd_plcm_setng
	,long_cd_plcm_setng
	,county_cd
	,poc1ab.filter_access_type
   ,poc1ab.filter_allegation
   ,poc1ab.filter_finding
   ,poc1ab.filter_service_category
   ,poc1ab.filter_service_budget
   ,poc1ab.int_match_param_key
	,cnt_start_date
from prtl.prtl_poc1ab poc1ab
 join dbo.prm_los_max_bin_los_cd	los on los.match_code=poc1ab.max_bin_los_cd	;









