

create function [dbo].[fnc_datediff_ss](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

-- Count of full seconds between dates. A full second requires a full 1000 milliseconds.
--DECLARE @BEGIN_DATE DATETIME = '2008-12-02 21:38:43.597'
--	,@END_DATE DATETIME = '2008-12-02 21:38:44.730'

DECLARE @diff int

IF @END_DATE < @BEGIN_DATE
begin
	DECLARE @TEMP_DATE DATETIME = @END_DATE
	SET @END_DATE = @BEGIN_DATE
	SET @BEGIN_DATE = @TEMP_DATE
end

IF datepart(ms,@END_DATE) < datepart(ms,@BEGIN_DATE)

	SET @diff = datediff(ss,@BEGIN_DATE,@END_DATE) - 1

ELSE

	SET @diff = datediff(ss,@BEGIN_DATE,@END_DATE)

--PRINT @diff
RETURN @diff

end




