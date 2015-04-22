--   select distinct * from vw_QA_ERROR_TABLES


--select * from CA_DATA_LOADED where date_loaded > getdate()-2
--order by tbl_name
create procedure sp_rollback_ca_load_tables
as
delete  CA 
from CA_DATA_LOADED CA
left join (
			select tbl_name,max(date_loaded) as date_loaded
			from CA_DATA_LOADED
			where date_loaded > getdate()-2
			group by tbl_name
			) q on q.date_loaded =ca.date_loaded
			and q.tbl_name=ca.tbl_name
where CA.date_loaded > getdate()-2
and q.tbl_name is null


delete CA
from CA_NULL_ANALYSIS CA
left join (
			select tblname,colname,max(load_date) as load_date
			from CA_NULL_ANALYSIS
			where load_date > getdate()-2
			group by tblname,colname
			) q on q.load_date =ca.load_date
			and q.tblname=ca.tblname
			and q.colname=ca.colname
where ca.load_date	 > getdate()-2
and q.tblname is null	

--select * from CA_NULL_ANALYSIS where load_date > getdate()-2
--order by tblname,colname