USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_intakes]    Script Date: 6/9/2014 1:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [base].[prod_update_tbl_intakes] (@permission_key datetime)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

  update base.tbl_intakes
   set [fl_ooh_after_this_referral] = 1 
  from base.tbl_intakes intk 
  where exists (select *
							from base.rptPlacement rpt
							where intk.id_intake_fact= rpt.id_intake_fact
							and rpt.id_intake_fact is not null);

update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_update_tbl_intakes'

 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end




 