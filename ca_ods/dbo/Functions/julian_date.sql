
create function [dbo].[julian_date](@mydate datetime) returns int
begin
declare @strdate nvarchar(7)
declare @julian int
set @strdate= DATENAME(YEAR, @mydate) + RIGHT('00' + DATENAME(DAYOFYEAR, @mydate), 3)
set @julian=convert(int,@strdate)
return @julian
end