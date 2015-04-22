create view dbo.vw_origin_tbl_child_episodes_column
as 
SELECT  cu.VIEW_SCHEMA,cu.VIEW_NAME,cu.TABLE_SCHEMA [source_table_schema],cu.TABLE_NAME [source_table_name],cu.COLUMN_NAME [source_column_name],c.ORDINAL_POSITION 
FROM    INFORMATION_SCHEMA.VIEW_COLUMN_USAGE AS cu
JOIN    INFORMATION_SCHEMA.COLUMNS AS c
ON      c.TABLE_SCHEMA  = cu.TABLE_SCHEMA
AND     c.TABLE_CATALOG = cu.TABLE_CATALOG
AND     c.TABLE_NAME    = cu.TABLE_NAME
AND     c.COLUMN_NAME   = cu.COLUMN_NAME
WHERE   cu.VIEW_NAME    = 'tbl_child_episodes'
AND     cu.VIEW_SCHEMA  = 'base'