use review_annie;



truncate table review_annie.cache_qry_param_pbcp5;
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

truncate table review_annie.cache_pbcp5_params;
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

truncate table review_annie.cache_pbcp5_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcp5_aggr.txt'
into table cache_pbcp5_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,cd_discharge_type,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd
,reentry_within_month,reentry_rate
,min_start_date,max_start_date,x1,x2,insert_date,qry_id,start_year,int_hash_key);

analyze table cache_pbcp5_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcp5_aggr)
  where tbl_name='cache_pbcp5_aggr';

