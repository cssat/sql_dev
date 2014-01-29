USE [CA_ODS]
GO
/****** Object:  StoredProcedure [dbo].[load_update_calendar_dim]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[load_update_calendar_dim]
as 

update calendar_dim
set state_fiscal_day_of_year_name=state_fiscal_day_of_quarter

update calendar_dim
set state_fiscal_day_of_quarter = cast(replace(state_fiscal_day_of_quarter_Name,'Day ','') as int)

GO
