
CREATE function [dbo].[last_complete_month]()
returns datetime
as 
begin
declare @max_mo datetime

set @max_mo= (select (max([Month])) from dbo.calendar_dim where dateadd(mm,1,[Month]) < dbo.cutoff_date())

return @max_mo
end
