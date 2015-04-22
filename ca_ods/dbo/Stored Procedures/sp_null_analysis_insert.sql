
CREATE procedure [dbo].[sp_null_analysis_insert](@TableName nvarchar(255))
as 
BEGIN
DECLARE @DatabaseName NVARCHAR(255)
set  @DatabaseName= DB_NAME()
DECLARE @SchemaName NVARCHAR(255) 
set @SchemaName= N'dbo'
--DECLARE @TableName NVARCHAR(255)
--set @TableName = N'AUTHORIZATION_FACT'



SET NOCOUNT ON

-- Declare the parameters internal to query
DECLARE @SQLString NVARCHAR(MAX)
set @SQLString = N''
DECLARE @ParamDefinition NVARCHAR(MAX)
set  @ParamDefinition= N''

DECLARE @ColumnList TABLE (
ColumnId INT IDENTITY(1,1)
, ColumnName NVARCHAR(255)
, ColumnNullCount INT
, ColumnNullPercentage NUMERIC(10,4)
)

DECLARE @TableRecordCount INT
DECLARE @ColumnNullCount INT
DECLARE @ColumnCount INT 
set @ColumnCount= 0

DECLARE @LoopCounter INT 
set @LoopCounter= 1
DECLARE @ColumnName NVARCHAR(255)

SET @SQLString = 
N'SELECT @TableRecordCount = COUNT(*) FROM ' 
+ @DatabaseName + N'.' + @SchemaName + N'.' + @TableName
SET @ParamDefinition = N'@TableRecordCount INT OUTPUT'
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @TableRecordCount OUTPUT

SET @SQLString = 
N'SELECT COLUMN_NAME FROM ' 
+ @DatabaseName + N'.' + N'INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = @SchemaName
AND TABLE_NAME = @TableName'

SET @ParamDefinition = N'@SchemaName NVARCHAR(255), @TableName NVARCHAR(255)'

INSERT INTO @ColumnList (ColumnName)
EXECUTE sp_executesql @SQLString, @ParamDefinition
, @SchemaName, @TableName

SELECT @ColumnCount = COUNT(*) FROM @ColumnList

WHILE (@LoopCounter <= @ColumnCount)
BEGIN

SELECT @ColumnName = ColumnName 
FROM @ColumnList 
WHERE ColumnId = @LoopCounter

SET @SQLString = 
N'SELECT @ColumnNullCount = COUNT(*) FROM ' 
+ @DatabaseName + N'.' + @SchemaName + N'.' + @TableName 
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
insert into CA_NULL_ANALYSIS (colname,tblname,tblrecordcnt,nullcnt,nullprcnt,load_date)
SELECT 
ColumnName AS [Column Name]
,@TableName as [Table Name]
, @TableRecordCount AS [Table Record Count]
, ColumnNullCount AS [Column Null Count]
, ColumnNullPercentage AS [Column Null Percentage]
,CA_DATA_LOADED.date_loaded
FROM @ColumnList
join CA_DATA_LOADED on cast(CA_DATA_LOADED.tbl_name as nvarchar(200))=@TableName
ORDER BY ColumnNullCount desc  ,[Column Name]

END


--select * from CA_NULL_ANALYSIS where tblname=@TableName;
