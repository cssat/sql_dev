USE [CA_ODS]
GO

/****** Object:  View [dbo].[vw_qa_intakes_by_open_episodes]    Script Date: 5/21/2014 10:48:12 AM ******/
DROP VIEW [dbo].[vw_qa_intakes_by_open_episodes]
GO

/****** Object:  View [dbo].[vw_qa_intakes_by_open_episodes]    Script Date: 5/21/2014 10:48:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vw_qa_intakes_by_open_episodes]
as
select  [yr],count(*)  removal_cnt,sum(iif(id_intake_fact is null,0,1)) as [cnt_with_intakes]  ,sum(iif(id_intake_fact is null,0,1)) /(count(*)   * 1.0000) * 100 as [%_with_intakes],ROW_NUMBER() over (order by [yr]) [sort_key]
from base.rptPlacement 
join (select distinct [Year] [YR] ,DATEFROMPARTS(year([year]),12,31) [YR_end] from  calendar_dim
			where [Year]  >='2000-01-01'  and [Year] <  getdate()) cd on  removal_dt <= yr_end and discharge_dt >= yr
where removal_dt >='2000-01-01' or discharge_dt  >='2000-01-01' 
group by [yr]

GO


