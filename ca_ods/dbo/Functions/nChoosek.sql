
--n choose k combinations
CREATE function [dbo].[nChoosek](@k int,@n int) RETURNS bigint
begin
DECLARE @combinations bigint
DECLARE @set TABLE (value int);

declare @counter int
if @n> 20 return null

set @counter=1
while @counter <=@n
		begin
			INSERT into @set 
				select @counter;
				set @counter = @counter + 1;
				
		end
set @combinations  = dbo.Factorial(@n) / (dbo.Factorial(@k) * dbo.Factorial(@n - @k));
return @combinations

end