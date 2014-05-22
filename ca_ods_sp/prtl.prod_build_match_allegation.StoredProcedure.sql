USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_match_allegation]    Script Date: 5/22/2014 11:18:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [prtl].[prod_build_match_allegation] as 

if object_ID(N'dbo.ref_match_allegation',N'U') is not null drop table dbo.ref_match_allegation
create table dbo.ref_match_allegation (cd_allegation int,filter_allegation decimal(18,0),[fl_phys_abuse] int
	  ,[fl_sexual_abuse] int
	  ,[fl_neglect] int
	  ,[fl_any_legal] int
	  )

insert into dbo.ref_match_allegation (filter_allegation,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal)
SELECT  distinct
      power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + ((case when fl_phys_abuse=1 or fl_sexual_abuse=1 or [fl_neglect]=1 then 1 else 0 end) * 1000) as filter_allegation
      ,[fl_phys_abuse]
	  ,[fl_sexual_abuse]
	  ,[fl_neglect]
	  ,case when fl_phys_abuse=1 or fl_sexual_abuse=1 or [fl_neglect]=1 then 1 else 0 end as [fl_any_legal]
  FROM vw_intakes_screened_in
  union
  SELECT  distinct
      power(10,4) + ((fl_phys_abuse * 1 ) + (fl_sexual_abuse * 10) +  (fl_neglect * 100)) + ((case when fl_phys_abuse=1 or fl_sexual_abuse=1 or [fl_neglect]=1 then 1 else 0 end) * 1000) as filter_allegation
      ,[fl_phys_abuse]
	  ,[fl_sexual_abuse]
	  ,[fl_neglect]
	  ,case when fl_phys_abuse=1 or fl_sexual_abuse=1 or [fl_neglect]=1 then 1 else 0 end as [fl_any_legal]
  FROM base.tbl_intakes

if OBJECT_ID('tempDB..#temp') is not null drop table #temp
select 1 as cd_allegation ,filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse
into #temp 
from ref_match_allegation 
where fl_phys_abuse=1
union
select 2 as cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from ref_match_allegation 
where fl_sexual_abuse=1
union
select 3 as cd_allegation,  filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from ref_match_allegation 
where fl_neglect=1
union all
select 4 as cd_allegation ,filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from ref_match_allegation 
where fl_any_legal=1		

truncate table dbo.ref_match_allegation 
insert into dbo.ref_match_allegation ( cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse )
select  cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse  from #temp

update prtl.prtl_tables_last_update
set last_build_date=getdate(),row_count=(select count(*) from ref_match_allegation)
where tbl_id=48;

--select * from prtl.prtl_tables_last_update