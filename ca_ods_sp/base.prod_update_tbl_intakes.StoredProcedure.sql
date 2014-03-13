USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_update_tbl_intakes]    Script Date: 3/6/2014 11:27:39 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [base].[prod_update_tbl_intakes] (@permission_key datetime)
as
if @permission_key = (select cutoff_date from dbo.ref_Last_DW_Transfer) 
begin

  
if object_id('tempDB..#temp') is not null drop table #temp;
SELECT  intk.[id_intake_fact]
      ,intk.[id_case]
      ,[id_investigation_assessment_fact]
      ,[id_safety_assessment_fact]
      ,[rfrd_date]
      ,[inv_ass_start]
      ,[inv_ass_stop]
      ,[screen_in_spvr_dcsn_dt]
      ,[invs_level2_approved]
      ,[cd_access_type]
      ,[tx_access_type]
      ,[cd_invs_type]
      ,[tx_invs_type]
      ,[cd_invs_disp]
      ,[tx_invs_disp]
      ,[close_id_assgn_fact]
      ,[close_assgn_begin_dt]
      ,[close_assgn_end_dt]
      ,[close_assgn_cd_rmts_wrkr_type]
      ,[close_assgn_tx_rmts_wrkr_type]
      ,[cd_spvr_rsn]
      ,[tx_spvr_rsn]
      ,[cd_final_decision]
      ,[tx_final_decision]
      ,[cd_asgn_type]
      ,[tx_asgn_type]
      ,[cd_asgn_rspns]
      ,[tx_asgn_rspns]
      ,[cd_reporter]
      ,[tx_reporter]
      ,[id_people_dim_hh]
      ,[id_prsn_hh]
      ,[pk_gndr]
      ,intk.[dt_birth]
      ,intk.[is_current]
      ,intk.[cd_race_census]
      ,intk.[census_hispanic_latino_origin_cd]
      ,[cd_sib_age_grp]
      ,[cd_office]
      ,[tx_office]
      ,[cd_region]
      ,[fl_ihs_90_day]
      ,[fl_phys_abuse]
      ,[fl_sexual_abuse]
      ,[fl_neglect]
      ,[fl_other_maltreatment]
      ,[fl_allegation_any]
      ,[fl_founded_phys_abuse]
      ,[fl_founded_sexual_abuse]
      ,[fl_founded_neglect]
      ,[fl_founded_other_maltreatment]
      ,[fl_founded_any_legal]
      ,[fl_prior_phys_abuse]
      ,[fl_prior_sexual_abuse]
      ,[fl_prior_neglect]
      ,[fl_prior_other_maltreatment]
      ,[fl_prior_allegation_any]
      ,[fl_founded_prior_phys_abuse]
      ,[fl_founded_prior_sexual_abuse]
      ,[fl_founded_prior_neglect]
      ,[fl_founded_prior_other_maltreatment]
      ,[fl_founded_prior_any_legal]
      ,[fl_hh_is_mother]
      ,[fl_cps_invs]
      ,[fl_cfws]
      ,[fl_risk_only]
      ,[fl_alternate_intervention]
      ,[fl_frs]
      ,[fl_reopen_case]
      ,[fl_dlr]
      ,[cnt_children_at_intake]
      ,[first_intake_date]
      ,[latest_intake_date]
      ,[nbr_intakes]
      ,[nbr_cps_intakes]
      ,[intake_rank]
      ,[fl_ooh_prior_this_referral]
      ,case when tce.id_intake_fact is not null then 1 else 0 end as [fl_ooh_after_this_referral]
      ,[case_nxt_intake_dt]
	into #temp
  from base.tbl_intakes intk 
  left join (select distinct id_intake_fact from base.tbl_child_episodes tce where id_intake_fact is not null) tce on tce.id_intake_fact=intk.id_intake_fact


truncate table base.tbl_intakes
insert into base.tbl_intakes
select * from #temp

	 
 end
 else
 begin 
	print 'NEED PERMISSION KEY TO EXECUTE STORED PROCEDURE'
 end




 