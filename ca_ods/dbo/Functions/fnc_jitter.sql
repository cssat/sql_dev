CREATE FUNCTION dbo.fnc_jitter 
(
	@value int
	,@top float
	,@bottom float
)
RETURNS int
AS
BEGIN
	declare @result int;

	select @result = case
		when @value > 0 and round(@value + 2 * sqrt(-2 * log(@top)) * cos(2 * pi() * @bottom),0) < 1
			then 1
		when @value > 0
			then round(@value + 2 * sqrt(-2 * log(@top)) * cos(2 * pi() * @bottom),0)
		else @value
	end;

	return @result;
END
GO

