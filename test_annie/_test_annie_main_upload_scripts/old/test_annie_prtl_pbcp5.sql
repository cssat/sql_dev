use test_annie;

truncate table test_annie.prtl_pbcp5;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcp5.txt'
into table prtl_pbcp5
FIELDS TERMINATED by '|'
(cohort_exit_year,date_type,qry_type,cd_discharge_type,age_grouping_cd,
pk_gndr,cd_race_census,census_hispanic_latino_origin_cd
,init_cd_plcm_setng,long_cd_plcm_setng,exit_county_cd,int_match_param_key,bin_dep_cd
,max_bin_los_cd,bin_placement_cd,cd_reporter_type
,bin_ihs_svc_cd,filter_access_type,filter_allegation,filter_finding,filter_service_category
,filter_service_budget,mnth
,discharge_count
,cohort_count);
analyze table prtl_pbcp5;

select 'prtl_pbcp5' as filename ,count(*) from prtl_pbcp5;

