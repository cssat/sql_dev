
create Function [dbo].[Factorial]
(@n bigINT)
RETURNS bigint
BEGIN 
	IF @n <= 0 RETURN 1
	RETURN @n * dbo.Factorial(@n-1)

END