use review_annie;

truncate table cache_outcomes_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_outcomes_params.txt'
into table cache_outcomes_params
fields terminated by '|'
(qry_ID, age_grouping_cd, cd_race_census, pk_gndr
, init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd 
 ,cd_reporter_type, filter_access_type, filter_allegation
 ,filter_finding, bin_dep_cd
 ,min_start_date, max_start_date, cnt_qry, last_run_date);

  analyze table cache_outcomes_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_outcomes_params)
  where tbl_name='cache_outcomes_params';


 truncate table cache_qry_param_outcomes;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_outcomes.txt'
 into table cache_qry_param_outcomes
 fields terminated by '|'
 (int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd
 ,cd_reporter_type,cd_access_type,cd_allegation,cd_finding
 ,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng
 ,long_cd_plcm_setng,county_cd,qry_id,int_hash_key);
 
 analyze table cache_qry_param_outcomes;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_outcomes)
  where tbl_name='cache_qry_param_outcomes';
 
 truncate table prtl_outcomes;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_outcomes.txt'
into table prtl_outcomes
fields terminated by '|'
LINES TERMINATED BY '\n' 
(cohort_entry_date,date_type,qry_type,cd_discharge_type,age_grouping_cd,pk_gndr,cd_race_census,census_hispanic_latino_origin_cd
,init_cd_plcm_setng,long_cd_plcm_setng
,removal_county_cd,int_match_param_key,bin_dep_cd,max_bin_los_cd
,bin_placement_cd,cd_reporter_type,bin_ihs_svc_cd
,filter_access_type,filter_allegation,filter_finding,
mnth,discharge_count,cohort_count);


analyze table prtl_outcomes;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_outcomes)
  where tbl_name='prtl_outcomes';

 
truncate table cache_outcomes_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_outcomes_aggr.txt'
into table cache_outcomes_aggr
fields terminated by '|'
(qry_type, date_type,cohort_entry_date, cd_discharge_type
, int_param_key, bin_dep_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
cd_reporter_type, cd_access_type, cd_allegation
, cd_finding, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, mnth,rate, min_start_date, 
max_start_date, x1, x2, insert_date
,qry_id,start_year,int_hash_key);

analyze table cache_outcomes_aggr;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_outcomes_aggr)
  where tbl_name='cache_outcomes_aggr';







truncate table cache_qry_param_pbcp5;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcp5.txt'
into table cache_qry_param_pbcp5
fields terminated by '|'
(int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type
 ,cd_allegation,cd_finding,age_grouping_cd,cd_race
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,qry_id,int_hash_key);

analyze table cache_qry_param_pbcp5;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcp5)
  where tbl_name='cache_qry_param_pbcp5';

truncate table cache_pbcp5_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcp5_params.txt'
into table cache_pbcp5_params
fields terminated by '|'
( qry_ID ,age_grouping_cd,cd_race_census,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd
      ,bin_los_cd ,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,filter_access_type,filter_allegation
      ,filter_finding,bin_dep_cd,min_start_date,max_start_date,cnt_qry,last_run_date);

analyze table cache_pbcp5_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcp5_params)
  where tbl_name='cache_pbcp5_params';

truncate table cache_pbcp5_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcp5_aggr.txt'
into table cache_pbcp5_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,cd_discharge_type,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_access_type,cd_allegation,cd_finding,age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd
,reentry_within_month,reentry_rate
,min_start_date,max_start_date,x1,x2,insert_date,qry_id,start_year,int_hash_key);

analyze table cache_pbcp5_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcp5_aggr)
  where tbl_name='cache_pbcp5_aggr';

