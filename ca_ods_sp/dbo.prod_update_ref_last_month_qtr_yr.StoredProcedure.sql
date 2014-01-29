USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[prod_update_ref_last_month_qtr_yr]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[prod_update_ref_last_month_qtr_yr] 
as
begin
truncate table dbo.ref_last_month_qtr_yr
insert into dbo.ref_last_month_qtr_yr
select 0,eomonth(dbo.last_complete_month())
union
select 1,dateadd(dd,-1,dateadd(mm,3,dbo.last_complete_qtr()))
union
select 2,cast(cast(year(dbo.last_complete_yr()) as char(4)) + '-12-31' as datetime)
end


GO
