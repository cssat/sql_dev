create view [dbo].[vw_qa_prtl_poc1ab_param_values]
as 
select    'qry_type'  [col_name]  , qry_type,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  qry_type  UNION ALL
select    'bin_dep_cd'  [col_name]  , bin_dep_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  bin_dep_cd  UNION ALL
select    'max_bin_los_cd'  [col_name]  , max_bin_los_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  max_bin_los_cd  UNION ALL
select    'bin_placement_cd'  [col_name]  , bin_placement_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  bin_placement_cd  UNION ALL
select    'bin_ihs_svc_cd'  [col_name]  , bin_ihs_svc_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  bin_ihs_svc_cd  UNION ALL
select    'cd_reporter_type'  [col_name]  , cd_reporter_type,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  cd_reporter_type  UNION ALL
select    'age_grouping_cd'  [col_name]  , age_grouping_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  age_grouping_cd  UNION ALL
select    'cd_race'  [col_name]  , cd_race,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  cd_race  UNION ALL
select    'census_hispanic_latino_origin_cd'  [col_name]  , census_hispanic_latino_origin_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  census_hispanic_latino_origin_cd  UNION ALL
select    'pk_gndr'  [col_name]  , pk_gndr,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  pk_gndr  UNION ALL
select    'init_cd_plcm_setng'  [col_name]  , init_cd_plcm_setng,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  init_cd_plcm_setng  UNION ALL
select    'long_cd_plcm_setng'  [col_name]  , long_cd_plcm_setng,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  long_cd_plcm_setng  UNION ALL
select    'county_cd'  [col_name]  , county_cd,  count(*)  [cnt]   from  prtl.prtl_poc1ab   GROUP BY  county_cd  