truncate table prtl_pbcp5;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_pbcp5.txt'
into table prtl_pbcp5
FIELDS TERMINATED by '|'
(cohort_exit_year,date_type,qry_type,cd_discharge_type,age_grouping_cd,
pk_gndr,cd_race_census,census_hispanic_latino_origin_cd
,init_cd_plcm_setng,long_cd_plcm_setng,exit_county_cd,int_match_param_key,bin_dep_cd
,max_bin_los_cd,bin_placement_cd,cd_reporter_type
,bin_ihs_svc_cd,filter_access_type,filter_allegation,filter_finding,mnth
,discharge_count
,cohort_count);
analyze table prtl_pbcp5;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcp5)
  where tbl_name='prtl_pbcp5';






truncate table prtl_pbcs2;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_pbcs2.txt'
into table prtl_pbcs2
fields terminated by '|'
(cohort_begin_date,date_type,qry_type,int_match_param_key,cd_sib_age_grp
,cd_race_census,census_hispanic_latino_origin_cd,county_cd
,filter_access_type,filter_allegation,
filter_finding,cd_reporter_type,bin_ihs_svc_cd,initref,initfndref
,cohortrefcount,cohortfndrefcount,case_founded_recurrence,
case_repeat_referral,cnt_case,nxt_ref_within_min_month);


analyze table prtl_pbcs2;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcs2)
  where tbl_name='prtl_pbcs2';


truncate table cache_pbcs2_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs2_params.txt'
into table cache_pbcs2_params
fields terminated by '|'
(qry_ID,age_grouping_cd,cd_race_census,cd_county,cd_reporter_type,filter_access_type
,filter_allegation,filter_finding,min_start_date,max_start_date,cnt_qry,last_run_date);


analyze table  cache_pbcs2_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs2_params)
  where tbl_name='cache_pbcs2_params';

 truncate table cache_qry_param_pbcs2;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcs2.txt'
 into table cache_qry_param_pbcs2
 fields terminated by '|'
 (int_param_key,cd_sib_age_grp,cd_race,cd_county,cd_reporter_type,cd_access_type,cd_allegation,
cd_finding,qry_id,int_hash_key);
 
analyze table  cache_qry_param_pbcs2;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcs2)
  where tbl_name='cache_qry_param_pbcs2';
  
truncate table cache_pbcs2_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs2_aggr.txt'
into table cache_pbcs2_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,cd_reporter_type,cd_access_type,cd_allegation,
cd_finding,cd_sib_age_grp,cd_race,cd_county,month,among_first_cmpt_rereferred,
min_start_date,max_start_date,x1,x2,insert_date,int_hash_key,qry_id,start_year);



analyze table cache_pbcs2_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs2_aggr)
  where tbl_name='cache_pbcs2_aggr';
 




/*
truncate table cache_pbcs3_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs3_params.txt'
into table cache_pbcs3_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_county, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, 
                         min_start_date, max_start_date, cnt_qry, last_run_date);
						 
analyze table cache_pbcs3_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs3_params)
  where tbl_name='cache_pbcs3_params';
  
  
 truncate table cache_qry_param_pbcs3;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcs3.txt'
 into table cache_qry_param_pbcs3
 fields terminated by '|'
 (int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding
 ,age_grouping_cd,cd_race,cd_county,qry_id,int_hash_key);
 
 
 analyze table cache_qry_param_pbcs3;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcs3)
  where tbl_name='cache_qry_param_pbcs3';
  
  
truncate table prtl_pbcs3;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_pbcs3.txt'
into table prtl_pbcs3
fields terminated by '|'
(cohort_begin_date,date_type,qry_type,cd_race_census,census_hispanic_latino_origin_cd,
county_cd,cd_sib_age_grp,int_match_param_key,cd_reporter_type,bin_ihs_svc_cd,
filter_access_type,filter_allegation,filter_finding,min_placed_within_month,cnt_case);

 analyze table prtl_pbcs3;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_pbcs3)
  where tbl_name='prtl_pbcs3';
  
  
truncate table cache_pbcs3_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs3_aggr.txt'
into table cache_pbcs3_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,
cd_allegation,cd_finding,cd_sib_age_grp,cd_race_census,
cd_county,month,placed,not_placed,min_start_date,max_start_date,x1,x2,
insert_date,qry_id,start_year,int_hash_key);

 analyze table cache_pbcs3_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcs3_aggr)
  where tbl_name='cache_pbcs3_aggr';
*/








