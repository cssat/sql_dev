

CREATE function [dbo].[fnc_datediff_ms](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

-- Count of full seconds between dates. A full second requires a full 1000 milliseconds.
--DECLARE @BEGIN_DATE DATETIME = '2008-12-02 21:38:43.597'
--	,@END_DATE DATETIME = '2008-12-02 21:38:44.730'

DECLARE @diff int, @seconds_diff int

IF @END_DATE < @BEGIN_DATE
begin
	DECLARE @TEMP_DATE DATETIME = @END_DATE
	SET @END_DATE = @BEGIN_DATE
	SET @BEGIN_DATE = @TEMP_DATE
end

SET @seconds_diff = dbo.fnc_datediff_ss(@BEGIN_DATE, @END_DATE)

IF @seconds_diff = 0

	SET @diff = ((datepart(ss, @END_DATE) * 1000) + datepart(ms, @END_DATE)) - ((datepart(ss, @BEGIN_DATE) * 1000) + datepart(ms, @BEGIN_DATE))

ELSE

	SET @diff = ((@seconds_diff * 1000) + datepart(ms, @END_DATE)) - datepart(ms, @BEGIN_DATE)
--PRINT @diff
RETURN @diff

end




