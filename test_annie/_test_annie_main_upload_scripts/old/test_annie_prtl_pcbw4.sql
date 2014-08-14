use test_annie;



truncate table test_annie.prtl_pbcw4;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcw4.txt'
into table prtl_pbcw4
fields terminated by '|'
(pit_date,date_type,qry_type,age_grouping_cd,pk_gndr,cd_race_census,census_hispanic_latino_origin_cd,init_cd_plcm_setng,long_cd_plcm_setng,removal_county_cd,int_match_param_key,
bin_dep_cd,bin_los_cd,bin_placement_cd,cd_reporter_type,bin_ihs_svc_cd,filter_access_type,filter_allegation,filter_finding,filter_service_type,filter_budget_type,kincare,bin_sibling_group_size,all_sib_together,some_sib_together,no_sib_together,total);

analyze table prtl_pbcw4;

select 'prtl_pbcw4' as filename,count(*),sum(total),sum(all_sib_together) from prtl_pbcw4;



