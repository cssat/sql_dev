use review_annie;
truncate table cache_poc1ab_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc1ab_params.txt'
into table cache_poc1ab_params
fields terminated by '|'
(qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd 
 ,cd_reporter_type, filter_access_type, filter_allegation
 , filter_finding, filter_srvc_type, filter_budget, bin_dep_cd
 ,min_start_date, max_start_date, cnt_qry, last_run_date);

  analyze table cache_poc1ab_params;
  
  
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_params)
  where tbl_name='cache_poc1ab_params';



 truncate table cache_qry_param_poc1ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_poc1ab.txt'
 into table cache_qry_param_poc1ab
 fields terminated by '|'
 (qry_id,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd
 ,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,
 age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,int_hash_key);
 
 analyze table cache_qry_param_poc1ab;

 
   update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc1ab)
  where tbl_name='cache_qry_param_poc1ab';
 

   update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc1ab)
  where tbl_name='prtl_poc1ab';
 
truncate table cache_poc1ab_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc1ab_aggr.txt'
into table cache_poc1ab_aggr
fields terminated by '|'
(qry_type, date_type,start_date, int_param_key, bin_dep_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
cd_reporter_type, cd_access_type, cd_allegation
, cd_finding, cd_subctgry_poc_frc, cd_budget_poc_frc
,  age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, cnt_start_date, min_start_date, 
max_start_date, x1, x2, insert_date,int_hash_key,qry_id,start_year,fl_include_perCapita);


analyze table cache_poc1ab_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_aggr)
  where tbl_name='cache_poc1ab_aggr';


