USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_intakes_after_ihs]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [base].[prod_update_tbl_intakes_after_ihs]
(@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin


	update base.tbl_intakes
	set fl_ihs_90_day=0

	update base.tbl_intakes
	set fl_ihs_90_day=1
	from base.tbl_ihs_episodes eps
	where eps.id_intake_fact=tbl_intakes.id_intake_fact
	and days_from_rfrd_date <=90
end	
GO
