use test_annie;
truncate table cache_pbcs3_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs3_params.txt'
into table cache_pbcs3_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_office, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, 
                         filter_budget, min_start_date, max_start_date, cnt_qry, last_run_date);
						 
select 'cache_pbcs3_params' as tbl_name,count(*) as cnt,max(qry_id) as qry_id from cache_pbcs3_params;

 truncate table cache_qry_param_pbcs3;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcs3.txt'
 into table cache_qry_param_pbcs3
 fields terminated by '|'
 (int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,cd_office,qry_id,int_hash_key);
 
 
 select 'cache_qry_param_pbcs3' as tbl_name,count(*) as cnt,max(qry_id) as qry_id from cache_qry_param_pbcs3;
 
truncate table cache_pbcs3_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcs3_aggr.txt'
into table cache_pbcs3_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,
cd_allegation,cd_finding,cd_service_type,cd_budget_type,cd_sib_age_grp,cd_race_census,
cd_office_collapse,month,placed,not_placed,min_start_date,max_start_date,x1,x2,
insert_date,qry_id,start_year,int_hash_key);



select min(start_date) as Min_Date,max(start_date) as max_Date,count(*) as cnt,max(qry_id) qry_id ,sum(placed)  from cache_pbcs3_aggr;
