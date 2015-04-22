
create function [dbo].[last_complete_qtr]()
returns datetime
as 
begin
declare @max_qtr datetime

set @max_qtr= (select max([Quarter]) from dbo.calendar_dim where dateadd(mm,3,[Quarter]) < dbo.cutoff_date())

return @max_qtr
end
