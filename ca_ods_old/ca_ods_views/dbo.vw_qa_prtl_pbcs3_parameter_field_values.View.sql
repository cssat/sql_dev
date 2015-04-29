USE [CA_ODS]
GO

/****** Object:  View [dbo].[vw_qa_prtl_pbcs3_parameter_field_values]    Script Date: 6/4/2014 6:41:51 PM ******/
DROP VIEW [dbo].[vw_qa_prtl_pbcs3_parameter_field_values]
GO

/****** Object:  View [dbo].[vw_qa_prtl_pbcs3_parameter_field_values]    Script Date: 6/4/2014 6:41:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE  view [dbo].[vw_qa_prtl_pbcs3_parameter_field_values]
as 
select    'qry_type'  [col_name]  , qry_type [value],  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  qry_type  UNION ALL
select    'age_grouping_cd'  [col_name]  , cd_sib_age_grp,  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  prtl_pbcs3.cd_sib_age_grp  UNION ALL
select    'cd_race_census'  [col_name]  , cd_race_census,  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  cd_race_census  UNION ALL
select    'census_hispanic_latino_origin_cd'  [col_name]  , census_hispanic_latino_origin_cd,  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  census_hispanic_latino_origin_cd  UNION ALL
select    'county_cd'  [col_name]  , county_cd,  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  county_cd  UNION ALL
select    'cd_reporter_type'  [col_name]  , cd_reporter,  count(*)  [cnt]   from  prtl.prtl_pbcs3   GROUP BY  cd_reporter  UNION ALL
select 'cd_access_type',acc.cd_access_type,  count(*)  [cnt]    from prtl.prtl_pbcs3  s2 join ref_filter_access_type acc on acc.filter_access_type=s2.filter_access_type group by  acc.cd_access_type union all
select  'cd_allegation' [col_name],cd_allegation,  count(*)  [cnt]     from  prtl.prtl_pbcs3 s2 join ref_match_allegation  alg on alg.filter_allegation=s2.filter_allegation group by alg.cd_allegation UNION ALL
select   'cd_finding',fnd.cd_finding ,  count(*)  [cnt]   from  prtl.prtl_pbcs3 s2 join ref_match_finding fnd on fnd.filter_finding=s2.filter_finding group by fnd.cd_finding union all
select 'bin_ihs_svc_cd',bin_ihs_svc_cd,count(*) from prtl.prtl_pbcs3 s2 group by bin_ihs_svc_cd union all
select 'filter_service_category', svc.cd_subctgry_poc_fr,count(*)   from prtl.prtl_pbcs3 s2 join ref_match_srvc_type_category svc on s2.filter_service_type = svc.filter_srvc_type  group by cd_subctgry_poc_fr union all
select 'filter_service_budget',cd_budget_poc_frc,count(*) from  prtl.prtl_pbcs3 s2 join ref_match_srvc_type_budget bud on bud.filter_service_budget=s2.filter_budget_type group by cd_budget_poc_frc


GO


