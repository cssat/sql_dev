CREATE FUNCTION [prtl].[fnc_jitter] (
	@value INT
	,@top FLOAT
	,@bottom FLOAT
	)
RETURNS INT
AS
BEGIN
	DECLARE @result INT;

	SELECT @result = CASE 
			WHEN @value > 0 AND ROUND(@value + 2 * SQRT(- 2 * LOG(@top)) * COS(2 * PI() * @bottom), 0) < 1
				THEN 1
			WHEN @value > 0
				THEN ROUND(@value + 2 * SQRT(- 2 * LOG(@top)) * COS(2 * PI() * @bottom), 0)
			ELSE @value
			END;

	RETURN @result;
END
GO
