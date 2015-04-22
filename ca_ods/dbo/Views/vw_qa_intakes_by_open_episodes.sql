

create view [dbo].[vw_qa_intakes_by_open_episodes]
as
select  [yr],count(*)  removal_cnt,sum(iif(id_intake_fact is null,0,1)) as [cnt_with_intakes]  ,sum(iif(id_intake_fact is null,0,1)) /(count(*)   * 1.0000) * 100 as [%_with_intakes],ROW_NUMBER() over (order by [yr]) [sort_key]
from base.rptPlacement 
join (select distinct [Year] [YR] ,DATEFROMPARTS(year([year]),12,31) [YR_end] from  calendar_dim
			where [Year]  >='2000-01-01'  and [Year] <  getdate()) cd on  removal_dt <= yr_end and discharge_dt >= yr
where removal_dt >='2000-01-01' or discharge_dt  >='2000-01-01' 
group by [yr]

