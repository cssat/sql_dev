create view dbo.vw_column_source_rptPlacement
as 

select TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,ORDINAL_POSITION,DATA_TYPE,c.CHARACTER_MAXIMUM_LENGTH,c.IS_NULLABLE 
,case when ORDINAL_POSITION > 115 then 'poc' else 'ca' end as column_source
from INFORMATION_SCHEMA.columns c where c.TABLE_SCHEMA='base'
and c.TABLE_NAME='rptPlacement'
