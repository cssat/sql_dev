CREATE FUNCTION [dbo].[lessorDate3] (
	@date1 AS DATETIME
	,@date2 AS DATETIME
	,@date3 AS DATETIME
	)
RETURNS DATETIME
AS
BEGIN
	DECLARE @myDate DATETIME;

	IF @date1 <= @date2 AND @date1 <= @date3
		SET @myDate = @date1
	ELSE IF @date2 <= @date3
		SET @myDate = @date2
	ELSE
		SET @myDate = @date3;

	RETURN @myDate;
END
