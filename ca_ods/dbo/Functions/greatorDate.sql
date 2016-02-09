CREATE FUNCTION [dbo].[greatorDate] (
	@date1 AS DATETIME
	,@date2 AS DATETIME
	)
RETURNS DATETIME
AS
BEGIN
	DECLARE @myDate DATETIME;

	IF @date1 >= @date2
		SET @myDate = @date1
	ELSE
		SET @myDate = @date2;

	RETURN @myDate;
END
