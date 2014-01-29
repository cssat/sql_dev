USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[sys_get_insert_code_ref_lookup_max_date]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sys_get_insert_code_ref_lookup_max_date] 
as 
select CONCAT('select ',id,',',char(39),procedure_name,char(39),',',char(39),convert(varchar(10),max_date_all,121),char(39),','
,char(39),convert(varchar(10),max_date_any,121),char(39),','
,char(39),convert(varchar(10),max_date_qtr,121),char(39),','
,char(39),convert(varchar(10),max_date_yr,121),char(39),','
,char(39),convert(varchar(10),min_date_any,121),char(39),' UNION ALL')
from ref_lookup_max_date
GO
