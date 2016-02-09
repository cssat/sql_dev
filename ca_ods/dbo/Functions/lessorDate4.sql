CREATE FUNCTION [dbo].[lessorDate4] (
	@date1 AS DATETIME
	,@date2 AS DATETIME
	,@date3 AS DATETIME
	,@date4 AS DATETIME
	)
RETURNS DATETIME
AS
BEGIN
	DECLARE @myDate DATETIME;

	IF @date1 <= @date2 AND @date1 <= @date3 AND @date1 <= @date4
		SET @myDate = @date1
	ELSE IF @date2 <= @date3 AND @date2 <= @date4
		SET @myDate = @date2
	ELSE IF @date3 <= @date4
		SET @myDate = @date3
	ELSE
		SET @myDate = @date4;

	RETURN @myDate;
END
