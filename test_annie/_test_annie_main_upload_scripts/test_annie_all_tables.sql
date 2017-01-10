USE test_annie;

-- Building outcomes tables
TRUNCATE TABLE cache_outcomes_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_outcomes_params.txt'
INTO TABLE cache_outcomes_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_outcomes_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_outcomes_params
		)
WHERE tbl_name = 'cache_outcomes_params';

TRUNCATE TABLE cache_qry_param_outcomes;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_outcomes.txt'
INTO TABLE cache_qry_param_outcomes fields terminated BY '|' (
		int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,qry_id
		,int_hash_key
		);

analyze TABLE cache_qry_param_outcomes;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_outcomes
		)
WHERE tbl_name = 'cache_qry_param_outcomes';

TRUNCATE TABLE prtl_outcomes;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_outcomes.txt'
INTO TABLE prtl_outcomes fields terminated BY '|' LINES TERMINATED BY '\n' (
		cohort_entry_date
		,date_type
		,qry_type
		,cd_discharge_type
		,age_grouping_cd
		,pk_gndr
		,cd_race_census
		,census_hispanic_latino_origin_cd
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,removal_county_cd
		,int_match_param_key
		,bin_dep_cd
		,max_bin_los_cd
		,bin_placement_cd
		,cd_reporter_type
		,bin_ihs_svc_cd
		,filter_access_type
		,filter_allegation
		,filter_finding
		,mnth
		,discharge_count
		,cohort_count
		);

analyze TABLE prtl_outcomes;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_outcomes
		)
WHERE tbl_name = 'prtl_outcomes';

TRUNCATE TABLE cache_outcomes_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_outcomes_aggr.txt'
INTO TABLE cache_outcomes_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,cohort_entry_date
		,cd_discharge_type
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,mnth
		,rate
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,start_year
		,int_hash_key
		);

analyze TABLE cache_outcomes_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_outcomes_aggr
		)
WHERE tbl_name = 'cache_outcomes_aggr';

-- Building pbcp5 tables
TRUNCATE TABLE cache_qry_param_pbcp5;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcp5.txt'
INTO TABLE cache_qry_param_pbcp5 fields terminated BY '|' (
		int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,qry_id
		,int_hash_key
		);

analyze TABLE cache_qry_param_pbcp5;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_pbcp5
		)
WHERE tbl_name = 'cache_qry_param_pbcp5';

TRUNCATE TABLE cache_pbcp5_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcp5_params.txt'
INTO TABLE cache_pbcp5_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_pbcp5_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcp5_params
		)
WHERE tbl_name = 'cache_pbcp5_params';

TRUNCATE TABLE cache_pbcp5_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcp5_aggr.txt'
INTO TABLE cache_pbcp5_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,cohort_entry_date
		,cd_discharge_type
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,reentry_within_month
		,reentry_rate
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,start_year
		,int_hash_key
		);

analyze TABLE cache_pbcp5_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcp5_aggr
		)
WHERE tbl_name = 'cache_pbcp5_aggr';

TRUNCATE TABLE prtl_pbcp5;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_pbcp5.txt'
INTO TABLE prtl_pbcp5 FIELDS TERMINATED BY '|' (
		cohort_exit_year
		,date_type
		,qry_type
		,cd_discharge_type
		,age_grouping_cd
		,pk_gndr
		,cd_race_census
		,census_hispanic_latino_origin_cd
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,exit_county_cd
		,int_match_param_key
		,bin_dep_cd
		,max_bin_los_cd
		,bin_placement_cd
		,cd_reporter_type
		,bin_ihs_svc_cd
		,filter_access_type
		,filter_allegation
		,filter_finding
		,mnth
		,discharge_count
		,cohort_count
		);

analyze TABLE prtl_pbcp5;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_pbcp5
		)
WHERE tbl_name = 'prtl_pbcp5';

