/****** Script for SelectTopNRows command from SSMS  ******/
SELECT concat(' ,','sum(case when sc.cd_subctgry_poc_frc=',cast(cd_subctgry_poc_frc as varchar(2)),' then 1 else 0 end) as ',fl_name)
  FROM [dbCoreAdministrativeTables].[dbo].[ref_service_cd_subctgry_poc]

  select * from ref_service_category


  SELECT concat(' ,',' sum(case when sc.cd_budget_poc_frc=',cast(cd_budget_poc_frc as varchar(2)),' then 1 else 0 end) as ',fl_name)
  FROM [dbCoreAdministrativeTables].[dbo].ref_service_cd_budget_poc_frc
  select * from ref_service_cd_budget_poc_frc
  fl_family_focused_services = curr.fl_family_focused_services + nxt.fl_family_focused_services
  --  fl_behavioral_rehabiliation_services = curr.fl_behavioral_rehabiliation_services + nxt.fl_behavioral_rehabiliation_services

  SELECT concat(' ,',char(32),fl_name,'=  case when nxt.',fl_name,' =1 then nxt.',fl_name,' else curr.',fl_name,' end')
  FROM [dbCoreAdministrativeTables].[dbo].[ref_service_cd_subctgry_poc]
  union all
    SELECT concat(' ,',char(32),fl_name,'=  case when nxt.',fl_name,' =1 then nxt.',fl_name,' else curr.',fl_name,' end')
  FROM [dbCoreAdministrativeTables].[dbo].ref_service_cd_budget_poc_frc



