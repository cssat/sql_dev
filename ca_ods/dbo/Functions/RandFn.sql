
create function [dbo].[RandFn]()
returns DECIMAL(18,18)
as 
begin
declare @randval DECIMAL(18,18)
select @randVal = rndResult from get_random_nbr
return @randval
end
