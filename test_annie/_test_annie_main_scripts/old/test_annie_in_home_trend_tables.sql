use test_annie;
truncate table cache_poc3ab_params;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc3ab_params.txt'
into table cache_poc3ab_params
fields terminated by '|'
(qry_ID, cd_sib_age_grp, cd_race_census, cd_office, cd_reporter_type, bin_ihs_svc_cd, filter_access_type, filter_allegation, filter_finding, filter_srvc_type, 
                         filter_budget, min_start_date, max_start_date, cnt_qry, last_run_date);

 truncate table cache_qry_param_poc3ab;
 LOAD DATA LOCAL INFILE '/data/pocweb/cache_qry_param_poc3ab.txt'
 into table cache_qry_param_poc3ab
 fields terminated by '|'
 (qry_id,param_value,param_name ,param_pos);
 
truncate table cache_poc3ab_aggr;
LOAD DATA LOCAL INFILE '/data/pocweb/cache_poc3ab_aggr.txt'
into table cache_poc3ab_aggr
fields terminated by '|'
( qry_type, date_type,  start_date, int_param_key, bin_ihs_svc_cd, cd_reporter_type, cd_access_type, cd_allegation
 ,cd_finding, cd_service_type, cd_budget_type, cd_sib_age_grp, cd_race_census, cd_office_collapse, cnt_start_date, cnt_opened, cnt_closed,min_start_date,  max_start_date, x1, x2, insert_date
, qry_id, start_year);

truncate table prtl_poc3ab;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_poc3ab.txt'
into table prtl_poc3ab
fields terminated by '|'
(qry_type, date_type,  start_date, start_year, int_match_param_key, bin_ihs_svc_cd, cd_reporter_type, fl_cps_invs, 
                         filter_access_type, filter_allegation, filter_finding, filter_service_type, filter_budget_type, fl_phys_abuse, fl_sexual_abuse, fl_neglect, fl_any_legal, 
                         fl_founded_phys_abuse, fl_founded_sexual_abuse, fl_founded_neglect, fl_found_any_legal, fl_family_focused_services, fl_child_care, fl_therapeutic_services, 
                         fl_family_home_placements, fl_behavioral_rehabiliation_services, fl_other_therapeutic_living_situations, fl_specialty_adolescent_services, fl_respite, 
                         fl_transportation, fl_adoption_support, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, fl_uncat_svc, cd_sib_age_group, 
 cd_race_census, census_hispanic_latino_origin_cd, cd_office, cnt_start_date, cnt_opened, cnt_closed);

analyze table prtl_poc3ab;


select count(*) as cnt,max(qry_id) as qry_id from cache_poc3ab_params;
select min(start_date) as Min_Date,max(start_date) as max_Date,count(*) as cnt,max(qry_id) as qry_id from cache_poc3ab_aggr;
select count(*) as cnt,max(qry_id) as qry_id from cache_qry_param_poc3ab;