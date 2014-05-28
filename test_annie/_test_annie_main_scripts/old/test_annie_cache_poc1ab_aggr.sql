use test_annie;


 
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


select count(*) as cnt,max(qry_id) as qry_id from cache_poc1ab_aggr;
analyze table cache_poc1ab_aggr;

call create_prtl_poc1ab_ram_table;

