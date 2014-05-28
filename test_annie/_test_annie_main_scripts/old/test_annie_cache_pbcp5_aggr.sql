use test_annie;


truncate table test_annie.cache_pbcp5_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcp5_aggr.txt'
into table cache_pbcp5_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,cd_discharge_type,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_access_type,cd_allegation,cd_finding,cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd
,reentry_within_month,reentry_rate
,min_start_date,max_start_date,x1,x2,insert_date,qry_id,start_year,int_hash_key);

analyze table cache_pbcp5_aggr;

select 'cache_pbcp5_aggr' as filename ,count(*) from cache_pbcp5_aggr;


