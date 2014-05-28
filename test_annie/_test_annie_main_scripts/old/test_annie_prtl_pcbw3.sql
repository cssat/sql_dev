use test_annie;



truncate table test_annie.prtl_pbcw3;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcw3.txt'
into table prtl_pbcw3
fields terminated by '|'
(cohort_begin_date, date_type, qry_type, age_grouping_cd, pk_gndr, cd_race_census, 
census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, Removal_County_Cd, int_match_param_key, bin_dep_cd, bin_los_cd, 
bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding,
filter_service_type, filter_budget_type,  family_setting_cnt, family_setting_DCFS_cnt, family_setting_private_agency_cnt, relative_care, group_inst_care_cnt, 
total);

analyze table prtl_pbcw3;

select 'prtl_pbcw3' as filename,count(*),sum(total),sum(family_setting_DCFS_cnt) from prtl_pbcw3;


