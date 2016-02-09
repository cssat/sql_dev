﻿CREATE VIEW [dbo].[vw_qa_test_annie_pbcw4]
AS
SELECT SUM(date_type) [date_type]
	,SUM(qry_type) [qry_type]
	,SUM(age_grouping_cd_census) [age_Grouping_cd]
	,SUM(pk_gndr) [pk_gndr]
	,SUM(cd_race) [cd_race_census]
	,SUM(census_hispanic_latino_origin_cd) [census_hispanic_latino_origin_cd]
	,SUM(init_cd_plcm_setng) [init_cd_plcm_setng]
	,SUM(long_cd_plcm_setng) [long_cd_plcm_setng]
	,SUM(county_cd) [county_cd]
	,SUM(bin_dep_cd) [bin_dep_cd]
	,SUM(max_bin_los_cd) [max_bin_los_cd]
	,SUM(bin_placement_cd) [bin_placement_cd]
	,SUM(cd_reporter_type) [cd_reporter_type]
	,SUM(bin_ihs_svc_cd) [bin_ihs_svc_cd]
	,SUM(kincare) [kincare]
	,SUM(bin_sibling_group_size) [bin_sibling_group_size]
	,SUM(all_sib_together) [all_sib_together]
	,SUM(some_sib_together) [some_sib_together]
	,SUM(no_sib_together) [no_sib_together]
	,SUM(cnt_child) [total]
	,COUNT(*) [row_count]
FROM prtl.ooh_point_in_time_measures
WHERE fl_w4 = 1
