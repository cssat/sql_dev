use test_annie;



truncate table test_annie.cache_qry_param_pbcp5;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcp5.txt'
into table cache_qry_param_pbcp5
fields terminated by '|'
(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type
 ,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,qry_id,int_hash_key);


analyze table cache_qry_param_pbcp5;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcp5)
  where tbl_name='cache_qry_param_pbcp5';

truncate table test_annie.cache_pbcp5_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcp5_params.txt'
into table cache_pbcp5_params
fields terminated by '|'
( qry_ID ,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd
      ,bin_los_cd ,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,filter_access_type,filter_allegation
      ,filter_finding,filter_srvc_type,filter_budget,bin_dep_cd,min_start_date,max_start_date,cnt_qry,last_run_date);

analyze table cache_pbcp5_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcp5_params)
  where tbl_name='cache_pbcp5_params';

  
truncate table test_annie.cache_pbcp5_aggr;

SET autocommit=0;
SET foreign_key_checks=0;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcp5_aggr.txt'
into table cache_pbcp5_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,cd_discharge_type,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd
,reentry_within_month,reentry_rate
,min_start_date,max_start_date,x1,x2,insert_date,qry_id,start_year,int_hash_key);

commit;
SET foreign_key_checks=1;

analyze table cache_pbcp5_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcp5_aggr)
  where tbl_name='cache_pbcp5_aggr';

truncate table test_annie.prtl_pbcp5;

SET autocommit=0;
SET foreign_key_checks=0;

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

commit;
SET foreign_key_checks=1;

analyze table prtl_pbcp5;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcp5)
  where tbl_name='prtl_pbcp5';
