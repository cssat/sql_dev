USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[sys_get_dependencies]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[sys_get_dependencies](@schema_with_tbl_name varchar(max))
as
SELECT referencing_schema_name, referencing_entity_name, referencing_id, referencing_class_desc, is_caller_dependent
FROM sys.dm_sql_referencing_entities (@schema_with_tbl_name, 'OBJECT');
GO
