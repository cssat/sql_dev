use test_annie;
truncate table cache_pbcs3_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs3_params.txt'
into table cache_pbcs3_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_county, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, 
                         filter_budget, min_start_date, max_start_date, cnt_qry, last_run_date);
						 
analyze table cache_pbcs3_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs3_params)
  where tbl_name='cache_pbcs3_params';
  
  
 truncate table cache_qry_param_pbcs3;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcs3.txt'
 into table cache_qry_param_pbcs3
 fields terminated by '|'
 (int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc
 ,age_grouping_cd,cd_race,cd_county,qry_id,int_hash_key);
 
 
 analyze table cache_qry_param_pbcs3;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcs3)
  where tbl_name='cache_qry_param_pbcs3';
  
  
truncate table prtl_pbcs3;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcs3.txt'
into table prtl_pbcs3
fields terminated by '|'
(cohort_begin_date,date_type,qry_type,cd_race_census,census_hispanic_latino_origin_cd,
county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type,bin_ihs_svc_cd,
filter_access_type,
filter_allegation,filter_finding,
filter_service_type,
filter_budget_type,min_placed_within_month,cnt_case);

 analyze table prtl_pbcs3;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcs3)
  where tbl_name='prtl_pbcs3';
  
  
truncate table cache_pbcs3_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs3_aggr.txt'
into table cache_pbcs3_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,
cd_allegation,cd_finding,cd_service_type,cd_budget_type,cd_sib_age_grp,cd_race_census,
cd_county,month,placed,not_placed,min_start_date,max_start_date,x1,x2,
insert_date,qry_id,start_year,int_hash_key);

 analyze table cache_pbcs3_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs3_aggr)
  where tbl_name='cache_pbcs3_aggr';


