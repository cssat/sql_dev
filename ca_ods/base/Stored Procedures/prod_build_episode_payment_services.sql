
	CREATE procedure [base].[prod_build_episode_payment_services] (@permission_key datetime)
	as
	set nocount on;
		if @permission_key=(select cutoff_date from dbo.ref_Last_DW_Transfer)
		begin
		if object_id(N'base.episode_payment_services') is not null truncate table base.episode_payment_services
		insert into base.episode_payment_services    ([id_prsn_child]
				   ,[id_removal_episode_fact]
				   ,[id_case]
				   ,[min_id_payment_fact]
				   ,[max_id_payment_fact]
				   ,[min_svc_begin_date]
				   ,[max_svc_end_date]
				   ,[nbr_services]
				   ,[fl_family_focused_services]
				   ,[fl_child_care]
				   ,[fl_therapeutic_services]
				   ,[fl_mh_services]
				   ,[fl_receiving_care]
				   ,[fl_family_home_placements]
				   ,[fl_behavioral_rehabiliation_services]
				   ,[fl_other_therapeutic_living_situations]
				   ,[fl_specialty_adolescent_services]
				   ,[fl_respite]
				   ,[fl_transportation]
				   ,[fl_clothing_incidentals]
				   ,[fl_sexually_aggressive_youth]
				   ,[fl_adoption_support]
				   ,[fl_various]
				   ,[fl_medical]
				   ,fl_ihs_reun
				   ,fl_concrete_goods
				   ,[fl_budget_C12]
				   ,[fl_budget_C14]
				   ,[fl_budget_C15]
				   ,[fl_budget_C16]
				   ,[fl_budget_C18]
				   ,[fl_budget_C19]
				   ,[fl_uncat_svc]
				   ,[cnt_family_focused_services]
				   ,[cnt_child_care]
				   ,[cnt_therapeutic_services]
				   ,[cnt_mh_services]
				   ,[cnt_receiving_care]
				   ,[cnt_family_home_placements]
				   ,[cnt_behavioral_rehabiliation_services]
				   ,[cnt_other_therapeutic_living_situations]
				   ,[cnt_specialty_adolescent_services]
				   ,[cnt_respite]
				   ,[cnt_transportation]
				   ,[cnt_clothing_incidentals]
				   ,[cnt_sexually_aggressive_youth]
				   ,[cnt_adoption_support]
				   ,[cnt_various]
				   ,[cnt_medical]
				   ,cnt_ihs_reun
				   ,cnt_concrete_goods
				   ,[cnt_budget_C12]
				   ,[cnt_budget_C14]
				   ,[cnt_budget_C15]
				   ,[cnt_budget_C16]
				   ,[cnt_budget_C18]
				   ,[cnt_budget_C19]
				   ,[cnt_uncat_svc]
				   ,[amt_pd_family_focused_services]
				   ,[amt_pd_child_care]
				   ,[amt_pd_therapeutic_services]
				   ,[amt_pd_mh_services]
				   ,[amt_pd_receiving_care]
				   ,[amt_pd_family_home_placements]
				   ,[amt_pd_behavioral_rehabiliation_services]
				   ,[amt_pd_other_therapeutic_living_situations]
				   ,[amt_pd_specialty_adolescent_services]
				   ,[amt_pd_respite]
				   ,[amt_pd_transportation]
				   ,[amt_pd_clothing_incidentals]
				   ,[amt_pd_sexually_aggressive_youth]
				   ,[amt_pd_adoption_support]
				   ,[amt_pd_various]
				   ,[amt_pd_medical]
				   ,amt_pd_ihs_reun
				   ,amt_pd_concrete_goods
				   ,[amt_pd_budget_C12]
				   ,[amt_pd_budget_C14]
				   ,[amt_pd_budget_C15]
				   ,[amt_pd_budget_C16]
				   ,[amt_pd_budget_C18]
				   ,[amt_pd_budget_C19]
				   ,[amt_pd_uncat_svc]
				   ,[total_paid])
		SELECT [id_prsn_child]
					,[id_removal_episode_fact]
					, id_case
					,min([id_payment_fact]) as min_id_payment_fact
					,max(id_payment_fact) as max_id_payment_fact
					,min(svc_begin_date) as min_svc_begin_date
					,max(isnull(svc_end_date,'12/31/3999')) as max_svc_end_date
					,count(distinct id_payment_fact) as nbr_services
					, max(case when cd_subctgry_poc_frc=1 then 1 else 0 end) as fl_family_focused_services
					, max(case when cd_subctgry_poc_frc=2 then 1 else 0 end) as fl_child_care
					, max(case when cd_subctgry_poc_frc=3 then 1 else 0 end) as fl_therapeutic_services
					, max(case when cd_subctgry_poc_frc=4 then 1 else 0 end) as fl_mh_services
					, max(case when cd_subctgry_poc_frc=5 then 1 else 0 end) as fl_receiving_care
					, max(case when cd_subctgry_poc_frc=6 then 1 else 0 end) as fl_family_home_placements
					, max(case when cd_subctgry_poc_frc=7 then 1 else 0 end) as fl_behavioral_rehabiliation_services
					, max(case when cd_subctgry_poc_frc=8 then 1 else 0 end) as fl_other_therapeutic_living_situations
					, max(case when cd_subctgry_poc_frc=9 then 1 else 0 end) as fl_specialty_adolescent_services
					, max(case when cd_subctgry_poc_frc=10 then 1 else 0 end) as fl_respite
					, max(case when cd_subctgry_poc_frc=11 then 1 else 0 end) as fl_transportation
					, max(case when cd_subctgry_poc_frc=12 then 1 else 0 end) as fl_clothing_incidentals
					, max(case when cd_subctgry_poc_frc=13 then 1 else 0 end) as fl_sexually_aggressive_youth
					, max(case when cd_subctgry_poc_frc=14 then 1 else 0 end) as fl_adoption_support
					, max(case when cd_subctgry_poc_frc=15 then 1 else 0 end) as fl_various
					, max(case when cd_subctgry_poc_frc=16 then 1 else 0 end) as fl_medical
					, max(case when cd_subctgry_poc_frc=17 then 1 else 0 end) as fl_ihs_reun
					, max(case when cd_subctgry_poc_frc=18 then 1 else 0 end) as fl_concrete_goods
					, max(case when cd_budget_poc_frc=12 then 1 else 0 end) as fl_budget_C12
					, max(case when cd_budget_poc_frc=14 then 1 else 0 end) as fl_budget_C14
					, max(case when cd_budget_poc_frc=15 then 1 else 0 end) as fl_budget_C15
					, max(case when cd_budget_poc_frc=16 then 1 else 0 end) as fl_budget_C16
					, max(case when cd_budget_poc_frc=18 then 1 else 0 end) as fl_budget_C18
					, max(case when cd_budget_poc_frc=19 then 1 else 0 end) as fl_budget_C19
					, max(case when cd_budget_poc_frc=99 then 1 else 0 end) as fl_uncat_svc
					, sum(case when cd_subctgry_poc_frc=1 then 1 else 0 end) as cnt_family_focused_services
					, sum(case when cd_subctgry_poc_frc=2 then 1 else 0 end) as cnt_child_care
					, sum(case when cd_subctgry_poc_frc=3 then 1 else 0 end) as cnt_therapeutic_services
					, sum(case when cd_subctgry_poc_frc=4 then 1 else 0 end) as cnt_mh_services
					, sum(case when cd_subctgry_poc_frc=5 then 1 else 0 end) as cnt_receiving_care
					, sum(case when cd_subctgry_poc_frc=6 then 1 else 0 end) as cnt_family_home_placements
					, sum(case when cd_subctgry_poc_frc=7 then 1 else 0 end) as cnt_behavioral_rehabiliation_services
					, sum(case when cd_subctgry_poc_frc=8 then 1 else 0 end) as cnt_other_therapeutic_living_situations
					, sum(case when cd_subctgry_poc_frc=9 then 1 else 0 end) as cnt_specialty_adolescent_services
					, sum(case when cd_subctgry_poc_frc=10 then 1 else 0 end) as cnt_respite
					, sum(case when cd_subctgry_poc_frc=11 then 1 else 0 end) as cnt_transportation
					, sum(case when cd_subctgry_poc_frc=12 then 1 else 0 end) as cnt_clothing_incidentals
					, sum(case when cd_subctgry_poc_frc=13 then 1 else 0 end) as cnt_sexually_aggressive_youth
					, sum(case when cd_subctgry_poc_frc=14 then 1 else 0 end) as cnt_adoption_support
					, sum(case when cd_subctgry_poc_frc=15 then 1 else 0 end) as cnt_various
					, sum(case when cd_subctgry_poc_frc=16 then 1 else 0 end) as cnt_medical
					,sum(case when cd_subctgry_poc_frc=17 then 1 else 0 end) as cnt_ihs_reun
					,sum(case when cd_subctgry_poc_frc=18 then 1 else 0 end) as cnt_concrete_goods
					, sum(case when cd_budget_poc_frc=12 then 1 else 0 end) as cnt_budget_C12
					, sum(case when cd_budget_poc_frc=14 then 1 else 0 end) as cnt_budget_C14
					, sum(case when cd_budget_poc_frc=15 then 1 else 0 end) as cnt_budget_C15
					, sum(case when cd_budget_poc_frc=16 then 1 else 0 end) as cnt_budget_C16
					, sum(case when cd_budget_poc_frc=18 then 1 else 0 end) as cnt_budget_C18
					, sum(case when cd_budget_poc_frc=19 then 1 else 0 end) as cnt_budget_C19
					, sum(case when cd_budget_poc_frc=99 then 1 else 0 end) as cnt_uncat_svc
					, sum(case when cd_subctgry_poc_frc=1 then total_paid else 0 end) as amt_pd_family_focused_services
					, sum(case when cd_subctgry_poc_frc=2 then total_paid else 0 end) as amt_pd_child_care
					, sum(case when cd_subctgry_poc_frc=3 then total_paid else 0 end) as amt_pd_therapeutic_services
					, sum(case when cd_subctgry_poc_frc=4 then total_paid else 0 end) as amt_pd_mh_services
					, sum(case when cd_subctgry_poc_frc=5 then total_paid else 0 end) as amt_pd_receiving_care
					, sum(case when cd_subctgry_poc_frc=6 then total_paid else 0 end) as amt_pd_family_home_placements
					, sum(case when cd_subctgry_poc_frc=7 then total_paid else 0 end) as amt_pd_behavioral_rehabiliation_services
					, sum(case when cd_subctgry_poc_frc=8 then total_paid else 0 end) as amt_pd_other_therapeutic_living_situations
					, sum(case when cd_subctgry_poc_frc=9 then total_paid else 0 end) as amt_pd_specialty_adolescent_services
					, sum(case when cd_subctgry_poc_frc=10 then total_paid else 0 end) as amt_pd_respite
					, sum(case when cd_subctgry_poc_frc=11 then total_paid else 0 end) as amt_pd_transportation
					, sum(case when cd_subctgry_poc_frc=12 then total_paid else 0 end) as amt_pd_clothing_incidentals
					, sum(case when cd_subctgry_poc_frc=13 then total_paid else 0 end) as amt_pd_sexually_aggressive_youth
					, sum(case when cd_subctgry_poc_frc=14 then total_paid else 0 end) as amt_pd_adoption_support
					, sum(case when cd_subctgry_poc_frc=15 then total_paid else 0 end) as amt_pd_various
					, sum(case when cd_subctgry_poc_frc=16 then total_paid else 0 end) as amt_pd_medical
					,sum(case when cd_subctgry_poc_frc=17 then total_paid else 0 end) as amt_ihs_reun
					,sum(case when cd_subctgry_poc_frc=18 then total_paid else 0 end) as amt_concrete_goods
					, sum(case when cd_budget_poc_frc=12 then total_paid else 0 end) as amt_pd_budget_C12
					, sum(case when cd_budget_poc_frc=14 then total_paid else 0 end) as amt_pd_budget_C14
					, sum(case when cd_budget_poc_frc=15 then total_paid else 0 end) as amt_pd_budget_C15
					, sum(case when cd_budget_poc_frc=16 then total_paid else 0 end) as amt_pd_budget_C16
					, sum(case when cd_budget_poc_frc=18 then total_paid else 0 end) as amt_pd_budget_C18
					, sum(case when cd_budget_poc_frc=19 then total_paid else 0 end) as amt_pd_budget_C19
					, sum(case when cd_budget_poc_frc=99 then total_paid else 0 end) as amt_pd_uncat_svc
					, sum([total_paid]) as total_paid
		  FROM [base].[placement_payment_services]
		  group by [id_prsn_child]
			  ,[id_removal_episode_fact]
			  , id_case
			 order by id_case,id_removal_episode_fact


			 --select * from ##costs where id_Removal_Episode_fact=126738

			 --select * from base.tbl_child_episode_merge_id mrg where  mrg.merge_episode_id=126738

			 --select entry_date,id_case from base.tbl_child_placement_settings where id_removal_episode_fact=126738

			
update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_build_episode_payment_services' 		

		

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end