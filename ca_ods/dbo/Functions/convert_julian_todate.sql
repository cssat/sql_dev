
create function [dbo].[convert_julian_todate] (@myjuliandate nvarchar(7))
returns datetime
begin
declare @mydate datetime
set @mydate=dateadd(dd,(cast(right(@myjuliandate,3) as int) -1) ,(convert(datetime,left(@myjuliandate,4) + '-01-01',121)))
return @mydate
end