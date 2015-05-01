

create function [dbo].[largerint](@val1 int,@val2 int)
returns int
begin
declare @largestVal int
if @val1 > @val2 set @largestVal=@val1
else set @largestVal=@val2
return @largestVal
end