-- Building pbcs2 tables
TRUNCATE TABLE prtl_pbcs2;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_pbcs2.txt'
INTO TABLE prtl_pbcs2 fields terminated BY '|' (
		cohort_begin_date
		,date_type
		,qry_type
		,int_match_param_key
		,cd_sib_age_grp
		,cd_race_census
		,census_hispanic_latino_origin_cd
		,county_cd
		,filter_access_type
		,filter_allegation
		,filter_finding
		,cd_reporter_type
		,bin_ihs_svc_cd
		,initref
		,initfndref
		,cohortrefcount
		,cohortfndrefcount
		,case_founded_recurrence
		,case_repeat_referral
		,cnt_case
		,nxt_ref_within_min_month
		);

analyze TABLE prtl_pbcs2;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_pbcs2
		)
WHERE tbl_name = 'prtl_pbcs2';

TRUNCATE TABLE cache_pbcs2_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs2_params.txt'
INTO TABLE cache_pbcs2_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,cd_county
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_pbcs2_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcs2_params
		)
WHERE tbl_name = 'cache_pbcs2_params';

TRUNCATE TABLE cache_qry_param_pbcs2;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcs2.txt'
INTO TABLE cache_qry_param_pbcs2 fields terminated BY '|' (
		int_param_key
		,cd_sib_age_grp
		,cd_race
		,cd_county
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,qry_id
		,int_hash_key
		);

analyze TABLE cache_qry_param_pbcs2;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_pbcs2
		)
WHERE tbl_name = 'cache_qry_param_pbcs2';

TRUNCATE TABLE cache_pbcs2_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcs2_aggr.txt'
INTO TABLE cache_pbcs2_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,int_param_key
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,cd_sib_age_grp
		,cd_race
		,cd_county
		,month
		,among_first_cmpt_rereferred
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,int_hash_key
		,qry_id
		,start_year
		);

analyze TABLE cache_pbcs2_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcs2_aggr
		)
WHERE tbl_name = 'cache_pbcs2_aggr';

-- Building pbcw3 tables
TRUNCATE TABLE cache_qry_param_pbcw3;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcw3.txt'
INTO TABLE cache_qry_param_pbcw3 fields terminated BY '|' (
		int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,qry_id
		,int_hash_key
		);

analyze TABLE cache_qry_param_pbcw3;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_pbcw3
		)
WHERE tbl_name = 'cache_qry_param_pbcw3';

TRUNCATE TABLE cache_pbcw3_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw3_params.txt'
INTO TABLE cache_pbcw3_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_pbcw3_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcw3_params
		)
WHERE tbl_name = 'cache_pbcw3_params';

TRUNCATE TABLE cache_pbcw3_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw3_aggr.txt'
INTO TABLE cache_pbcw3_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,cohort_entry_date
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,family_setting_dcfs_prcntg
		,family_setting_private_agency_prcntg
		,relative_prcntg
		,group_inst_care_prcntg
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,cohort_begin_year
		,int_hash_key
		);

analyze TABLE cache_pbcw3_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcw3_aggr
		)
WHERE tbl_name = 'cache_pbcw3_aggr';

-- Building pbcw4 tables
TRUNCATE TABLE cache_qry_param_pbcw4;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_pbcw4.txt'
INTO TABLE cache_qry_param_pbcw4 fields terminated BY '|' (
		int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,qry_id
		,int_hash_key
		);

analyze TABLE cache_qry_param_pbcw4;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_pbcw4
		)
WHERE tbl_name = 'cache_qry_param_pbcw4';

TRUNCATE TABLE cache_pbcw4_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw4_params.txt'
INTO TABLE cache_pbcw4_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_pbcw4_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcw4_params
		)
WHERE tbl_name = 'cache_pbcw4_params';

TRUNCATE TABLE cache_pbcw4_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_pbcw4_aggr.txt'
INTO TABLE cache_pbcw4_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,cohort_entry_date
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,kincare
		,bin_sibling_group_size
		,all_together
		,some_together
		,none_together
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,cohort_begin_year
		,int_hash_key
		,cnt_cohort
		);

analyze TABLE cache_pbcw4_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_pbcw4_aggr
		)
