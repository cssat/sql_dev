use test_annie;

truncate table prtl_pbcs2;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcs2.txt'
into table prtl_pbcs2
fields terminated by '|'
(cohort_begin_date,date_type,qry_type,int_match_param_key,cd_sib_age_grp
,cd_race_census,census_hispanic_latino_origin_cd,cd_office_collapse
,filter_access_type,filter_allegation,
filter_finding,cd_reporter_type,bin_ihs_svc_cd,initref,initfndref
,cohortrefcount,cohortfndrefcount,case_founded_recurrence,
case_repeat_referral,cnt_case,nxt_ref_within_min_month);


analyze table prtl_pbcs2;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcs2)
  where tbl_name='prtl_pbcs2';


truncate table cache_pbcs2_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs2_params.txt'
into table cache_pbcs2_params
fields terminated by '|'
(qry_ID,age_grouping_cd,cd_race_census,cd_office,cd_reporter_type,filter_access_type
,filter_allegation,filter_finding,min_start_date,max_start_date,cnt_qry,last_run_date);


analyze table  cache_pbcs2_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs2_params)
  where tbl_name='cache_pbcs2_params';

 truncate table cache_qry_param_pbcs2;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcs2.txt'
 into table cache_qry_param_pbcs2
 fields terminated by '|'
 (int_param_key,cd_sib_age_grp,cd_race,cd_office,cd_reporter_type,cd_access_type,cd_allegation,
cd_finding,qry_id,int_all_param_key);
 
analyze table  cache_qry_param_pbcs2;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcs2)
  where tbl_name='cache_qry_param_pbcs2';
  
truncate table cache_pbcs2_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs2_aggr.txt'
into table cache_pbcs2_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,cd_reporter_type,cd_access_type,cd_allegation,
cd_finding,cd_sib_age_grp,cd_race,cd_office,month,among_first_cmpt_rereferred,among_first_cmpt_founded_rereferred,
min_start_date,max_start_date,x1,x2,insert_date,int_hash_key,qry_id,start_year);



analyze table cache_pbcs2_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs2_aggr)
  where tbl_name='cache_pbcs2_aggr';
 
