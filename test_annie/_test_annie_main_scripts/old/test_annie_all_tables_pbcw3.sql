use test_annie;


truncate table test_annie.prtl_pbcw3;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcw3.txt'
into table prtl_pbcw3
fields terminated by '|'
(cohort_begin_date, date_type, qry_type, age_grouping_cd, pk_gndr, cd_race_census, 
census_hispanic_latino_origin_cd, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, int_match_param_key, bin_dep_cd
, max_bin_los_cd, 
bin_placement_cd, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding,
filter_service_category, filter_service_budget,  family_setting_cnt, family_setting_DCFS_cnt
, family_setting_private_agency_cnt, relative_care, group_inst_care_cnt, 
total);

analyze table prtl_pbcw3;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcw3)
  where tbl_name='prtl_pbcw3';

truncate table test_annie.cache_qry_param_pbcw3;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_pbcw3.txt'
into table cache_qry_param_pbcw3
fields terminated by '|'
(int_param_key, bin_dep_cd,bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation, cd_finding, cd_subctgry_poc_frc, 
cd_budget_poc_frc, age_grouping_cd, cd_race, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, qry_id, int_hash_key);

analyze table cache_qry_param_pbcw3;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcw3)
  where tbl_name='cache_qry_param_pbcw3';

truncate table test_annie.cache_pbcw3_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw3_params.txt'
into table cache_pbcw3_params
fields terminated by '|'
( qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
 cd_reporter_type, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, filter_budget,bin_dep_cd, min_start_date, 
 max_start_date, cnt_qry,last_run_date);

analyze table cache_pbcw3_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw3_params)
  where tbl_name='cache_pbcw3_params';

truncate table test_annie.cache_pbcw3_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_pbcw3_aggr.txt'
into table cache_pbcw3_aggr
fields terminated by '|'
(qry_type, date_type, cohort_entry_date, int_param_key, bin_dep_cd, bin_los_cd, bin_placement_cd, 
bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation, cd_finding, cd_subctgry_poc_frc, cd_budget_poc_frc
, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd, family_setting_dcfs_prcntg, family_setting_private_agency_prcntg
, relative_prcntg, group_inst_care_prcntg, 
min_start_date,  max_start_date, x1, x2, insert_date, qry_id, cohort_begin_year, int_hash_key);

analyze table cache_pbcw3_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw3_aggr)
  where tbl_name='cache_pbcw3_aggr';


