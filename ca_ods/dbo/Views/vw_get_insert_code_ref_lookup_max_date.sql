CREATE view  [dbo].[vw_get_insert_code_ref_lookup_max_date] 
as 

select CONCAT('select ',id,',',char(39),procedure_name,char(39),',',char(39),convert(varchar(10),max_date_all,121),char(39),','
,char(39),convert(varchar(10),max_date_any,121),char(39),','
,char(39),convert(varchar(10),max_date_qtr,121),char(39),','
,char(39),convert(varchar(10),max_date_yr,121),char(39),','
,char(39),convert(varchar(10),min_date_any,121),char(39),case when [id]=(select max([id]) from ref_lookup_max_date) then ' ' else ' UNION ALL' end) [code]
from ref_lookup_max_date