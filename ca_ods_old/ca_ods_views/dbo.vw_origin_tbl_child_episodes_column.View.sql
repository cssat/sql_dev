USE [CA_ODS]
GO
/****** Object:  View [dbo].[vw_origin_tbl_child_episodes_column]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_origin_tbl_child_episodes_column]
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
GO
