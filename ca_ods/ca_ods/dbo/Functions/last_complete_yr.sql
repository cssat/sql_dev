
CREATE function [dbo].[last_complete_yr]()
returns datetime
as 
begin
declare @max_yr datetime

set @max_yr= (select max([Year]) from dbo.calendar_dim where dateadd(yy,1,[Year]) < dbo.cutoff_date())

return @max_yr
end
