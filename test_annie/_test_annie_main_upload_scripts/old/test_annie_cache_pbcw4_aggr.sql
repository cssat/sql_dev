use test_annie;



truncate table test_annie.cache_pbcw4_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw4_aggr.txt'
into table cache_pbcw4_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
cd_subctgry_poc_frc,cd_budget_poc_frc,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,kincare,bin_sibling_group_size,all_together,
some_together,none_together,min_start_date,max_start_date,x1,x2,insert_date,qry_id,cohort_begin_year,int_hash_key,cnt_cohort);

analyze table cache_pbcw4_aggr;

select 'cache_pbcw4_aggr' as filename ,count(*) as cnt,sum(all_together) as all_together from cache_pbcw4_aggr;


