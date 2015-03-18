use review_annie;




truncate table cache_poc2ab_params;
LOAD DATA INFILE '/data/pocweb/cache_poc2ab_params.txt'
into table cache_poc2ab_params
fields terminated by '|'
(qry_ID,age_grouping_cd,cd_race_census,cd_county,cd_reporter_type,filter_access_type
,filter_allegation,filter_finding,min_start_date,max_start_date,cnt_qry,last_run_date);


analyze table cache_poc2ab_params;

 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc2ab_params)
  where tbl_name='cache_poc2ab_params';

SET autocommit=0;
SET foreign_key_checks=0;  

 truncate table cache_qry_param_poc2ab;
 LOAD DATA INFILE '/data/pocweb/cache_qry_param_poc2ab.txt'
 into table cache_qry_param_poc2ab
 fields terminated by '|'
 (qry_id,int_param_key,
cd_sib_age_grp,
cd_race,
cd_county,
cd_reporter_type,
cd_access_type,
cd_allegation,
cd_finding,
int_all_param_key);
 
 commit;
 SET foreign_key_checks=1;  
 
 analyze table cache_qry_param_poc2ab;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc2ab)
  where tbl_name='cache_qry_param_poc2ab';
 
truncate table prtl_poc2ab;
LOAD DATA INFILE '/data/pocweb/prtl_poc2ab.txt'
into table prtl_poc2ab
fields terminated by '|'
(qry_type,date_type,start_date,start_year,int_match_param_key
,cd_reporter_type,filter_access_type,filter_allegation
,filter_finding,cd_sib_age_group,cd_race_census
,census_hispanic_latino_origin_cd,county_cd,cnt_start_date
,cnt_opened,cnt_closed);


analyze table prtl_poc2ab;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc2ab)
  where tbl_name='prtl_poc2ab';


 truncate table cache_poc2ab_aggr;
SET autocommit=0;
SET foreign_key_checks=0;  
 
LOAD DATA INFILE '/data/pocweb/cache_poc2ab_aggr.txt'
into table cache_poc2ab_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,cd_reporter_type,cd_access_type,cd_allegation
,cd_finding,cd_sib_age_grp,cd_race,cd_county,cnt_start_date,cnt_opened,cnt_closed
,min_start_date,max_start_date,x1,x2,insert_date,int_all_param_key,qry_id,start_year,fl_include_perCapita);
commit;
SET foreign_key_checks=1;

analyze table cache_poc2ab_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc2ab_aggr)
  where tbl_name='cache_poc2ab_aggr';

