
CREATE FUNCTION [dbo].[fnc_p]
(
	@exp  int
)
RETURNS @result TABLE (id int)
AS
BEGIN
	DECLARE @pow int
	SET @pow = POWER(10, @exp)

	INSERT @result
		SELECT 0 id UNION ALL 
		SELECT 1 * @pow UNION ALL
		SELECT 2 * @pow UNION ALL
		SELECT 3 * @pow UNION ALL
		SELECT 4 * @pow UNION ALL
		SELECT 5 * @pow UNION ALL
		SELECT 6 * @pow UNION ALL
		SELECT 7 * @pow UNION ALL
		SELECT 8 * @pow UNION ALL
		SELECT 9 * @pow
	RETURN
END