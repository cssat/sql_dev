use test_annie;
truncate table prtl_outcomes;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_outcomes.txt'
into table prtl_outcomes
fields terminated by '|'
(cohort_entry_date,date_type,qry_type,cd_discharge_type,age_grouping_cd,pk_gndr,cd_race_census,census_Hispanic_Latino_Origin_cd,
init_cd_plcm_setng,long_cd_plcm_setng,removal_county_cd,int_match_param_key,bin_dep_cd,max_bin_los_cd,bin_placement_cd,cd_reporter_type,
bin_ihs_svc_cd,filter_access_type,filter_allegation,filter_finding,filter_service_type,filter_budget_type,mnth,discharge_count,cohort_count);
analyze table prtl_outcomes;
select 'prtl_outcomes' as table_name,count(*) as row_cnt from prtl_outcomes;