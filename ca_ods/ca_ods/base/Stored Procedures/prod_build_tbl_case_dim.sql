


CREATE procedure [base].[prod_build_tbl_case_dim] 
as



declare @BEGINDATE datetime
Declare @ENDDATE datetime
declare @reportmonth datetime
declare @case int

 
SET @BeginDate = '1997-01-01'   
SET @EndDate = (select cutoff_date from ref_last_dw_transfer)
 
declare @today as datetime
declare @enddateINT as INT
DECLARE @BEGINDATEINT AS INT
declare @todayINT as INT
 
SET @Today = getdate()
SET @TodayINT = CONVERT(INT, CONVERT(VARCHAR(10),getdate(),112))
SET @enddateINT  = CONVERT(INT, CONVERT(VARCHAR(10),@enddate,112))
SET @BEGINDATEINT  = CONVERT(INT, CONVERT(VARCHAR(10),@BEGINDATE,112))
 --truncate table tbl_case_dim;
 
if object_ID('tempDB..#cases1') is not null drop table #cases1; 
---step 1: convert case dates from date/time to date
--, select all rows of case_dim based on open and closed dates evaluated against date parameters
select c.id_case
		,c.cd_case_type
		, c.tx_case_type as case_type_txt
		, c.dt_case_opn
		, c.dt_case_cls
		, c.CD_CASE_STAT
		, c.is_current
		, c.ID_LOCATION_DIM
 into #cases1
from dbo.case_dim c
where (C.DT_CASE_CLS IS NULL OR CONVERT(INT, CONVERT(VARCHAR(10),C.DT_CASE_CLS,112)) >  @BEGINDATEint) 
AND CONVERT(INT, CONVERT(VARCHAR(10),C.DT_CASE_OPN,112)) < @ENDDATEint
order by id_case
 
--step 2: select the last closed date for each case 
--and opn date where the status is ‘closed’ and records with out a cls date 
--but with a current flag (others only reflect a case opening or other change in the record)
if object_ID('tempDB..#cases2') is not null drop table #cases2; 
select distinct id_case,c.cd_case_type, c.case_type_txt,dt_case_opn, max(dt_case_cls) dt_case_cls,ID_LOCATION_DIM
into #cases2
from #cases1 c
where dt_case_cls is not null
group by id_case,dt_case_opn, c.case_type_txt,c.cd_case_type ,ID_LOCATION_DIM
union
select distinct id_case,  c.cd_case_type,c.case_type_txt,dt_case_opn, dt_case_cls dt_case_cls,ID_LOCATION_DIM
from #cases1 c
where c.is_current = 1 and dt_case_cls is null
 
--step 3: final list of case openings with ‘derived’ case closure dates
 
truncate table base.tbl_case_dim; 

INSERT INTO [base].[tbl_case_dim]
           ([id_case]
           ,[cd_case_type]
           ,[tx_case_type]
           ,[dt_case_opn]
           ,[dt_case_cls]
           ,[cseq]
           ,[case_opn_days]
           ,[tbl_refresh_dt])


select distinct c1.id_case, c2.cd_case_type,c2.case_type_txt,c1.dt_case_opn, isnull(c2.dt_case_cls,'12/31/9999')
,RANK() OVER(Partition BY C1.ID_CASE order by c1.DT_CASE_OPN,c2.DT_CASE_CLS) as CSEQ,
datediff(day,c2.dt_case_opn, isnull(c2.dt_case_cls,GETDATE())) case_opn_days
,@Today
--into #cases
from #cases1 c1
left join #cases2 c2 on c1.id_case = c2.id_case and c1.dt_case_opn = c2.dt_case_opn 


update cd
set cd_region=q.CD_REGION
,cd_office=q.CD_OFFICE
,cd_county=q.CD_CNTY
from base.tbl_case_dim cd
join (select id_case ,c1.DT_CASE_OPN,c1.DT_CASE_CLS,cd_region,cd_office,cd_cnty
, ROW_NUMBER() over (partition by id_case,dt_case_opn order by dt_case_cls desc) as row_num
from  #cases1 c1
join  location_dim ld on ld.ID_LOCATION_DIM=c1.ID_LOCATION_DIM) q on q.ID_CASE=cd.id_case 
		and q.row_num=1

 
 
 

update statistics base.tbl_case_dim;

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_tbl_case_dim'
