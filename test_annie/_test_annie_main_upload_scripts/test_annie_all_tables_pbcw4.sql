use test_annie;



truncate table test_annie.cache_qry_param_pbcw4;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcw4.txt'
into table cache_qry_param_pbcw4
fields terminated by '|'
(int_param_key, bin_dep_cd,bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, cd_reporter_type
, cd_access_type, cd_allegation, cd_finding, cd_subctgry_poc_frc, 
cd_budget_poc_frc, age_grouping_cd, cd_race, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng
, county_cd, qry_id, int_hash_key);

analyze table cache_qry_param_pbcw4;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcw4)
  where tbl_name='cache_qry_param_pbcw4';

truncate table test_annie.cache_pbcw4_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw4_params.txt'
into table cache_pbcw4_params
fields terminated by '|'
( qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
 cd_reporter_type, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, filter_budget, bin_dep_cd, min_start_date, 
 max_start_date, cnt_qry,last_run_date);

analyze table cache_pbcw4_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw4_params)
  where tbl_name='cache_pbcw4_params';


truncate table test_annie.cache_pbcw4_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw4_aggr.txt'
into table cache_pbcw4_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,kincare,bin_sibling_group_size,all_together,
some_together,none_together,min_start_date,max_start_date,x1,x2,insert_date,qry_id,cohort_begin_year,int_hash_key,cnt_cohort);

analyze table cache_pbcw4_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw4_aggr)
  where tbl_name='cache_pbcw4_aggr';


