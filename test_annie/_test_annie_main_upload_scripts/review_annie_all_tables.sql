USE review_annie;

DROP TABLE

IF EXISTS `prtl_tables_last_update`;
	CREATE TABLE `prtl_tables_last_update` (
		`tbl_id` INT (11) DEFAULT NULL
		,`tbl_name` VARCHAR(100) NOT NULL DEFAULT ''
		,`load_Date` DATETIME DEFAULT NULL
		,`row_count` INT (11) DEFAULT NULL
		,PRIMARY KEY (`tbl_name`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

-- Building outcomes tables
DROP TABLE

IF EXISTS cache_outcomes_params;
	CREATE TABLE `cache_outcomes_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) NOT NULL
		,`cd_race_census` VARCHAR(30) NOT NULL
		,`pk_gndr` VARCHAR(10) NOT NULL
		,`init_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`long_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`county_cd` VARCHAR(200) NOT NULL
		,`bin_los_cd` VARCHAR(30) NOT NULL
		,`bin_placement_cd` VARCHAR(30) NOT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) NOT NULL
		,`cd_reporter_type` VARCHAR(100) NOT NULL
		,`filter_access_type` VARCHAR(30) NOT NULL
		,`filter_allegation` VARCHAR(30) NOT NULL
		,`filter_finding` VARCHAR(30) NOT NULL
		,`bin_dep_cd` VARCHAR(20) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`cnt_qry` INT (11) NOT NULL
		,`last_run_date` DATETIME NOT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `age_grouping_cd`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_dep_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_outcomes;
	CREATE TABLE `cache_qry_param_outcomes` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		,KEY `qry_id`(`qry_id`)
		,KEY `int_param_key`(`int_param_key`)
		,KEY `idx_primary`(`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS prtl_outcomes;
	CREATE TABLE `prtl_outcomes` (
		`cohort_entry_date` DATETIME NOT NULL
		,`date_type` INT (11) NOT NULL
		,`qry_type` INT (11) NOT NULL
		,`cd_discharge_type` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) DEFAULT NULL
		,`pk_gndr` INT (11) DEFAULT NULL
		,`cd_race_census` INT (11) DEFAULT NULL
		,`census_Hispanic_Latino_Origin_cd` INT (11) DEFAULT NULL
		,`init_cd_plcm_setng` INT (11) DEFAULT NULL
		,`long_cd_plcm_setng` INT (11) DEFAULT NULL
		,`removal_county_cd` INT (11) DEFAULT NULL
		,`int_match_param_key` DECIMAL(9, 0) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`max_bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`filter_access_type` INT (11) NOT NULL
		,`filter_allegation` INT (11) NOT NULL
		,`filter_finding` INT (11) NOT NULL
		,`mnth` INT (11) NOT NULL
		,`discharge_count` INT (11) NOT NULL
		,`cohort_count` INT (11) NOT NULL
		,PRIMARY KEY (
			`cohort_entry_date`
			,`date_type`
			,`qry_type`
			,`cd_discharge_type`
			,`int_match_param_key`
			,`bin_dep_cd`
			,`max_bin_los_cd`
			,`bin_placement_cd`
			,`cd_reporter_type`
			,`bin_ihs_svc_cd`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			,`mnth`
			)
		,KEY `idx_int_match_param_key_eth`(`int_match_param_key`)
		,KEY `idx_allegation`(`filter_allegation`)
		,KEY `idx_145`(`cd_reporter_type`)
		,KEY `idx_acc`(`filter_access_type`)
		,KEY `idx_alg`(`filter_allegation`)
		,KEY `idx_los`(`max_bin_los_cd`)
		,KEY `idx_plc`(`bin_placement_cd`)
		,KEY `idx_outcomes_param_los`(`max_bin_los_cd`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_outcomes_aggr;
	CREATE TABLE `cache_outcomes_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`cohort_entry_date` DATETIME NOT NULL
		,`cd_discharge_type` INT (11) NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`mnth` INT (11) NOT NULL
		,`rate` DECIMAL(9, 2) DEFAULT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL DEFAULT '0'
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`cohort_entry_date`
			,`cd_discharge_type`
			,`mnth`
			)
		,KEY `idx_hashkey_qry_id`(`int_hash_key`, `qry_id`)
		,KEY `idx_qry_id`(`qry_id`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_qry_param_pbcp5;
	CREATE TABLE `cache_qry_param_pbcp5` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		,KEY `qry_id`(`qry_id`)
		,KEY `int_param_key`(`int_param_key`)
		,KEY `idx_primary`(`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcp5_params;
	CREATE TABLE `cache_pbcp5_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) DEFAULT NULL
		,`cd_race_census` VARCHAR(30) DEFAULT NULL
		,`pk_gndr` VARCHAR(10) DEFAULT NULL
		,`init_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`long_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`county_cd` VARCHAR(200) DEFAULT NULL
		,`bin_los_cd` VARCHAR(30) DEFAULT NULL
		,`bin_placement_cd` VARCHAR(30) DEFAULT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) DEFAULT NULL
		,`cd_reporter_type` VARCHAR(100) DEFAULT NULL
		,`filter_access_type` VARCHAR(30) DEFAULT NULL
		,`filter_allegation` VARCHAR(30) DEFAULT NULL
		,`filter_finding` VARCHAR(30) DEFAULT NULL
		,`bin_dep_cd` VARCHAR(20) DEFAULT NULL
		,`min_start_date` DATETIME DEFAULT NULL
		,`max_start_date` DATETIME DEFAULT NULL
		,`cnt_qry` INT (11) DEFAULT NULL
		,`last_run_date` DATETIME DEFAULT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `param_id`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_dep_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcp5_aggr;
	CREATE TABLE `cache_pbcp5_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`cohort_entry_date` DATETIME NOT NULL
		,`cd_discharge_type` INT (11) NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`reentry_within_month` INT (11) NOT NULL
		,`reentry_rate` DECIMAL(18, 2) DEFAULT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL DEFAULT '0'
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`cohort_entry_date`
			,`cd_discharge_type`
			,`reentry_within_month`
			)
		,KEY `idx_qry_id`(`qry_id`)
		,KEY `idx_qry_id_hashkey`(`int_hash_key`, `qry_id`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS prtl_pbcp5;
	CREATE TABLE `prtl_pbcp5` (
		`cohort_exit_year` DATETIME NOT NULL
		,`date_type` INT (11) NOT NULL
		,`qry_type` INT (11) NOT NULL
		,`cd_discharge_type` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) DEFAULT NULL
		,`pk_gndr` INT (11) DEFAULT NULL
		,`cd_race_census` INT (11) DEFAULT NULL
		,`census_hispanic_latino_origin_cd` INT (11) DEFAULT NULL
		,`init_cd_plcm_setng` INT (11) DEFAULT NULL
		,`long_cd_plcm_setng` INT (11) DEFAULT NULL
		,`exit_county_cd` INT (11) DEFAULT NULL
		,`int_match_param_key` DECIMAL(9, 0) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`max_bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) NOT NULL DEFAULT '0'
		,`filter_allegation` DECIMAL(7, 0) NOT NULL
		,`filter_finding` DECIMAL(5, 0) NOT NULL DEFAULT '0'
		,`mnth` INT (11) NOT NULL
		,`discharge_count` INT (11) DEFAULT NULL
		,`cohort_count` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`cohort_exit_year`
			,`date_type`
			,`qry_type`
			,`cd_discharge_type`
			,`int_match_param_key`
			,`bin_dep_cd`
			,`max_bin_los_cd`
			,`bin_ihs_svc_cd`
			,`bin_placement_cd`
			,`cd_reporter_type`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			,`mnth`
			)
		,KEY `idx_int_match_param_key`(`int_match_param_key`)
		,KEY `idx_finding_allegation`(`filter_allegation`, `filter_finding`)
		,KEY `idx_los`(`max_bin_los_cd`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS prtl_pbcs2;
	CREATE TABLE `prtl_pbcs2` (
		`cohort_begin_date` DATETIME NOT NULL
		,`date_type` INT (11) NOT NULL
		,`qry_type` INT (11) NOT NULL
		,`int_match_param_key` BIGINT (20) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`cd_race_census` INT (11) NOT NULL
		,`census_hispanic_latino_origin_cd` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) NOT NULL DEFAULT '0'
		,`filter_allegation` DECIMAL(5, 0) NOT NULL DEFAULT '0'
		,`filter_finding` DECIMAL(5, 0) NOT NULL DEFAULT '0'
		,`cd_reporter_type` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`initref` INT (11) NOT NULL
		,`initfndref` INT (11) NOT NULL
		,`cohortrefcount` INT (11) NOT NULL
		,`cohortfndrefcount` INT (11) NOT NULL
		,`case_founded_recurrence` INT (11) NOT NULL
		,`case_repeat_referral` INT (11) NOT NULL
		,`cnt_case` INT (11) NOT NULL
		,`nxt_ref_within_min_month` INT (11) NOT NULL
		,PRIMARY KEY (
			`cohort_begin_date`
			,`date_type`
			,`qry_type`
			,`int_match_param_key`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			,`cd_reporter_type`
			,`bin_ihs_svc_cd`
			,`initref`
			,`initfndref`
			,`case_founded_recurrence`
			,`nxt_ref_within_min_month`
			)
		,KEY `idx_int_match_param_key`(`int_match_param_key`, `filter_access_type`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcs2_params;
	CREATE TABLE `cache_pbcs2_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) NOT NULL
		,`cd_race_census` VARCHAR(30) NOT NULL
		,`cd_county` VARCHAR(250) NOT NULL
		,`cd_reporter_type` VARCHAR(100) NOT NULL
		,`filter_access_type` VARCHAR(30) NOT NULL
		,`filter_allegation` VARCHAR(30) NOT NULL
		,`filter_finding` VARCHAR(30) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`cnt_qry` INT (11) NOT NULL
		,`last_run_date` DATETIME NOT NULL
		,PRIMARY KEY (
			`age_grouping_cd`
			,`cd_race_census`
			,`cd_county`
			,`cd_reporter_type`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			)
		,KEY `qry_ID`(`qry_ID`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_pbcs2;
	CREATE TABLE `cache_qry_param_pbcs2` (
		`int_param_key` BIGINT (20) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`cd_county` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(12, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcs2_aggr;
	CREATE TABLE `cache_pbcs2_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`cd_county` INT (11) NOT NULL
		,`month` INT (11) NOT NULL
		,`among_first_cmpt_rereferred` DECIMAL(9, 2) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`int_hash_key` DECIMAL(21, 0) NOT NULL DEFAULT '0'
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`qry_type`
			,`date_type`
			,`start_date`
			,`int_hash_key`
			,`month`
			)
		,KEY `qry_id`(`qry_id`, `int_hash_key`)
		,KEY `idx_qry_id_only`(`qry_id`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_qry_param_pbcw3;
	CREATE TABLE `cache_qry_param_pbcw3` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		,KEY `qry_id`(`qry_id`)
		,KEY `int_param_key`(`int_param_key`)
		,KEY `idx_primary`(`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcw3_params;
	CREATE TABLE `cache_pbcw3_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) NOT NULL
		,`cd_race_census` VARCHAR(30) NOT NULL
		,`pk_gndr` VARCHAR(10) NOT NULL
		,`init_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`long_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`county_cd` VARCHAR(200) NOT NULL
		,`bin_los_cd` VARCHAR(30) NOT NULL
		,`bin_placement_cd` VARCHAR(30) NOT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) NOT NULL
		,`cd_reporter_type` VARCHAR(100) NOT NULL
		,`filter_access_type` VARCHAR(30) NOT NULL
		,`filter_allegation` VARCHAR(30) NOT NULL
		,`filter_finding` VARCHAR(30) NOT NULL
		,`bin_dep_cd` VARCHAR(20) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`cnt_qry` INT (11) NOT NULL
		,`last_run_date` DATETIME NOT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `param_id`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcw3_aggr;
	CREATE TABLE `cache_pbcw3_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`cohort_entry_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`family_setting_dcfs_prcntg` DECIMAL(9, 2) DEFAULT NULL
		,`family_setting_private_agency_prcntg` DECIMAL(9, 2) DEFAULT NULL
		,`relative_prcntg` DECIMAL(9, 2) DEFAULT NULL
		,`group_inst_care_prcntg` DECIMAL(9, 2) DEFAULT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`cohort_begin_year` INT (11) DEFAULT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`date_type`
			,`cohort_entry_date`
			)
		,KEY `idx_qry_id_int_hashkey`(`qry_id`, `int_hash_key`)
		,KEY `idx_int_hash_key`(`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_qry_param_pbcw4;
	CREATE TABLE `cache_qry_param_pbcw4` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,KEY `int_hash_key`(`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcw4_params;
	CREATE TABLE `cache_pbcw4_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) NOT NULL
		,`cd_race_census` VARCHAR(30) NOT NULL
		,`pk_gndr` VARCHAR(10) NOT NULL
		,`init_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`long_cd_plcm_setng` VARCHAR(50) NOT NULL
		,`county_cd` VARCHAR(200) NOT NULL
		,`bin_los_cd` VARCHAR(30) NOT NULL
		,`bin_placement_cd` VARCHAR(30) NOT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) NOT NULL
		,`cd_reporter_type` VARCHAR(100) NOT NULL
		,`filter_access_type` VARCHAR(30) NOT NULL
		,`filter_allegation` VARCHAR(30) NOT NULL
		,`filter_finding` VARCHAR(30) NOT NULL
		,`bin_dep_cd` VARCHAR(20) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`cnt_qry` INT (11) NOT NULL
		,`last_run_date` DATETIME NOT NULL
		,PRIMARY KEY (
			`age_grouping_cd`
			,`cd_race_census`
			,`pk_gndr`
			,`init_cd_plcm_setng`
			,`long_cd_plcm_setng`
			,`county_cd`
			,`bin_dep_cd`
			,`bin_los_cd`
			,`bin_placement_cd`
			,`bin_ihs_svc_cd`
			,`cd_reporter_type`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			)
		,KEY `qry_ID`(`qry_ID`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_pbcw4_aggr;
	CREATE TABLE `cache_pbcw4_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`cohort_entry_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`kincare` INT (11) NOT NULL
		,`bin_sibling_group_size` INT (11) NOT NULL
		,`all_together` DECIMAL(9, 2) NOT NULL
		,`some_together` DECIMAL(9, 2) NOT NULL
		,`none_together` DECIMAL(9, 2) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`cohort_begin_year` INT (11) DEFAULT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,`cnt_cohort` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`date_type`
			,`cohort_entry_date`
			,`bin_sibling_group_size`
			,`kincare`
			)
		,KEY `idx_bin_placement_cd`(`bin_placement_cd`)
		,KEY `idx_qry_id_bin_dep_cd`(`qry_id`, `bin_dep_cd`)
		,KEY `qry_id_hash_key`(`int_hash_key`)
		,KEY `idx_hash_key_alone`(`qry_id`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_poc1ab_params;
	CREATE TABLE `cache_poc1ab_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) DEFAULT NULL
		,`cd_race_census` VARCHAR(30) DEFAULT NULL
		,`pk_gndr` VARCHAR(10) DEFAULT NULL
		,`init_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`long_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`county_cd` VARCHAR(200) DEFAULT NULL
		,`bin_los_cd` VARCHAR(30) DEFAULT NULL
		,`bin_placement_cd` VARCHAR(30) DEFAULT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) DEFAULT NULL
		,`cd_reporter_type` VARCHAR(100) DEFAULT NULL
		,`filter_access_type` VARCHAR(30) DEFAULT NULL
		,`filter_allegation` VARCHAR(30) DEFAULT NULL
		,`filter_finding` VARCHAR(30) DEFAULT NULL
		,`bin_dep_cd` VARCHAR(20) DEFAULT NULL
		,`min_start_date` DATETIME DEFAULT NULL
		,`max_start_date` DATETIME DEFAULT NULL
		,`cnt_qry` INT (11) DEFAULT NULL
		,`last_run_date` DATETIME DEFAULT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `param_id`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_poc1ab;
	CREATE TABLE `cache_qry_param_poc1ab` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_poc1ab_aggr;
	CREATE TABLE `cache_poc1ab_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`cnt_start_date` INT (11) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`int_hash_key` DECIMAL(22, 0) unsigned zerofill NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`fl_include_perCapita` INT (11) NOT NULL DEFAULT '1'
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`date_type`
			,`start_date`
			)
		,KEY `idx_qry_id_hash_key`(`qry_id`, `int_hash_key`)
		,KEY `idx_qryeth`(`qry_id`, `int_param_key`, `bin_dep_cd`, `cd_race`)
		,KEY `idx_census_counts`(`start_year`, `county_cd`, `pk_gndr`, `cd_race`, `age_grouping_cd`, `cnt_start_date`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_poc1ab_entries_params;
	CREATE TABLE `cache_poc1ab_entries_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) DEFAULT NULL
		,`cd_race_census` VARCHAR(30) DEFAULT NULL
		,`pk_gndr` VARCHAR(10) DEFAULT NULL
		,`init_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`long_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`county_cd` VARCHAR(200) DEFAULT NULL
		,`bin_los_cd` VARCHAR(30) DEFAULT NULL
		,`bin_placement_cd` VARCHAR(30) DEFAULT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) DEFAULT NULL
		,`cd_reporter_type` VARCHAR(100) DEFAULT NULL
		,`filter_access_type` VARCHAR(30) DEFAULT NULL
		,`filter_allegation` VARCHAR(30) DEFAULT NULL
		,`filter_finding` VARCHAR(30) DEFAULT NULL
		,`bin_dep_cd` VARCHAR(20) DEFAULT NULL
		,`min_start_date` DATETIME DEFAULT NULL
		,`max_start_date` DATETIME DEFAULT NULL
		,`cnt_qry` INT (11) DEFAULT NULL
		,`last_run_date` DATETIME DEFAULT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `param_id`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_poc1ab_entries;
	CREATE TABLE `cache_qry_param_poc1ab_entries` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS prtl_poc1ab_entries;
	CREATE TABLE `prtl_poc1ab_entries` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`max_bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) DEFAULT NULL
		,`cd_race` INT (11) DEFAULT NULL
		,`census_hispanic_latino_origin_cd` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) DEFAULT NULL
		,`long_cd_plcm_setng` INT (11) DEFAULT NULL
		,`county_cd` INT (11) DEFAULT NULL
		,`int_match_param_key` BIGINT (20) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) DEFAULT NULL
		,`filter_allegation` DECIMAL(18, 0) NOT NULL DEFAULT '10000'
		,`filter_finding` DECIMAL(18, 0) NOT NULL DEFAULT '10000'
		,`cnt_entries` INT (11) DEFAULT NULL
		,`start_year` INT (11) NOT NULL
		,KEY `idx_year_inc`(`start_year`)
		,KEY `idx_filters_fnd_covering`(`filter_finding`, `qry_type`, `date_type`, `start_date`, `bin_dep_cd`)
		,KEY `idx_bin_dep_cd_start_date`(`start_date`, `bin_dep_cd`)
		,KEY `idx_params`(`int_match_param_key`, `max_bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_poc1ab_entries_aggr;
	CREATE TABLE `cache_poc1ab_entries_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`cnt_entries` INT (11) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`fl_include_perCapita` INT (11) NOT NULL DEFAULT '1'
		,PRIMARY KEY (
			`int_hash_key`
			,`qry_type`
			,`date_type`
			,`start_date`
			)
		,KEY `idx_qry_id_hash_key`(`qry_id`, `int_hash_key`)
		,KEY `idx_qryeth`(`qry_id`, `int_param_key`, `bin_dep_cd`, `cd_race`)
		,KEY `idx_census_start_year_county_cd_gender_race_age`(`start_year`, `county_cd`, `pk_gndr`, `cd_race`, `age_grouping_cd`, `cnt_entries`)
		,KEY `id_fl_include_perCapita`(`fl_include_perCapita`)
		,KEY `fk_bin_ihs_svc_cd_idx`(`bin_ihs_svc_cd`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_poc1ab_exits_params;
	CREATE TABLE `cache_poc1ab_exits_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) DEFAULT NULL
		,`cd_race_census` VARCHAR(30) DEFAULT NULL
		,`pk_gndr` VARCHAR(10) DEFAULT NULL
		,`init_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`long_cd_plcm_setng` VARCHAR(50) DEFAULT NULL
		,`county_cd` VARCHAR(200) DEFAULT NULL
		,`bin_los_cd` VARCHAR(30) DEFAULT NULL
		,`bin_placement_cd` VARCHAR(30) DEFAULT NULL
		,`bin_ihs_svc_cd` VARCHAR(30) DEFAULT NULL
		,`cd_reporter_type` VARCHAR(100) DEFAULT NULL
		,`filter_access_type` VARCHAR(30) DEFAULT NULL
		,`filter_allegation` VARCHAR(30) DEFAULT NULL
		,`filter_finding` VARCHAR(30) DEFAULT NULL
		,`bin_dep_cd` VARCHAR(20) DEFAULT NULL
		,`min_start_date` DATETIME DEFAULT NULL
		,`max_start_date` DATETIME DEFAULT NULL
		,`cnt_qry` INT (11) DEFAULT NULL
		,`last_run_date` DATETIME DEFAULT NULL
		,PRIMARY KEY (`qry_ID`)
		,KEY `param_id`(`age_grouping_cd`, `cd_race_census`, `pk_gndr`, `init_cd_plcm_setng`, `long_cd_plcm_setng`, `county_cd`, `bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_poc1ab_exits;
	CREATE TABLE `cache_qry_param_poc1ab_exits` (
		`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,PRIMARY KEY (`int_hash_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS prtl_poc1ab_exits;
	CREATE TABLE `prtl_poc1ab_exits` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`max_bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) DEFAULT NULL
		,`cd_race` INT (11) DEFAULT NULL
		,`census_hispanic_latino_origin_cd` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) DEFAULT NULL
		,`long_cd_plcm_setng` INT (11) DEFAULT NULL
		,`county_cd` INT (11) DEFAULT NULL
		,`int_match_param_key` BIGINT (20) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) DEFAULT NULL
		,`filter_allegation` DECIMAL(18, 0) NOT NULL DEFAULT '10000'
		,`filter_finding` DECIMAL(18, 0) NOT NULL DEFAULT '10000'
		,`cd_discharge_type` INT (11) NOT NULL
		,`cnt_exits` INT (11) DEFAULT NULL
		,`start_year` INT (11) NOT NULL
		,KEY `idx_year_inc`(`start_year`)
		,KEY `idx_filters_fnd_covering`(`filter_finding`, `qry_type`, `date_type`, `start_date`, `bin_dep_cd`)
		,KEY `idx_bin_dep_cd_start_date`(`start_date`, `bin_dep_cd`)
		,KEY `idx_params`(`int_match_param_key`, `max_bin_los_cd`, `bin_placement_cd`, `bin_ihs_svc_cd`, `cd_reporter_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_poc1ab_exits_aggr;
	CREATE TABLE `cache_poc1ab_exits_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`int_hash_key` DECIMAL(22, 0) NOT NULL
		,`cd_discharge_type` INT (11) NOT NULL
		,`cnt_exits` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`fl_include_perCapita` INT (11) NOT NULL
		,PRIMARY KEY (
			`int_hash_key`
			,`cd_discharge_type`
			,`qry_type`
			,`date_type`
			,`start_date`
			)
		,KEY `idx_qry_id_hash_key`(`qry_id`, `int_hash_key`)
		,KEY `idx_qryeth`(`qry_id`, `int_param_key`, `cd_race`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS cache_poc2ab_params;
	CREATE TABLE `cache_poc2ab_params` (
		`qry_ID` BIGINT (20) NOT NULL
		,`age_grouping_cd` VARCHAR(20) NOT NULL
		,`cd_race_census` VARCHAR(30) NOT NULL
		,`cd_county` VARCHAR(250) NOT NULL
		,`cd_reporter_type` VARCHAR(100) NOT NULL
		,`filter_access_type` VARCHAR(30) NOT NULL
		,`filter_allegation` VARCHAR(30) NOT NULL
		,`filter_finding` VARCHAR(30) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`cnt_qry` INT (11) NOT NULL
		,`last_run_date` DATETIME NOT NULL
		,PRIMARY KEY (
			`age_grouping_cd`
			,`cd_race_census`
			,`cd_county`
			,`cd_reporter_type`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			)
		,KEY `idx_qry_id_only`(`qry_ID`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_qry_param_poc2ab;
	CREATE TABLE `cache_qry_param_poc2ab` (
		`int_param_key` BIGINT (20) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`cd_county` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`int_all_param_key` DECIMAL(12, 0) NOT NULL
		,PRIMARY KEY (`int_all_param_key`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS prtl_poc2ab;
	CREATE TABLE `prtl_poc2ab` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`start_year` INT (11) NOT NULL
		,`int_match_param_key` BIGINT (20) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) NOT NULL DEFAULT '0'
		,`filter_allegation` DECIMAL(5, 0) NOT NULL DEFAULT '0'
		,`filter_finding` DECIMAL(5, 0) NOT NULL DEFAULT '0'
		,`cd_sib_age_group` INT (11) DEFAULT NULL
		,`cd_race_census` INT (11) DEFAULT NULL
		,`census_hispanic_latino_origin_cd` INT (11) NOT NULL
		,`county_cd` INT (11) DEFAULT NULL
		,`cnt_start_date` INT (11) DEFAULT NULL
		,`cnt_opened` INT (11) DEFAULT NULL
		,`cnt_closed` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`qry_type`
			,`date_type`
			,`start_date`
			,`int_match_param_key`
			,`cd_reporter_type`
			,`filter_access_type`
			,`filter_allegation`
			,`filter_finding`
			)
		,KEY `idx_int_match_param_key`(`int_match_param_key`, `cd_reporter_type`, `filter_access_type`)
		,KEY `idx_param_key_rpt`(`int_match_param_key`, `cd_reporter_type`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS cache_poc2ab_aggr;
	CREATE TABLE `cache_poc2ab_aggr` (
		`qry_type` INT (11) NOT NULL
		,`date_type` INT (11) NOT NULL
		,`start_date` DATETIME NOT NULL
		,`int_param_key` BIGINT (20) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`cd_access_type` INT (11) NOT NULL
		,`cd_allegation` INT (11) NOT NULL
		,`cd_finding` INT (11) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`cd_county` INT (11) NOT NULL
		,`cnt_start_date` INT (11) NOT NULL
		,`cnt_opened` INT (11) NOT NULL
		,`cnt_closed` INT (11) NOT NULL
		,`min_start_date` DATETIME NOT NULL
		,`max_start_date` DATETIME NOT NULL
		,`x1` FLOAT NOT NULL
		,`x2` FLOAT NOT NULL
		,`insert_date` DATETIME NOT NULL
		,`int_all_param_key` DECIMAL(21, 0) NOT NULL
		,`qry_id` INT (11) NOT NULL
		,`start_year` INT (11) DEFAULT NULL
		,`fl_include_perCapita` SMALLINT (6) NOT NULL DEFAULT '1'
		,PRIMARY KEY (
			`int_all_param_key`
			,`qry_type`
			,`date_type`
			,`start_date`
			)
		,KEY `idx_census_poc2ab`(`start_year`, `cd_county`, `cd_race`, `cd_sib_age_grp`, `cnt_start_date`, `cnt_opened`, `cnt_closed`)
		,KEY `qry_id`(`int_all_param_key`, `qry_id`)
		,KEY `idx_cd_county_idx`(`cd_county`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS ref_match_allegation;
	CREATE TABLE `ref_match_allegation` (
		`cd_allegation` INT (11) NOT NULL
		,`filter_allegation` INT (11) NOT NULL
		,`fl_phys_abuse` INT (11) DEFAULT NULL
		,`fl_sexual_abuse` INT (11) DEFAULT NULL
		,`fl_neglect` INT (11) DEFAULT NULL
		,`fl_any_legal` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`cd_allegation`
			,`filter_allegation`
			)
		,KEY `cd_allegation`(`cd_allegation`, `filter_allegation`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS ref_match_finding;
	CREATE TABLE `ref_match_finding` (
		`filter_finding` INT (11) NOT NULL
		,`fl_founded_phys_abuse` INT (11) DEFAULT NULL
		,`fl_founded_sexual_abuse` INT (11) DEFAULT NULL
		,`fl_founded_neglect` INT (11) DEFAULT NULL
		,`fl_any_finding_legal` INT (11) DEFAULT NULL
		,`cd_finding` INT (11) NOT NULL
		,PRIMARY KEY (
			`filter_finding`
			,`cd_finding`
			)
		,KEY `filter_finding`(`filter_finding`, `cd_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS ooh_point_in_time_measures;
	CREATE TABLE `ooh_point_in_time_measures` (
		`start_date` DATETIME NOT NULL
		,`date_type` INT (11) NOT NULL
		,`qry_type` INT (11) NOT NULL
		,`age_grouping_cd_mix` INT (11) NOT NULL
		,`age_grouping_cd_census` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`census_hispanic_latino_origin_cd` INT (11) NOT NULL
		,`init_cd_plcm_setng` INT (11) NOT NULL
		,`long_cd_plcm_setng` INT (11) NOT NULL
		,`county_cd` INT (11) NOT NULL
		,`int_match_param_key_mix` INT (11) NOT NULL
		,`int_match_param_key_census` INT (11) NOT NULL
		,`bin_dep_cd` INT (11) NOT NULL
		,`max_bin_los_cd` INT (11) NOT NULL
		,`bin_placement_cd` INT (11) NOT NULL
		,`cd_reporter_type` INT (11) NOT NULL
		,`bin_ihs_svc_cd` INT (11) NOT NULL
		,`filter_access_type` DECIMAL(9, 0) NOT NULL
		,`filter_allegation` INT (11) NOT NULL
		,`filter_finding` INT (11) NOT NULL
		,`kincare` INT (11) DEFAULT NULL
		,`bin_sibling_group_size` INT (11) DEFAULT NULL
		,`family_setting_cnt` INT (11) DEFAULT NULL
		,`family_setting_DCFS_cnt` INT (11) DEFAULT NULL
		,`family_setting_private_agency_cnt` INT (11) DEFAULT NULL
		,`relative_care` INT (11) DEFAULT NULL
		,`group_inst_care_cnt` INT (11) DEFAULT NULL
		,`all_sib_together` INT (11) DEFAULT NULL
		,`some_sib_together` INT (11) DEFAULT NULL
		,`no_sib_together` INT (11) DEFAULT NULL
		,`cnt_child_unique` INT (11) DEFAULT NULL
		,`cnt_child` INT (11) DEFAULT NULL
		,`fl_w3` INT (11) NOT NULL
		,`fl_w4` INT (11) NOT NULL
		,`fl_poc1ab` INT (11) NOT NULL
		,KEY `idx_pbcw3_qid1`(`fl_w3`)
		,KEY `idx_pbcw4_qid1`(`fl_w4`)
		,KEY `idx_poc1ab_qid1`(`fl_poc1ab`, `int_match_param_key_census`, `bin_dep_cd`, `max_bin_los_cd`, `bin_placement_cd`, `cd_reporter_type`, `bin_ihs_svc_cd`, `filter_access_type`, `filter_allegation`, `filter_finding`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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
DROP TABLE

IF EXISTS ref_lookup_census_population;
	CREATE TABLE `ref_lookup_census_population` (
		`source_census` INT (11) DEFAULT NULL
		,`county_cd` INT (11) NOT NULL
		,`pk_gndr` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`age_grouping_cd` INT (11) NOT NULL
		,`measurement_year` INT (11) NOT NULL
		,`pop_cnt` INT (11) DEFAULT NULL
		,PRIMARY KEY (
			`measurement_year`
			,`age_grouping_cd`
			,`cd_race`
			,`pk_gndr`
			,`county_cd`
			)
		,KEY `idx_measurement_year`(`measurement_year`)
		,KEY `idx_age_race_gndr_county_year`(`age_grouping_cd`, `cd_race`, `pk_gndr`, `county_cd`, `measurement_year`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS ref_lookup_census_population_poc2;
	CREATE TABLE `ref_lookup_census_population_poc2` (
		`source_census` INT (11) DEFAULT NULL
		,`county_cd` INT (11) NOT NULL
		,`cd_race` INT (11) NOT NULL
		,`cd_sib_age_grp` INT (11) NOT NULL
		,`measurement_year` INT (11) NOT NULL
		,`pop_cnt` INT (11) DEFAULT NULL
		,KEY `idx_year_cnty_age_race`(`measurement_year`, `cd_sib_age_grp`, `cd_race`, `county_cd`)
		,KEY `idx_cd_sib_age_grp`(`cd_sib_age_grp`)
		,KEY `idx_cd_race`(`cd_race`)
		,KEY `idx_county_cd`(`county_cd`)
		,KEY `idx_year`(`measurement_year`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

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

DROP TABLE

IF EXISTS ref_lookup_max_date;
	CREATE TABLE `ref_lookup_max_date` (
		`id` INT (11) NOT NULL
		,`procedure_name` VARCHAR(45) DEFAULT NULL
		,`max_date_all` DATETIME DEFAULT NULL
		,`max_date_any` DATETIME DEFAULT NULL
		,`max_date_qtr` DATETIME DEFAULT NULL
		,`max_date_yr` DATETIME DEFAULT NULL
		,`min_date_any` DATETIME DEFAULT NULL
		,`is_current` INT (11) DEFAULT NULL
		,PRIMARY KEY (`id`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_lookup_max_date.txt'
INTO TABLE ref_lookup_max_date fields terminated BY '|' (
		id
		,PROCEDURE_NAME
		,max_date_all
		,max_date_any
		,max_date_qtr
		,min_date_any
		,max_date_yr
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
DROP TABLE

IF EXISTS ref_last_dw_transfer;
	CREATE TABLE `ref_last_dw_transfer` (
		`cutoff_date` DATETIME NOT NULL
		,PRIMARY KEY (`cutoff_date`)
		,KEY `cutoff_date`(`cutoff_date`)
		) ENGINE = InnoDB DEFAULT CHARSET = latin1;

LOAD DATA INFILE '/data/pocweb/upload_files/ref_last_dw_transfer.txt'
INTO TABLE ref_last_dw_transfer fields terminated BY '|' (cutoff_date);

analyze TABLE ref_last_dw_transfer;
