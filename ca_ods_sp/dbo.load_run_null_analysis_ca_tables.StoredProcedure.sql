/****** Object:  StoredProcedure [dbo].[load_run_null_analysis_ca_tables]    Script Date: 8/26/2014 5:21:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[load_run_null_analysis_ca_tables]
as

update [dbo].[ca_table_id]
  set last_update =date_loaded
  from dbo.CA_DATA_LOADED cdl where cdl.ca_tbl_id=[ca_table_id].ca_tbl_id
  and cdl.date_loaded > getdate()-2


declare @counter int
declare @stop int
declare @mysql varchar(max)

if OBJECT_ID('tempDB..#temp') is not null drop table #temp
create table #temp(tbl_id int,tbl_name varchar(200),mysql varchar(max),pkey int)
insert into #temp
select  cdl.ca_tbl_id,cdl.tbl_name, concat('dbo.sp_null_analysis_insert ',char(39),cdl.tbl_name,char(39)),row_number() over (order by cdl.tbl_name) [row_num]
from CA_DATA_LOADED cdl  where exists (select * from ca_table_id ca
where  ca.ca_tbl_id=cdl.ca_tbl_id )
and date_loaded > getdate()-5
and tbl_name not in ('rptPlacement','rptPlacement_Events','rptPlacements')
order by cdl.tbl_name

select  @counter=min(pkey),@stop=max(pkey) from #temp;

while @counter <= @stop
begin

set @mysql=(select mysql from #temp where pkey=@counter);
exec (@mysql);



set @counter+=1;

end 


GO


