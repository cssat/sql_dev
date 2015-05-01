

create function [dbo].[bomonth](@myDate datetime)
returns datetime
-- this function returns first day of month
begin
declare @first_of_month datetime
set @first_of_month= DATEADD(month, DATEDIFF(month, 0, @myDate), 0)

return @first_of_month
end