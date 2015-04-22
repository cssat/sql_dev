CREATE procedure [dbo].[load_update_calendar_dim]
as 

-- update statistics calendar_dim
update calendar_dim
set state_fiscal_day_of_year_name=state_fiscal_day_of_quarter


update calendar_dim
set state_fiscal_day_of_quarter = cast(replace(state_fiscal_day_of_quarter_Name,'Day ','') as int)