truncate table cache_qry_param_pbcw3;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcw3.txt'
into table cache_qry_param_pbcw3
fields terminated by '|'
(int_param_key, bin_dep_cd,bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation, cd_finding, 
age_grouping_cd, cd_race, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, qry_id, int_hash_key);

analyze table cache_qry_param_pbcw3;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcw3)
  where tbl_name='cache_qry_param_pbcw3';

truncate table cache_pbcw3_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw3_params.txt'
into table cache_pbcw3_params
fields terminated by '|'
( qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
 cd_reporter_type, filter_access_type, filter_allegation, filter_finding, bin_dep_cd, min_start_date, max_start_date, cnt_qry,last_run_date);

analyze table cache_pbcw3_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw3_params)
  where tbl_name='cache_pbcw3_params';

truncate table cache_pbcw3_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw3_aggr.txt'
into table cache_pbcw3_aggr
fields terminated by '|'
(qry_type, date_type, cohort_entry_date, int_param_key, bin_dep_cd, bin_los_cd, bin_placement_cd, 
bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation, cd_finding, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd, family_setting_dcfs_prcntg, family_setting_private_agency_prcntg
, relative_prcntg, group_inst_care_prcntg, 
min_start_date,  max_start_date, x1, x2, insert_date, qry_id, cohort_begin_year, int_hash_key);

analyze table cache_pbcw3_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw3_aggr)
  where tbl_name='cache_pbcw3_aggr';









truncate table cache_qry_param_pbcw4;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcw4.txt'
into table cache_qry_param_pbcw4
fields terminated by '|'
(int_param_key, bin_dep_cd,bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, cd_reporter_type
, cd_access_type, cd_allegation, cd_finding, age_grouping_cd, cd_race, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng
, county_cd, qry_id, int_hash_key);

analyze table cache_qry_param_pbcw4;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_pbcw4)
  where tbl_name='cache_qry_param_pbcw4';

truncate table cache_pbcw4_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw4_params.txt'
into table cache_pbcw4_params
fields terminated by '|'
( qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
 cd_reporter_type, filter_access_type, filter_allegation, filter_finding, bin_dep_cd, min_start_date, max_start_date, cnt_qry,last_run_date);

analyze table cache_pbcw4_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw4_params)
  where tbl_name='cache_pbcw4_params';


truncate table cache_pbcw4_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw4_aggr.txt'
into table cache_pbcw4_aggr
fields terminated by '|'
(qry_type,date_type,cohort_entry_date,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,kincare,bin_sibling_group_size,all_together,
some_together,none_together,min_start_date,max_start_date,x1,x2,insert_date,qry_id,cohort_begin_year,int_hash_key,cnt_cohort);

analyze table cache_pbcw4_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_pbcw4_aggr)
  where tbl_name='cache_pbcw4_aggr';






truncate table cache_poc1ab_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_params.txt'
into table cache_poc1ab_params
fields terminated by '|'
(qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd 
 ,cd_reporter_type, filter_access_type, filter_allegation
 , filter_finding, bin_dep_cd
 ,min_start_date, max_start_date, cnt_qry, last_run_date);

  analyze table cache_poc1ab_params;
  
  
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_params)
  where tbl_name='cache_poc1ab_params';



 truncate table cache_qry_param_poc1ab;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab.txt'
 into table cache_qry_param_poc1ab
 fields terminated by '|'
 (qry_id,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd
 ,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
 age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,int_hash_key);
 
 analyze table cache_qry_param_poc1ab;

 
   update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc1ab)
  where tbl_name='cache_qry_param_poc1ab';
 

 
truncate table cache_poc1ab_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_aggr.txt'
into table cache_poc1ab_aggr
fields terminated by '|'
(qry_type, date_type,start_date, int_param_key, bin_dep_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
cd_reporter_type, cd_access_type, cd_allegation
, cd_finding, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, cnt_start_date, min_start_date, 
max_start_date, x1, x2, insert_date,int_hash_key,qry_id,start_year,fl_include_perCapita);


