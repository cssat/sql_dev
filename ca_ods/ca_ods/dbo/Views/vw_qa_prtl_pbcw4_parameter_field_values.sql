


CREATE view [dbo].[vw_qa_prtl_pbcw4_parameter_field_values] as 
select    'qry_type'  [col_name]  , qry_type [col_value],  count(*)  [row_cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    qry_type  UNION ALL
select    'age_grouping_cd_mix'  [col_name]  , age_grouping_cd_mix,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    age_grouping_cd_mix  UNION ALL
select    'pk_gndr'  [col_name]  , pk_gndr,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    pk_gndr  UNION ALL
select    'cd_race'  [col_name]  , cd_race,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    cd_race  UNION ALL
select    'census_hispanic_latino_origin_cd'  [col_name]  , census_hispanic_latino_origin_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    census_hispanic_latino_origin_cd  UNION ALL
select    'init_cd_plcm_setng'  [col_name]  , init_cd_plcm_setng,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    init_cd_plcm_setng  UNION ALL
select    'long_cd_plcm_setng'  [col_name]  , long_cd_plcm_setng,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    long_cd_plcm_setng  UNION ALL
select    'county_cd'  [col_name]  , county_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    county_cd  UNION ALL
select    'bin_dep_cd'  [col_name]  , bin_dep_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    bin_dep_cd  UNION ALL
select    'max_bin_los_cd'  [col_name]  , max_bin_los_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    max_bin_los_cd  UNION ALL
select    'bin_placement_cd'  [col_name]  , bin_placement_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    bin_placement_cd  UNION ALL
select    'cd_reporter_type'  [col_name]  , cd_reporter_type,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    cd_reporter_type  UNION ALL
select    'bin_ihs_svc_cd'  [col_name]  , bin_ihs_svc_cd,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    bin_ihs_svc_cd  UNION ALL
select    'kincare'  [col_name]  , kincare,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    kincare  UNION ALL
select    'bin_sibling_group_size'  [col_name]  , bin_sibling_group_size,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    bin_sibling_group_size  UNION ALL
select    'all_sib_together'  [col_name]  , all_sib_together,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    all_sib_together  UNION ALL
select    'some_sib_together'  [col_name]  , some_sib_together,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    some_sib_together  UNION ALL
select    'no_sib_together'  [col_name]  , no_sib_together,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    no_sib_together  UNION ALL
select    'cnt_child'  [col_name]  , cnt_child,  count(*)  [cnt]   from  prtl.ooh_point_in_time_measures   WHERE fl_w4=1  GROUP BY    cnt_child 