WHERE tbl_name = 'cache_pbcw4_aggr';

-- Building poc1ab tables
TRUNCATE TABLE cache_poc1ab_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_params.txt'
INTO TABLE cache_poc1ab_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_poc1ab_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_params
		)
WHERE tbl_name = 'cache_poc1ab_params';

TRUNCATE TABLE cache_qry_param_poc1ab;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab.txt'
INTO TABLE cache_qry_param_poc1ab fields terminated BY '|' (
		qry_id
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,int_hash_key
		);

analyze TABLE cache_qry_param_poc1ab;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_poc1ab
		)
WHERE tbl_name = 'cache_qry_param_poc1ab';

TRUNCATE TABLE cache_poc1ab_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_aggr.txt'
INTO TABLE cache_poc1ab_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,cnt_start_date
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,int_hash_key
		,qry_id
		,start_year
		,fl_include_perCapita
		);

analyze TABLE cache_poc1ab_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_aggr
		)
WHERE tbl_name = 'cache_poc1ab_aggr';

call create_prtl_poc1ab_ram_table;

-- Building entry tables
TRUNCATE TABLE cache_poc1ab_entries_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_entries_params.txt'
INTO TABLE cache_poc1ab_entries_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_poc1ab_entries_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_entries_params
		)
WHERE tbl_name = 'cache_poc1ab_entries_params';

TRUNCATE TABLE cache_qry_param_poc1ab_entries;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab_entries.txt'
INTO TABLE cache_qry_param_poc1ab_entries fields terminated BY '|' (
		qry_id
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,int_hash_key
		);

analyze TABLE cache_qry_param_poc1ab_entries;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_poc1ab_entries
		)
WHERE tbl_name = 'cache_qry_param_poc1ab_entries';

TRUNCATE TABLE prtl_poc1ab_entries;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc1ab_entries.txt'
INTO TABLE prtl_poc1ab_entries fields terminated BY ',' LINES TERMINATED BY '\n' (
		qry_type
		,date_type
		,start_date
		,bin_dep_cd
		,max_bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,age_grouping_cd
		,cd_race
		,census_hispanic_latino_origin_cd
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,int_match_param_key
		,cnt_entries
		,filter_allegation
		,filter_finding
		,filter_access_type
		,start_year
		);

analyze TABLE prtl_poc1ab_entries;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_poc1ab_entries
		)
WHERE tbl_name = 'prtl_poc1ab_entries';

TRUNCATE TABLE cache_poc1ab_entries_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_entries_aggr.txt'
INTO TABLE cache_poc1ab_entries_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,cnt_entries
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,int_hash_key
		,qry_id
		,start_year
		,fl_include_perCapita
		);

analyze TABLE cache_poc1ab_entries_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_entries_aggr
		)
WHERE tbl_name = 'cache_poc1ab_entries_aggr';

-- Building exit tables
TRUNCATE TABLE cache_poc1ab_exits_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_exits_params.txt'
INTO TABLE cache_poc1ab_exits_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,bin_dep_cd
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_poc1ab_exits_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_exits_params
		)
WHERE tbl_name = 'cache_poc1ab_exits_params';

TRUNCATE TABLE cache_qry_param_poc1ab_exits;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc1ab_exits.txt'
INTO TABLE cache_qry_param_poc1ab_exits fields terminated BY '|' (
		qry_id
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,int_hash_key
		);

analyze TABLE cache_qry_param_poc1ab_exits;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_poc1ab_exits
		)
WHERE tbl_name = 'cache_qry_param_poc1ab_exits';

TRUNCATE TABLE prtl_poc1ab_exits;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc1ab_exits.txt'
INTO TABLE prtl_poc1ab_exits fields terminated BY '|' LINES TERMINATED BY '\n' (
		qry_type
		,date_type
		,start_date
		,bin_dep_cd
		,max_bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,age_grouping_cd
		,cd_race
		,census_hispanic_latino_origin_cd
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,int_match_param_key
		,filter_allegation
		,filter_finding
		,filter_access_type
		,start_year
		,cd_discharge_type
		,cnt_exits
		);