analyze table cache_poc1ab_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_aggr)
  where tbl_name='cache_poc1ab_aggr';
  
call create_prtl_poc1ab_ram_table;






truncate table cache_poc1ab_entries_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_entries_params.txt'
into table cache_poc1ab_entries_params
fields terminated by '|'
(qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, cd_reporter_type, filter_access_type, filter_allegation
 , filter_finding, bin_dep_cd, min_start_date, max_start_date, cnt_qry, last_run_date);

  analyze table cache_poc1ab_entries_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_entries_params)
  where tbl_name='cache_poc1ab_entries_params';


 truncate table cache_qry_param_poc1ab_entries;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab_entries.txt'
 into table cache_qry_param_poc1ab_entries
 fields terminated by '|'
 (qry_id,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd
 ,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
 age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,int_hash_key);
 
 analyze table cache_qry_param_poc1ab_entries;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc1ab_entries)
  where tbl_name='cache_qry_param_poc1ab_entries';
 
 truncate table prtl_poc1ab_entries;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc1ab_entries.txt'
into table prtl_poc1ab_entries
fields terminated by ','
LINES TERMINATED BY '\n' 
(qry_type,date_type,start_date,bin_dep_cd,max_bin_los_cd
,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,age_grouping_cd,cd_race,census_hispanic_latino_origin_cd
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd,int_match_param_key,cnt_entries
,filter_allegation,filter_finding,
filter_access_type,start_year);


analyze table prtl_poc1ab_entries;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc1ab_entries)
  where tbl_name='prtl_poc1ab_entries';

 
truncate table cache_poc1ab_entries_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_entries_aggr.txt'
into table cache_poc1ab_entries_aggr
fields terminated by '|'
(qry_type, date_type,start_date, int_param_key, bin_dep_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
cd_reporter_type, cd_access_type, cd_allegation
, cd_finding, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, cnt_entries, min_start_date, 
max_start_date, x1, x2, insert_date,int_hash_key,qry_id,start_year,fl_include_perCapita);

analyze table cache_poc1ab_entries_aggr;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_entries_aggr)
  where tbl_name='cache_poc1ab_entries_aggr';






truncate table cache_poc1ab_exits_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_exits_params.txt'
into table cache_poc1ab_exits_params
fields terminated by '|'
(qry_ID, age_grouping_cd, cd_race_census, pk_gndr, init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd 
 ,cd_reporter_type, filter_access_type, filter_allegation
 , filter_finding, bin_dep_cd
 ,min_start_date, max_start_date, cnt_qry, last_run_date);

  analyze table cache_poc1ab_exits_params;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_exits_params)
  where tbl_name='cache_poc1ab_exits_params';


 truncate table cache_qry_param_poc1ab_exits;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab_exits.txt'
 into table cache_qry_param_poc1ab_exits
 fields terminated by '|'
 (qry_id,int_param_key,bin_dep_cd,bin_los_cd,bin_placement_cd,bin_ihs_svc_cd
 ,cd_reporter_type,cd_access_type,cd_allegation,cd_finding,
 age_grouping_cd,cd_race,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng,county_cd,int_hash_key);
 
 analyze table cache_qry_param_poc1ab_exits;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc1ab_exits)
  where tbl_name='cache_qry_param_poc1ab_exits';
 
 truncate table prtl_poc1ab_exits;
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc1ab_exits.txt'
into table prtl_poc1ab_exits
fields terminated by '|'
LINES TERMINATED BY '\n' 
(qry_type,date_type,start_date,bin_dep_cd,max_bin_los_cd
,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,age_grouping_cd,cd_race,census_hispanic_latino_origin_cd
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd,int_match_param_key
,filter_allegation,filter_finding,
filter_access_type,start_year,cd_discharge_type,cnt_exits);


