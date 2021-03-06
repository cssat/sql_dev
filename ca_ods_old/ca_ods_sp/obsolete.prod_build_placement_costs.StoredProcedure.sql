USE [CA_ODS]
GO
/****** Object:  StoredProcedure [obsolete].[prod_build_placement_costs]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create procedure [obsolete].[prod_build_placement_costs] (@permission_key datetime)
	as

		if @permission_key=(select cutoff_date from dbo.ref_Last_DW_Transfer)
		begin	 if OBJECT_ID(N'base.placement_costs',N'U') is not null truncate table base.placement_costs
			 insert into base.placement_costs
			 select   
					  pps.id_prsn_child
					, pps.entry_date_int
					, pps.exit_date_int
					, pps.entry_date
					, pps.exit_date
					, pps.removal_county_cd
					, pps.removal_county
					, pps.placement_provider_caregiver_county_code
					, pps.placement_provider_caregiver_county
					, pps.placement_provider_caregiver_id
					, pps.placement_setting_type_code
					, pps.placement_setting_type
					, pps.cd_epsd_type
					, pps.tx_epsd_type
					, pps.placement_end_reason_code
					, pps.placement_end_reason
					, pps.placement_discharge_reason_code
					, pps.placement_discharge_reason
					, pps.placement_care_auth_cd
					, pps.placement_care_auth
					, pps.placement_care_auth_tribe_cd
					, pps.placement_care_auth_tribe
					, pps.trial_return_home_cd
					, pps.trial_return_home
					, pps.trh_begin_date
					, pps.trh_end_date
					, pps.cd_srvc
					, pps.tx_srvc
					, pps.id_plcmnt_evnt
					, pps.cd_plcmnt_evnt
					, pps.id_removal_episode_fact
					, pps.id_placement_fact
					, pps.dur_days
					, pps.fl_dur_7
					, pps.fl_dur_90
					, pps.plcm_rank
					, pps.plcm_total
					, pps.plcm_ooh_rank
					, pps.plcm_ooh_total
					, pps.fl_close
					, pps.fl_lst_ooh_plcm
					, pps.fl_lst_plcm
					, pps.eps_plcm_sort_asc
					, pps.id_case
					, pps.child_age_plcm_begin
					, pps.child_age_plcm_end
					, sum(pps.fl_primary_srvc) as cnt_primary
					, sum(case when pps.fl_primary_srvc=0 then 1 else 0 end) as cnt_nonprimary_svc
					, sum(case when pps.fl_primary_srvc=1 then pps.total_paid else 0 end) as total_paid_primary_services
					, sum(case when pps.fl_primary_srvc=0 then pps.total_paid else 0 end) as total_paid_not_primary
					, sum(pps.total_paid * 1.00)
			from base.placement_payment_services pps
			group by 	  pps.id_prsn_child
					, pps.entry_date_int
					, pps.exit_date_int
					, pps.entry_date
					, pps.exit_date
					, pps.removal_county_cd
					, pps.removal_county
					, pps.placement_provider_caregiver_county_code
					, pps.placement_provider_caregiver_county
					, pps.placement_provider_caregiver_id
					, pps.placement_setting_type_code
					, pps.placement_setting_type
					, pps.cd_epsd_type
					, pps.tx_epsd_type
					, pps.placement_end_reason_code
					, pps.placement_end_reason
					, pps.placement_discharge_reason_code
					, pps.placement_discharge_reason
					, pps.placement_care_auth_cd
					, pps.placement_care_auth
					, pps.placement_care_auth_tribe_cd
					, pps.placement_care_auth_tribe
					, pps.trial_return_home_cd
					, pps.trial_return_home
					, pps.trh_begin_date
					, pps.trh_end_date
					, pps.cd_srvc
					, pps.tx_srvc
					, pps.id_plcmnt_evnt
					, pps.cd_plcmnt_evnt
					, pps.id_removal_episode_fact
					, pps.id_placement_fact
					, pps.dur_days
					, pps.fl_dur_7
					, pps.fl_dur_90
					, pps.plcm_rank
					, pps.plcm_total
					, pps.plcm_ooh_rank
					, pps.plcm_ooh_total
					, pps.fl_close
					, pps.fl_lst_ooh_plcm
					, pps.fl_lst_plcm
					, pps.eps_plcm_sort_asc
					, pps.id_case
					, pps.child_age_plcm_begin
					, pps.child_age_plcm_end
		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
GO
