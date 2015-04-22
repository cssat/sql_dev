

CREATE function [dbo].[fnc_datediff_mis](@BEGIN_DATE datetime,@END_DATE datetime)
returns int
begin

-- Count of full minutes between dates. A full minute requires a full 60 seconds.
--DECLARE @BEGIN_DATE DATETIME = '2008-12-02 21:38:44.997'
--	,@END_DATE DATETIME = '2008-12-02 21:36:43.730'

DECLARE @diff int

IF @END_DATE < @BEGIN_DATE
begin
	DECLARE @TEMP_DATE DATETIME = @END_DATE
	SET @END_DATE = @BEGIN_DATE
	SET @BEGIN_DATE = @TEMP_DATE
end

IF datepart(ss,@END_DATE) < datepart(ss,@BEGIN_DATE)

	SET @diff = datediff(mi,@BEGIN_DATE,@END_DATE) - 1

ELSE

	SET @diff = datediff(mi,@BEGIN_DATE,@END_DATE)

--PRINT @diff
RETURN @diff

end




--GO


