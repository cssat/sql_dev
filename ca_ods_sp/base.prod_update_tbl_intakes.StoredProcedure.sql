USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_intakes]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [base].[prod_update_tbl_intakes] (@permission_key datetime)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

  set nocount on
  update intk
  set intk.fl_ooh_after_this_referral=0
  from base.tbl_intakes intk 

  update intk
  set intk.fl_ooh_after_this_referral=1
  from base.tbl_intakes intk 
  join base.tbl_child_episodes tce on tce.id_intake_fact=intk.id_intake_fact
  where tce.id_intake_fact is not null
	 
 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end

GO