analyze table prtl_poc1ab_exits;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc1ab_exits)
  where tbl_name='prtl_poc1ab_exits';

 
truncate table cache_poc1ab_exits_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_exits_aggr.txt'
into table cache_poc1ab_exits_aggr
fields terminated by '|'
(qry_type, date_type,start_date, int_param_key, bin_dep_cd
, bin_los_cd, bin_placement_cd, bin_ihs_svc_cd, 
cd_reporter_type, cd_access_type, cd_allegation
, cd_finding, age_grouping_cd, cd_race, pk_gndr, 
init_cd_plcm_setng, long_cd_plcm_setng, county_cd
, min_start_date, 
max_start_date, x1, x2, insert_date,qry_id,start_year
,int_hash_key,fl_include_perCapita,cd_discharge_type,cnt_exits);

analyze table cache_poc1ab_exits_aggr;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc1ab_exits_aggr)
  where tbl_name='cache_poc1ab_exits_aggr';









truncate table cache_poc2ab_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc2ab_params.txt'
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
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc2ab.txt'
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
LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc2ab.txt'
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
 
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc2ab_aggr.txt'
into table cache_poc2ab_aggr
fields terminated by '|'
(qry_type,date_type,start_date,int_param_key,cd_reporter_type,cd_access_type,cd_allegation
,cd_finding,cd_sib_age_grp,cd_race,cd_county,cnt_start_date,cnt_opened,cnt_closed
,min_start_date,max_start_date,x1,x2,insert_date,int_all_param_key,qry_id,start_year);
commit;
SET foreign_key_checks=1;

analyze table cache_poc2ab_aggr;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc2ab_aggr)
  where tbl_name='cache_poc2ab_aggr';






/*
truncate table cache_poc3ab_params;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc3ab_params.txt'
into table cache_poc3ab_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_county, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, 
                         min_start_date, max_start_date, cnt_qry, last_run_date);
						 

analyze table cache_poc3ab_params;
update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc3ab_params)
  where tbl_name='cache_poc3ab_params';

 truncate table cache_qry_param_poc3ab;
 LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc3ab.txt'
 into table cache_qry_param_poc3ab
 fields terminated by '|'
 (int_param_key,bin_ihs_svc_cd,cd_reporter_type,cd_access_type,cd_allegation,cd_finding
 ,cd_sib_age_grp,cd_race,cd_county,qry_id,int_hash_key);
 
 analyze table cache_qry_param_poc3ab;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_qry_param_poc3ab)
  where tbl_name='cache_qry_param_poc3ab';
  
truncate table prtl_poc3ab;
 LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc3ab.txt'
 into table prtl_poc3ab
 fields terminated by '|'
 (qry_type,date_type,start_date,start_year,int_match_param_key,
 bin_ihs_svc_cd,cd_reporter_type,filter_access_type,filter_allegation,
 filter_finding,cd_sib_age_group,cd_race_census,census_hispanic_latino_origin_cd,
 county_cd,cnt_start_date,cnt_opened,cnt_closed);
 analyze table prtl_poc3ab;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from prtl_poc3ab)
  where tbl_name='prtl_poc3ab';

 
truncate table cache_poc3ab_aggr;
LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc3ab_aggr.txt'
into table cache_poc3ab_aggr
fields terminated by '|'
( qry_type, date_type,  start_date, int_param_key, bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation
 ,cd_finding, cd_sib_age_grp, cd_race_census, cd_county, cnt_start_date, cnt_opened, cnt_closed,min_start_date,  max_start_date, x1, x2, insert_date
, qry_id, start_year,int_hash_key);



analyze table cache_poc3ab_aggr;
 update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from cache_poc3ab_aggr)
  where tbl_name='cache_poc3ab_aggr';
  
  
  
  
  

truncate table ref_match_srvc_type_category;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_srvc_type_category.txt'
into table ref_match_srvc_type_category
fields terminated by '|'
(filter_srvc_type,fl_family_focused_services,fl_child_care,fl_therapeutic_services,fl_mh_services ,fl_receiving_care,fl_family_home_placements ,fl_behavioral_rehabiliation_services
,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services,fl_respite,fl_transportation,fl_clothing_incidentals ,fl_sexually_aggressive_youth
,fl_adoption_support,fl_various,fl_medical,cd_subctgry_poc_fr);
analyze table ref_match_srvc_type_category;

  
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_srvc_type_category)
  where tbl_name='ref_match_srvc_type_category';

truncate table ref_match_srvc_type_budget;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_srvc_type_budget.txt'
into table ref_match_srvc_type_budget
fields terminated by '|'
(filter_service_budget,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,cd_budget_poc_frc);
analyze table ref_match_srvc_type_budget;


  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_srvc_type_budget)
  where tbl_name='ref_match_srvc_type_budget';
*/
truncate table ref_match_allegation;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_allegation.txt'
into table ref_match_allegation
fields terminated by '|'
(cd_allegation,filter_allegation,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal);
analyze table ref_match_allegation;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_allegation)
  where tbl_name='ref_match_allegation';

