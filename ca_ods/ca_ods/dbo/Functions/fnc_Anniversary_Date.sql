CREATE FUNCTION [dbo].[fnc_Anniversary_Date] 
(
	@original_date DATETIME
	,@year_start_date DATETIME
	,@year_end_date DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @anniversary_date DATETIME
		,@original_month TINYINT = MONTH(@original_date)
		,@original_day TINYINT = DAY(@original_date)
		,@year_start_date_id INT = CONVERT(INT, CONVERT(VARCHAR, @year_start_date, 112))
		,@year_end_date_id INT = CONVERT(INT, CONVERT(VARCHAR, @year_end_date, 112))

	SELECT @anniversary_date = MAX(CALENDAR_DATE)
	FROM CALENDAR_DIM
	WHERE MONTH(CALENDAR_DATE) = @original_month
		AND DAY(CALENDAR_DATE) <= @original_day
		AND ID_CALENDAR_DIM BETWEEN @year_start_date_id AND @year_end_date_id

	RETURN @anniversary_date

END
