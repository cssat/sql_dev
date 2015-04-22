
create function [dbo].[lessorDate](@date1 as datetime,@date2 as datetime)
returns datetime
as
begin
	declare @myDate datetime;
	if @date1 <=@date2  set @myDate= @date1
	else set @myDate= @date2;
	
	return @myDate;
end
