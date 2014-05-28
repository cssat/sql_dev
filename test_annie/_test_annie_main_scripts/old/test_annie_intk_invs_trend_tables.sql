use test_annie;
truncate table cache_poc2ab_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc2ab_params.txt'
into table cache_poc2ab_params
fields terminated by '|'
(qry_ID,age_grouping_cd,cd_race_census,cd_office,cd_reporter_type,filter_access_type
,filter_allegation,filter_finding,min_start_date,max_start_date,cnt_qry,last_run_date);

 truncate table cache_qry_param_poc2ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_poc2ab.txt'
 into table cache_qry_param_poc2ab
 fields terminated by '|'
 (qry_id,param_value,param_name ,param_pos);
 
truncate table cache_poc2ab_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc2ab_aggr.txt'
into table cache_poc2ab_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,cd_reporter_type,cd_access_type,cd_allegation
,cd_finding,cd_sib_age_grp,cd_race,cd_office,cnt_start_date,cnt_opened,cnt_closed
,min_start_date,max_start_date,x1,x2,insert_date,int_all_param_key,qry_id,start_year);




truncate table prtl_poc2ab;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_poc2ab.txt'
into table prtl_poc2ab
fields terminated by '|'
(qry_type,date_type,start_date,start_year,int_match_param_key,cd_reporter_type,fl_cps_invs,filter_access_type,filter_allegation,filter_finding
,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_found_any_legal
,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,cd_office,cnt_start_date,cnt_opened,cnt_closed);


analyze table cache_poc2ab_params;
analyze table cache_qry_param_poc2ab;
analyze table cache_poc2ab_aggr;
analyze table prtl_poc2ab;


select count(*) as cnt,max(qry_id) as qry_id from cache_poc2ab_params;
select min(start_date) as Min_Date,max(start_date) as max_Date,count(*) as cnt,max(qry_id) as qry_id from cache_poc2ab_aggr;
select count(*) as cnt,max(qry_id) as qry_id from cache_qry_param_poc2ab;
select count(*) as cnt from prtl_poc2ab;