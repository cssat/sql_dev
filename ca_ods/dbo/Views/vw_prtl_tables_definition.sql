create view dbo.vw_prtl_tables_definition
as 
select  distinct c2.*,q.ORDINAL_POSITION,q.COLUMN_NAME,q.DATA_TYPE,q.CHARACTER_MAXIMUM_LENGTH 
from INFORMATION_SCHEMA.COLUMNs c
join  (select distinct c.table_name,max(c.ordinal_position) [nbr_columns],row_number() over (order by c.table_name) [tbl_id]
from INFORMATION_SCHEMA.COLUMNs c
where c.TABLE_SCHEMA='prtl'  and (charindex('pbc',c.table_name) > 0 or  charindex('poc',c.table_name) > 0) and charindex('obs_',c.table_name)=0
and charindex('_bkp',c.table_name)=0
group by c.table_name
 ) c2 on c2.TABLE_NAME=c.TABLE_NAME 
join (select distinct table_name,(ordinal_position) ,COLUMN_NAME,DATA_TYPE,c.CHARACTER_MAXIMUM_LENGTH
			from INFORMATION_SCHEMA.COLUMNs c
			where c.TABLE_SCHEMA='prtl'  and (charindex('pbc',table_name) > 0 or  charindex('poc',table_name) > 0) and charindex('obs_',table_name)=0
			and charindex('_bkp',table_name)=0
			) q on q.TABLE_NAME=c.TABLE_NAME
where c.TABLE_SCHEMA='prtl'  and (charindex('pbc',c.table_name) > 0 or  charindex('poc',c.table_name) > 0) and charindex('obs_',c.table_name)=0
and charindex('_bkp',c.table_name)=0