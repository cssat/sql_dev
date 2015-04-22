CREATE procedure [prtl].[prod_build_match_allegation] as 
set nocount on
truncate table dbo.ref_match_allegation

if OBJECT_ID('tempDB..#ref_match_allegation' ) is not null drop table #ref_match_allegation
CREATE TABLE #ref_match_allegation(
	[filter_allegation] [int] NOT NULL,
		fl_any_legal [int] NULL,
	[fl_phys_abuse] [int] NULL,
	[fl_sexual_abuse] [int] NULL,
	[fl_neglect] [int] NULL
)

insert into #ref_match_allegation (filter_allegation,fl_any_legal,fl_phys_abuse,fl_sexual_abuse,fl_neglect)

select constant  
+  iif(NOT(fl_phys_abuse.fl_phys_abuse =0 and  fl_sexual_abuse.fl_sexual_abuse=0 and fl_neglect.fl_neglect=0)
		  ,fl_any_legal.fl_any_legal,0)  * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal') 
+ fl_phys_abuse.fl_phys_abuse * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse')
+  fl_sexual_abuse.fl_sexual_abuse * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse')
+  fl_neglect.fl_neglect * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect') 
,iif(NOT(fl_phys_abuse.fl_phys_abuse =0 and  fl_sexual_abuse.fl_sexual_abuse=0 and fl_neglect.fl_neglect=0)
		  ,fl_any_legal.fl_any_legal,0) fl_any_legal
,fl_phys_abuse.fl_phys_abuse
,fl_sexual_abuse.fl_sexual_abuse
,fl_neglect.fl_neglect
from (select cd_multiplier constant from ref_filter_allegation where cd_allegation=0) c
cross join  (select 0 fl_phys_abuse union select 1) fl_phys_abuse 
cross join  (select 0 fl_sexual_abuse union select 1) fl_sexual_abuse 
cross join  (select 0 fl_neglect union select 1) fl_neglect 
cross join  (select 1 fl_any_legal ) fl_any_legal 
-- include other maltreatment
union select constant +  (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal') ,1,0,0,0
from (select cd_multiplier constant from ref_filter_allegation where cd_allegation=0) c
union  select (select cd_multiplier constant from ref_filter_allegation where cd_allegation=0)  ,0,0,0,0





if OBJECT_ID('tempDB..#temp') is not null drop table #temp
select 1 as cd_allegation ,filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse
into #temp 
from #ref_match_allegation 
where fl_phys_abuse=1
union
select 2 as cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from #ref_match_allegation 
where fl_sexual_abuse=1
union
select 3 as cd_allegation,  filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from #ref_match_allegation 
where fl_neglect=1
union all
select 4 as cd_allegation ,filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from #ref_match_allegation 
where fl_any_legal=1		
union all
select 0,filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse from #ref_match_allegation 
where fl_any_legal=0		


insert into dbo.ref_match_allegation ( cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse )
select  cd_allegation , filter_allegation,fl_any_legal,fl_neglect,fl_sexual_abuse,fl_phys_abuse  from #temp

update prtl.prtl_tables_last_update
set last_build_date=getdate(),row_count=(select count(*) from ref_match_allegation)
where tbl_id=48;


update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_match_allegation'

--select * from prtl.prtl_tables_last_update