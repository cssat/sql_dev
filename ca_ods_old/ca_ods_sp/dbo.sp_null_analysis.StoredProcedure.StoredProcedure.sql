
/****** Object:  StoredProcedure [dbo].[sp_null_analysis]    Script Date: 9/16/2014 10:21:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [dbo].[sp_null_analysis](@TableName nvarchar(255))
as 
BEGIN
DECLARE @DatabaseName nvarchar(255)
set  @DatabaseName= DB_NAME()
DECLARE @SchemaName nvarchar(255) 
set @SchemaName= N'dbo'
declare @mytable nvarchar(255)=@tablename
--DECLARE @TableName nvarchar(255)
--set @TableName = N'AUTHORIZATION_FACT'

if CHARINDEX('.',@mytable,1)>0
begin
		set @SchemaName=SUBSTRING(@mytable,1,CHARINDEX('.',@mytable,1)-1)
		set @mytable=SUBSTRING(@mytable,CHARINDEX('.',@mytable,1)+1,len(@mytable)-CHARINDEX('.',@mytable,1))

end

SET NOCOUNT ON

-- Declare the parameters internal to query
DECLARE @SQLString nvarchar(MAX)
set @SQLString = N''
DECLARE @ParamDefinition nvarchar(MAX)
set  @ParamDefinition= N''

DECLARE @ColumnList TABLE (
ColumnId INT IDENTITY(1,1)
, ColumnName nvarchar(255)
, ColumnNullCount INT
, ColumnNullPercentage NUMERIC(10,4)
)

DECLARE @TableRecordCount INT
DECLARE @ColumnNullCount INT
DECLARE @ColumnCount INT 
set @ColumnCount= 0

DECLARE @LoopCounter INT 
set @LoopCounter= 1
DECLARE @ColumnName nvarchar(255)

SET @SQLString = 
N'SELECT @TableRecordCount = COUNT(*) FROM ' 
+ @DatabaseName + N'.' + @SchemaName + N'.' + @mytable
SET @ParamDefinition = N'@TableRecordCount INT OUTPUT'
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @TableRecordCount OUTPUT

SET @SQLString = 
N'SELECT COLUMN_NAME FROM ' 
+ @DatabaseName + N'.' + N'INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = @SchemaName
AND TABLE_NAME = @mytable'

SET @ParamDefinition = N'@SchemaName nvarchar(255), @mytable nvarchar(255)'

INSERT INTO @ColumnList (ColumnName)
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @SchemaName, @mytable

SELECT @ColumnCount = COUNT(*) FROM @ColumnList

WHILE (@LoopCounter <= @ColumnCount)
BEGIN

SELECT @ColumnName = ColumnName 
FROM @ColumnList 
WHERE ColumnId = @LoopCounter

SET @SQLString = 
N'SELECT @ColumnNullCount = COUNT(*) FROM ' 
+ @DatabaseName + N'.' + @SchemaName + N'.' + @mytable 
+ N' WHERE ' + @ColumnName + N' IS NULL'

SET @ParamDefinition = N'@ColumnNullCount INT OUTPUT'

EXECUTE sp_executesql @SQLString, @ParamDefinition
, @ColumnNullCount OUTPUT

UPDATE @ColumnList
SET 
ColumnNullCount = @ColumnNullCount
, ColumnNullPercentage = case when @TableRecordCount > 0 then @ColumnNullCount * 100.0/@TableRecordCount else null end
WHERE ColumnId = @LoopCounter

SET @LoopCounter = @LoopCounter +  1

END

SELECT 
ColumnName AS [Column Name]
,@mytable as [Table Name]
, @TableRecordCount AS [Table Record Count]
, ColumnNullCount AS [Column Null Count]
, ColumnNullPercentage AS [Column Null Percentage]
FROM @ColumnList
ORDER BY ColumnNullCount desc  ,[Column Name]

END


--select * from CA_NULL_ANALYSIS where tblname=@mytable;
