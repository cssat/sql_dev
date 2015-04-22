

create function [dbo].[fnc_datediff_hrs](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

-- Count of full hours between dates. A full hour requires a full 60 minutes down to the second.
--DECLARE @BEGIN_DATE DATETIME = '2008-12-02 21:36:43.997'
--	,@END_DATE DATETIME = '2009-01-29 07:35:02.730'

DECLARE @diff int

IF @END_DATE < @BEGIN_DATE
begin
	DECLARE @TEMP_DATE DATETIME = @END_DATE
	SET @END_DATE = @BEGIN_DATE
	SET @BEGIN_DATE = @TEMP_DATE
end

IF cast(replace(right(convert(varchar,@END_DATE,8), 5),':','') as int) < cast(replace(right(convert(varchar,@BEGIN_DATE,8), 5),':','') as int)

	SET @diff = datediff(hh,@BEGIN_DATE,@END_DATE) - 1

ELSE

	SET @diff = datediff(hh,@BEGIN_DATE,@END_DATE)

--PRINT @diff
RETURN @diff

end




