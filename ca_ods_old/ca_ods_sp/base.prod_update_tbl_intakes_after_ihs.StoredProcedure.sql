USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_intakes_after_ihs]    Script Date: 6/4/2014 1:45:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [base].[prod_update_tbl_intakes_after_ihs]
(@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin


	update base.tbl_intakes
	set fl_ihs_90_day=0
	where fl_ihs_90_day <>0;

	

	update intk
	set fl_ihs_90_day=1
	from base.tbl_ihs_episodes eps
	join base.tbl_intakes intk
	on eps.id_intake_fact=intk.id_intake_fact
	where  days_from_rfrd_date <=90
	and intk.id_case>0;
end	