create procedure dbo.sys_identify_foreignkeys_on_table(@tbl_name varchar(max))
as
declare @mysql varchar(max)='
select t.name as TableWithForeignKey, fk.constraint_column_id as FK_PartNo , c.name as ForeignKeyColumn 
from sys.foreign_key_columns as fk
inner join sys.tables as t on fk.parent_object_id = t.object_id
inner join sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
where fk.referenced_object_id = (select object_id from sys.tables where name = ' + char(39) + @tbl_name + char(39) + ')
order by TableWithForeignKey, FK_PartNo'

execute (@mysql)