analyze TABLE prtl_poc1ab_exits;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_poc1ab_exits
		)
WHERE tbl_name = 'prtl_poc1ab_exits';

TRUNCATE TABLE cache_poc1ab_exits_aggr;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc1ab_exits_aggr.txt'
INTO TABLE cache_poc1ab_exits_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,int_param_key
		,bin_dep_cd
		,bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,age_grouping_cd
		,cd_race
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,qry_id
		,start_year
		,int_hash_key
		,fl_include_perCapita
		,cd_discharge_type
		,cnt_exits
		);

analyze TABLE cache_poc1ab_exits_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc1ab_exits_aggr
		)
WHERE tbl_name = 'cache_poc1ab_exits_aggr';

-- Building poc2ab tables
TRUNCATE TABLE cache_poc2ab_params;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc2ab_params.txt'
INTO TABLE cache_poc2ab_params fields terminated BY '|' (
		qry_ID
		,age_grouping_cd
		,cd_race_census
		,cd_county
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,min_start_date
		,max_start_date
		,cnt_qry
		,last_run_date
		);

analyze TABLE cache_poc2ab_params;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc2ab_params
		)
WHERE tbl_name = 'cache_poc2ab_params';

SET autocommit = 0;
SET foreign_key_checks = 0;

TRUNCATE TABLE cache_qry_param_poc2ab;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_qry_param_poc2ab.txt'
INTO TABLE cache_qry_param_poc2ab fields terminated BY '|' (
		qry_id
		,int_param_key
		,cd_sib_age_grp
		,cd_race
		,cd_county
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,int_all_param_key
		);

COMMIT;

SET foreign_key_checks = 1;

analyze TABLE cache_qry_param_poc2ab;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_qry_param_poc2ab
		)
WHERE tbl_name = 'cache_qry_param_poc2ab';

TRUNCATE TABLE prtl_poc2ab;

LOAD DATA INFILE '/data/pocweb/upload_files/prtl_poc2ab.txt'
INTO TABLE prtl_poc2ab fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,start_year
		,int_match_param_key
		,cd_reporter_type
		,filter_access_type
		,filter_allegation
		,filter_finding
		,cd_sib_age_group
		,cd_race_census
		,census_hispanic_latino_origin_cd
		,county_cd
		,cnt_start_date
		,cnt_opened
		,cnt_closed
		);

analyze TABLE prtl_poc2ab;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM prtl_poc2ab
		)
WHERE tbl_name = 'prtl_poc2ab';

TRUNCATE TABLE cache_poc2ab_aggr;

SET autocommit = 0;
SET foreign_key_checks = 0;

LOAD DATA INFILE '/data/pocweb/upload_files/cache_poc2ab_aggr.txt'
INTO TABLE cache_poc2ab_aggr fields terminated BY '|' (
		qry_type
		,date_type
		,start_date
		,int_param_key
		,cd_reporter_type
		,cd_access_type
		,cd_allegation
		,cd_finding
		,cd_sib_age_grp
		,cd_race
		,cd_county
		,cnt_start_date
		,cnt_opened
		,cnt_closed
		,min_start_date
		,max_start_date
		,x1
		,x2
		,insert_date
		,int_all_param_key
		,qry_id
		,start_year
		);

COMMIT;

SET foreign_key_checks = 1;

analyze TABLE cache_poc2ab_aggr;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM cache_poc2ab_aggr
		)
WHERE tbl_name = 'cache_poc2ab_aggr';

-- Building ref tables
TRUNCATE TABLE ref_match_allegation;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_allegation.txt'
INTO TABLE ref_match_allegation fields terminated BY '|' (
		cd_allegation
		,filter_allegation
		,fl_phys_abuse
		,fl_sexual_abuse
		,fl_neglect
		,fl_any_legal
		);

analyze TABLE ref_match_allegation;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ref_match_allegation
		)
