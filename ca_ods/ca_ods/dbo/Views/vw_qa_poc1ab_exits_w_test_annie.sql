create view dbo.vw_qa_poc1ab_exits_w_test_annie
as 
SELECT
(start_date),
sum(qry_type) sum_qry_type,
sum(date_type) [sum_date_type],

sum(bin_dep_cd)[sum_bin_dep_cd],
sum(max_bin_los_cd) [sum_max_bin_los_cd],
sum(bin_placement_cd) [sum_bin_placement_cd],
sum(bin_ihs_svc_cd) [sum_bin_ihs_svc_cd],
sum(cd_reporter_type) [sum_cd_reporter_type],
sum(age_grouping_cd) [sum_age_grouping_cd],
sum(cd_race) [sum_cd_race],
sum(census_hispanic_latino_origin_cd) [sum_census_hispanic_latino_origin_cd],
sum(pk_gndr) [sum_pk_gndr],
sum(init_cd_plcm_setng) sum_init_cd_plcm_setng,
sum(long_cd_plcm_setng) [sum_long_cd_plcm_setng],
sum(county_cd) [sum_county_cd],
sum(int_match_param_key) [sum_int_match_param_key],
sum(filter_access_type) [sum_filter_access_type],
sum(filter_allegation) [sum_filter_allegation],
sum(filter_finding) [sum_filter_finding],
sum(filter_service_category) [sum_filter_service_category],
sum(filter_service_budget) [sum_filter_service_budget],
sum(cd_discharge_type) [sum_cd_discharge_type],
sum(cnt_exits) [sum_cnt_exits]
FROM prtl.prtl_poc1ab_exits
group by start_date
