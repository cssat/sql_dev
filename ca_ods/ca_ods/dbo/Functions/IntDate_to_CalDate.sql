
create function [dbo].[IntDate_to_CalDate](@id_calendar_dim integer) returns datetime
 begin
	declare @myDate as datetime
	set @myDate = null
	if @id_calendar_dim between 19000101 and 29991231
	begin
		set  @myDate=convert(datetime,cast(@id_calendar_dim as varchar(8)),112)
		
	end
	return @myDate
end
