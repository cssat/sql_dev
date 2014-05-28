use test_annie;



truncate table test_annie.cache_pbcw4_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw4_params.txt'
into table cache_pbcw4_params
fields terminated by '|'
( qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
 cd_reporter_type, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, filter_budget, bin_dep_cd, min_start_date, 
 max_start_date, cnt_qry,last_run_date);

analyze table cache_pbcw4_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw4_params)
  where tbl_name='cache_pbcw4_params';
