

CREATE  view [dbo].[vw_qa_prtl_pbcs2_parameter_field_values]
as 
select    'qry_type'  [col_name]  , qry_type [value],  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  qry_type  UNION ALL
select    'age_grouping_cd'  [col_name]  , cd_sib_age_grp,  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  cd_sib_age_grp  UNION ALL
select    'cd_race_census'  [col_name]  , cd_race_census,  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  cd_race_census  UNION ALL
select    'census_hispanic_latino_origin_cd'  [col_name]  , census_hispanic_latino_origin_cd,  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  census_hispanic_latino_origin_cd  UNION ALL
select    'county_cd'  [col_name]  , county_cd,  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  county_cd  UNION ALL
select    'cd_reporter_type'  [col_name]  , cd_reporter_type,  count(*)  [cnt]   from  prtl.prtl_pbcs2   GROUP BY  cd_reporter_type  UNION ALL
select 'cd_access_type',acc.cd_access_type,  count(*)  [cnt]    from prtl.prtl_pbcs2  s2 join ref_filter_access_type acc on acc.filter_access_type=s2.filter_access_type group by  acc.cd_access_type union all
select  'cd_allegation' [col_name],cd_allegation,  count(*)  [cnt]     from  prtl.prtl_pbcs2 s2 join ref_match_allegation  alg on alg.filter_allegation=s2.filter_allegation group by alg.cd_allegation UNION ALL
select   'cd_finding',fnd.cd_finding ,  count(*)  [cnt]   from  prtl.prtl_pbcs2 s2 join ref_match_finding fnd on fnd.filter_finding=s2.filter_finding group by fnd.cd_finding 


