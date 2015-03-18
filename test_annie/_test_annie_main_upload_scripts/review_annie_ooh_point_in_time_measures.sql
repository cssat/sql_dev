use review_annie;

truncate table ooh_point_in_time_measures;
LOAD DATA INFILE '/data/pocweb/ooh_point_in_time_measures.txt'
into table ooh_point_in_time_measures
fields terminated by ','
LINES TERMINATED BY '\n' 
(qry_type,date_type,start_date,bin_dep_cd,max_bin_los_cd
,bin_placement_cd,bin_ihs_svc_cd,cd_reporter_type
,cd_race,census_hispanic_latino_origin_cd
,pk_gndr,init_cd_plcm_setng,long_cd_plcm_setng
,county_cd,filter_allegation,filter_finding,
filter_service_category,filter_service_budget,filter_access_type,age_grouping_cd_mix,age_grouping_cd_census,int_match_param_key_mix,int_match_param_key_census,kincare,bin_sibling_group_size,family_setting_cnt,
family_setting_DCFS_cnt,family_setting_private_agency_cnt,relative_care,group_inst_care_cnt,all_sib_together,some_sib_together,no_sib_together,cnt_child_unique,cnt_child,fl_w3,fl_w4,fl_poc1ab);


analyze table ooh_point_in_time_measures;

   update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ooh_point_in_time_measures)
  where tbl_name='ooh_point_in_time_measures';