WHERE tbl_name = 'ref_match_allegation';

TRUNCATE TABLE ref_match_finding;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_match_finding.txt'
INTO TABLE ref_match_finding fields terminated BY '|' (
		filter_finding
		,fl_founded_phys_abuse
		,fl_founded_sexual_abuse
		,fl_founded_neglect
		,fl_any_finding_legal
		,cd_finding
		);

analyze TABLE ref_match_finding;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ref_match_finding
		)
WHERE tbl_name = 'ref_match_finding';

-- Building point in time table
TRUNCATE TABLE ooh_point_in_time_measures;

LOAD DATA INFILE '/data/pocweb/upload_files/ooh_point_in_time_measures.txt'
INTO TABLE ooh_point_in_time_measures fields terminated BY ',' LINES TERMINATED BY '\n' (
		qry_type
		,date_type
		,start_date
		,bin_dep_cd
		,max_bin_los_cd
		,bin_placement_cd
		,bin_ihs_svc_cd
		,cd_reporter_type
		,cd_race
		,census_hispanic_latino_origin_cd
		,pk_gndr
		,init_cd_plcm_setng
		,long_cd_plcm_setng
		,county_cd
		,filter_allegation
		,filter_finding
		,filter_access_type
		,age_grouping_cd_mix
		,age_grouping_cd_census
		,int_match_param_key_mix
		,int_match_param_key_census
		,kincare
		,bin_sibling_group_size
		,family_setting_cnt
		,family_setting_DCFS_cnt
		,family_setting_private_agency_cnt
		,relative_care
		,group_inst_care_cnt
		,all_sib_together
		,some_sib_together
		,no_sib_together
		,cnt_child_unique
		,cnt_child
		,fl_w3
		,fl_w4
		,fl_poc1ab
		);

analyze TABLE ooh_point_in_time_measures;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ooh_point_in_time_measures
		)
WHERE tbl_name = 'ooh_point_in_time_measures';

-- Building census tables
TRUNCATE TABLE ref_lookup_census_population;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_census_population.txt'
INTO TABLE ref_lookup_census_population fields terminated BY '|' (
		source_census
		,county_cd
		,pk_gndr
		,cd_race
		,age_grouping_cd
		,measurement_year
		,pop_cnt
		);

analyze TABLE ref_lookup_census_population;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ref_lookup_census_population
		)
WHERE tbl_name = 'ref_lookup_census_population';

TRUNCATE TABLE ref_lookup_census_population_poc2;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_census_population_poc2.txt'
INTO TABLE ref_lookup_census_population_poc2 fields terminated BY '|' (
		source_census
		,county_cd
		,cd_race
		,cd_sib_age_grp
		,measurement_year
		,pop_cnt
		);

analyze TABLE ref_lookup_census_population_poc2;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ref_lookup_census_population_poc2
		)
WHERE tbl_name = 'ref_lookup_census_population_poc2';

-- Building max date tables
DROP TABLE

IF EXISTS bkp_ref_lookup_max_date;
	CREATE TABLE bkp_ref_lookup_max_date AS

SELECT *
FROM ref_lookup_max_date;

TRUNCATE TABLE ref_lookup_max_date;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_max_date.txt'
INTO TABLE ref_lookup_max_date fields terminated BY '|' (
		id
		,PROCEDURE_NAME
		,max_date_all
		,max_date_any
		,max_date_qtr
		,max_date_yr
		,min_date_any
		,is_current
		);

analyze TABLE ref_lookup_max_date;

UPDATE prtl_tables_last_update
SET load_date = now()
	,row_count = (
		SELECT count(*)
		FROM ref_lookup_max_date
		)
WHERE tbl_name = 'ref_lookup_max_date';

-- Building last data transfer tables
TRUNCATE TABLE ref_last_dw_transfer;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_last_dw_transfer.txt'
INTO TABLE ref_last_dw_transfer fields terminated BY '|' (cutoff_date);

analyze TABLE ref_last_dw_transfer;
 