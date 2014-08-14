 
 use test_annie;
 
 truncate table cache_qry_param_poc2ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_poc2ab.txt'
 into table cache_qry_param_poc2ab
 fields terminated by '|'
 (qry_id,int_param_key,
cd_sib_age_grp,
cd_race,
cd_office,
cd_reporter_type,
cd_access_type,
cd_allegation,
cd_finding,
int_all_param_key);