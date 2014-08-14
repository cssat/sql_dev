use test_annie;
truncate table cache_poc3ab_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc3ab_params.txt'
into table cache_poc3ab_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_office, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, 
                         filter_budget, min_start_date, max_start_date, cnt_qry, last_run_date);
						 

analyze table cache_poc3ab_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc3ab_params)
  where tbl_name='cache_poc3ab_params';

 truncate table cache_qry_param_poc3ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_poc3ab.txt'
 into table cache_qry_param_poc3ab
 fields terminated by '|'
 (int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,cd_office,qry_id,int_hash_key);
 
 analyze table cache_qry_param_poc3ab;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc3ab)
  where tbl_name='cache_qry_param_poc3ab';
  
truncate table prtl_poc3ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/prtl_poc3ab.txt'
 into table prtl_poc3ab
 fields terminated by '|'
 (qry_type,date_type,start_date,start_year,int_match_param_key,
 bin_ihs_svc_cd,cd_reporter_type,filter_access_type,filter_allegation,
 filter_finding,filter_service_type,filter_budget_type,
 cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,
 cd_office,cnt_start_date,cnt_opened,cnt_closed);
 analyze table prtl_poc3ab;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc3ab)
  where tbl_name='prtl_poc3ab';

 
truncate table cache_poc3ab_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc3ab_aggr.txt'
into table cache_poc3ab_aggr
fields terminated by '|'
( qry_type, date_type,  start_date, int_param_key, bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation
 ,cd_finding, cd_service_type, cd_budget_type, cd_sib_age_grp, cd_race_census, cd_office_collapse, cnt_start_date, cnt_opened, cnt_closed,min_start_date,  max_start_date, x1, x2, insert_date
, qry_id, start_year,int_hash_key);



analyze table cache_poc3ab_aggr;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc3ab_aggr)
  where tbl_name='cache_poc3ab_aggr';