truncate table ref_match_finding;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_finding.txt'
into table ref_match_finding
fields terminated by '|'
(filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_any_finding_legal,cd_finding);
analyze table ref_match_finding;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_finding)
  where tbl_name='ref_match_finding';
  
  
  
  
  
  

truncate table ooh_point_in_time_measures;
LOAD DATA INFILE '/data/pocweb/upload_files/ooh_point_in_time_measures.txt'
into table ooh_point_in_time_measures
fields terminated by ','
LINES TERMINATED BY '\n' 
(qry_type,date_type,start_date,bin_dep_cd,max_bin_los_cd
,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_race,census_hispanic_latino_origin_cd
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd,filter_allegation,filter_finding,
filter_access_type,age_grouping_cd_mix,age_grouping_cd_census,int_match_param_key_mix,int_match_param_key_census,kincare,bin_sibling_group_size,family_setting_cnt,
family_setting_DCFS_cnt,family_setting_private_agency_cnt,relative_care,group_inst_care_cnt,all_sib_together,some_sib_together,no_sib_together,cnt_child_unique,cnt_child,fl_w3,fl_w4,fl_poc1ab);


analyze table ooh_point_in_time_measures;

   update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ooh_point_in_time_measures)
  where tbl_name='ooh_point_in_time_measures';
  





truncate table ref_lookup_census_population;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_census_population.txt'
into table ref_lookup_census_population
fields terminated by '|'
(source_census,county_cd,pk_gndr,cd_race,age_grouping_cd,measurement_year,pop_cnt);

analyze table ref_lookup_census_population;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_lookup_census_population)
  where tbl_name='ref_lookup_census_population';






truncate table ref_lookup_census_population_poc2;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_census_population_poc2.txt'
into table ref_lookup_census_population_poc2
fields terminated by '|'
(source_census,county_cd,cd_race,cd_sib_age_grp,measurement_year,pop_cnt);

analyze table ref_lookup_census_population_poc2;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_lookup_census_population_poc2)
  where tbl_name='ref_lookup_census_population_poc2';






drop table if exists bkp_ref_lookup_max_date ;
create table bkp_ref_lookup_max_date as select * from ref_lookup_max_date;

truncate table ref_lookup_max_date;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_max_date.txt'
into table ref_lookup_max_date
fields terminated by '|'
(id,procedure_name,max_date_all,max_date_any,max_date_qtr,max_date_yr,min_date_any,is_current);

analyze table ref_lookup_max_date;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_lookup_max_date)
  where tbl_name='ref_lookup_max_date';
  





truncate table ref_last_dw_transfer;
LOAD DATA INFILE '/data/pocweb/upload_files/ref_last_dw_transfer.txt'
into table ref_last_dw_transfer
fields terminated by '|'
(cutoff_date);

analyze table ref_last_dw_transfer;
  