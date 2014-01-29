USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_placement_payment_services]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE procedure [base].[prod_build_placement_payment_services] (@permission_key datetime)
	as

		if @permission_key=(select cutoff_date from dbo.ref_Last_DW_Transfer)
		begin
			if OBJECT_ID(N'base.placement_payment_services',N'U') is not null drop table  base.placement_payment_services
			CREATE TABLE [base].[placement_payment_services](
				[id_prsn_child] [int] NULL,
				[entry_date_int] [int] NULL,
				[exit_date_int] [int] NULL,
				[entry_date] [datetime] NOT NULL,
				[exit_date] [datetime] NULL,
				[removal_county_cd] [int] NULL,
				[removal_county] [varchar](255) NULL,
				[placement_provider_caregiver_county_code] [int] NOT NULL,
				[placement_provider_caregiver_county] [varchar](200) NULL,
				[placement_provider_caregiver_id] [int] NULL,
				[placement_setting_type_code] [int] NOT NULL,
				[placement_setting_type] [varchar](200) NULL,
				[cd_epsd_type] [int] NULL,
				[tx_epsd_type] [varchar](200) NULL,
				[placement_end_reason_code] [int] NULL,
				[placement_end_reason] [varchar](200) NULL,
				[placement_discharge_reason_code] [int] NULL,
				[placement_discharge_reason] [varchar](200) NULL,
				[placement_care_auth_cd] [int] NULL,
				[placement_care_auth] [varchar](200) NULL,
				[placement_care_auth_tribe_cd] [int] NULL,
				[placement_care_auth_tribe] [varchar](200) NULL,
				[trial_return_home_cd] [int] NOT NULL,
				[trial_return_home] [varchar](1) NOT NULL,
				[trh_begin_date] [datetime] NULL,
				[trh_end_date] [datetime] NULL,
				[cd_srvc] [int] NULL,
				[tx_srvc] [varchar](40) NULL,
				[id_plcmnt_evnt] [int] NOT NULL,
				[cd_plcmnt_evnt] [varchar](3) NULL,
				[id_removal_episode_fact] [int] NOT NULL,
				[id_placement_fact] [int] NOT NULL,
				[dur_days] [int] NULL,
				[fl_dur_7] [smallint] NULL,
				[fl_dur_90] [smallint] NULL,
				[plcm_rank] [int] NULL,
				[plcm_total] [int] NULL,
				[plcm_ooh_rank] [int] NULL,
				[plcm_ooh_total] [int] NULL,
				[fl_close] [smallint] NULL,
				[fl_lst_ooh_plcm] [int] NOT NULL,
				[fl_lst_plcm] [int] NOT NULL,
				[eps_plcm_sort_asc] [int] NOT NULL,
				[id_case] [int] NULL,
				[child_age_plcm_begin] [int] NULL,
				[child_age_plcm_end] [int] NULL,
				[id_payment_fact] [int] NULL,
				[svc_begin_date] [date] NULL,
				[svc_end_date] [date] NULL,
				[pymt_cd_srvc] [int] NULL,
				[pymt_tx_srvc] [varchar](200) NULL,
				[fl_primary_srvc] [int] NULL,
				[srvc_match] [int] NULL,
				[prov_match] [int] NULL,
				[rate][decimal](18,6) NULL,
				[unit][decimal](18,6) NULL,
				[total_paid] [decimal](18, 2) NULL,
				[cd_budget_poc_frc] int ,
				[tx_budget_poc_frc] varchar(200),
				[cd_subctgry_poc_frc] int,
				[tx_subctgry_poc_frc] varchar(200),
				[fl_plc_svc] int,
			--	tx_program_index varchar(10),
				[fl_dup_payment] [int] NULL,
			) ON [PRIMARY]

	/*******  STEP 1   match person provider cd_srvc dates  ******************************************************/
	begin tran step1
			insert into base.placement_payment_services
			select distinct 
					  tcps.id_prsn_child
					, tcps.entry_date_int
					, tcps.exit_date_int
					, tcps.entry_date
					, tcps.exit_date
					, tcps.removal_county_cd
					, tcps.removal_county
					, tcps.placement_provider_caregiver_county_code
					, tcps.placement_provider_caregiver_county
					, tcps.placement_provider_caregiver_id
					, tcps.placement_setting_type_code
					, tcps.placement_setting_type
					, tcps.cd_epsd_type
					, tcps.tx_epsd_type
					, tcps.placement_end_reason_code
					, tcps.placement_end_reason
					, tcps.placement_discharge_reason_code
					, tcps.placement_discharge_reason
					, tcps.placement_care_auth_cd
					, tcps.placement_care_auth
					, tcps.placement_care_auth_tribe_cd
					, tcps.placement_care_auth_tribe
					, tcps.trial_return_home_cd
					, tcps.trial_return_home
					, tcps.trh_begin_date
					, tcps.trh_end_date
					, tcps.cd_srvc
					, tcps.tx_srvc
					, tcps.id_plcmnt_evnt
					, tcps.cd_plcmnt_evnt
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.dur_days
					, tcps.fl_dur_7
					, tcps.fl_dur_90
					, tcps.plcm_rank
					, tcps.plcm_total
					, tcps.plcm_ooh_rank
					, tcps.plcm_ooh_total
					, tcps.fl_close
					, tcps.fl_lst_ooh_plcm
					, tcps.fl_lst_plcm
					, tcps.eps_plcm_sort_asc
					, tcps.id_case
					, tcps.child_age_plcm_begin
					, tcps.child_age_plcm_end
					, pf.id_payment_fact
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)
					, std.cd_srvc
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 1 as srvc_match
					, 1 as prv_match
					, pf.AM_RATE
					, pf.AM_UNITS
					, pf.am_total_paid  as total_paid
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
				--	, pdd.tx_program_index
					, 0
			from base.TBL_CHILD_PLACEMENT_SETTINGS tcps 
			-- FIRST JOIN ON TBL_CHILD_PLACEMENT_SETTINGS CD_SRVC
			 join dbo.payment_fact pf on pf.ID_PRSN_CHILD=tcps.ID_PRSN_CHILD and pf.am_total_paid > 0
				and ((dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) <= isnull(tcps.Exit_Date,'12/31/3999') 
					and isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >=  tcps.Entry_Date )
					--OR
					--(isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = tcps.entry_date 
					--		and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=tcps.entry_date)
					--OR (isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = isnull(tcps.Exit_Date,'12/31/3999') 
					--		and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=isnull(tcps.Exit_Date,'12/31/3999') )
				AND NOT(coalesce(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'1900-01-01')= tcps.entry_date )
					AND NOT(coalesce(dbo.IntDate_to_CalDate(pf.ID_CALENDAR_DIM_SERVICE_BEGIN),'1900-01-01')=tcps.exit_date)							
					)

				and pf.id_provider_dim_service=tcps.placement_provider_caregiver_id
				--left join dbo.payment_detail_fact pdf on pdf.id_payment_fact=pf.id_payment_fact and pdf.fl_active=1 and pdf.am_paid=pf.am_total_paid
				--left join dbo.payment_detail_dim pdd on pdd.id_payment_detail_dim=pdf.id_payment_detail_dim and pdd.is_current=1
				join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM  and tcps.cd_srvc=std.cd_srvc
				join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
				left join base.tbl_ihs_services ihs on ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT
				where ihs.dtl_id_payment_fact is null
		

		


			  update PP 
			  set [fl_dup_payment] = 1
			  from base.placement_payment_services PP
			  join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact,abs(datediff(dd,entry_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact, pps.id_prsn_child,pps.id_removal_episode_fact,pps.eps_plcm_sort_asc,pps.entry_date,pps.exit_date,pps.pymt_cd_srvc,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date,pps.total_paid
					 from  base.placement_payment_services pps
					 join (
							select id_payment_fact,count(*) as cnt
							  from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
		

			commit tran step1;
			begin tran step1a
		
			delete PP from base.placement_payment_services PP where fl_dup_payment=1
			commit tran step1a;


	/*******  STEP 2   		--now match on child dates provider but NOT service  ********************************/
		begin tran step2
			insert into base.placement_payment_services
			select distinct 
					  tcps.id_prsn_child
					, tcps.entry_date_int
					, tcps.exit_date_int
					, tcps.entry_date
					, tcps.exit_date
					, tcps.removal_county_cd
					, tcps.removal_county
					, tcps.placement_provider_caregiver_county_code
					, tcps.placement_provider_caregiver_county
					, tcps.placement_provider_caregiver_id
					, tcps.placement_setting_type_code
					, tcps.placement_setting_type
					, tcps.cd_epsd_type
					, tcps.tx_epsd_type
					, tcps.placement_end_reason_code
					, tcps.placement_end_reason
					, tcps.placement_discharge_reason_code
					, tcps.placement_discharge_reason
					, tcps.placement_care_auth_cd
					, tcps.placement_care_auth
					, tcps.placement_care_auth_tribe_cd
					, tcps.placement_care_auth_tribe
					, tcps.trial_return_home_cd
					, tcps.trial_return_home
					, tcps.trh_begin_date
					, tcps.trh_end_date
					, tcps.cd_srvc
					, tcps.tx_srvc
					, tcps.id_plcmnt_evnt
					, tcps.cd_plcmnt_evnt
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.dur_days
					, tcps.fl_dur_7
					, tcps.fl_dur_90
					, tcps.plcm_rank
					, tcps.plcm_total
					, tcps.plcm_ooh_rank
					, tcps.plcm_ooh_total
					, tcps.fl_close
					, tcps.fl_lst_ooh_plcm
					, tcps.fl_lst_plcm
					, tcps.eps_plcm_sort_asc
					, tcps.id_case
					, tcps.child_age_plcm_begin
					, tcps.child_age_plcm_end
					, pf.id_payment_fact
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)
					, std.cd_srvc
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 1 as prv_match
					, pf.AM_RATE
					, pf.AM_UNITS
					, pf.am_total_paid  as total_paid
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0
			from base.TBL_CHILD_PLACEMENT_SETTINGS tcps 
			 join dbo.payment_fact pf on pf.ID_PRSN_CHILD=tcps.ID_PRSN_CHILD and pf.am_total_paid > 0
				and ((dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) < isnull(tcps.Exit_Date,'12/31/3999') 
					and isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >  tcps.Entry_Date )
					OR
					(isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = tcps.entry_date 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=tcps.entry_date)
					OR (isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = isnull(tcps.Exit_Date,'12/31/3999') 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=isnull(tcps.Exit_Date,'12/31/3999') ))

				and pf.id_provider_dim_service=tcps.placement_provider_caregiver_id
			  join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
			   join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc  and pps.fl_plc_svc=1
			   left join base.placement_payment_services plc on  plc.id_payment_fact=pf.id_payment_fact 
			   left join base.tbl_ihs_services ihs on ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT
			 where plc.id_payment_fact is null and ihs.dtl_id_payment_fact is null
			
  
			update PP 
			  set [fl_dup_payment] = 1
			  from base.placement_payment_services PP
			  join (select distinct 
					row_number() over (partition by pps.id_payment_fact  ,pps.id_prsn_child
						order by pps.id_payment_fact,abs(datediff(dd,entry_date, pps.svc_begin_date)) asc ) as row_num
					,pps.id_payment_fact,pps.id_placement_fact, pps.id_prsn_child,pps.id_removal_episode_fact,pps.eps_plcm_sort_asc,pps.entry_date,pps.exit_date,pps.pymt_cd_srvc,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date,pps.total_paid
					 from  base.placement_payment_services pps 
					 join (
							select id_payment_fact,count(*) as cnt
							  from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
			
		commit  tran step2
		begin tran step2a
			delete PP from base.placement_payment_services PP where fl_dup_payment=1
		commit tran step2a;	


	/*******  STEP 3   		last match child & dates no provider no service ***************************************/
	   begin tran step3
			insert into base.placement_payment_services
			select distinct 
					  tcps.id_prsn_child
					, tcps.entry_date_int
					, tcps.exit_date_int
					, tcps.entry_date
					, tcps.exit_date
					, tcps.removal_county_cd
					, tcps.removal_county
					, tcps.placement_provider_caregiver_county_code
					, tcps.placement_provider_caregiver_county
					, tcps.placement_provider_caregiver_id
					, tcps.placement_setting_type_code
					, tcps.placement_setting_type
					, tcps.cd_epsd_type
					, tcps.tx_epsd_type
					, tcps.placement_end_reason_code
					, tcps.placement_end_reason
					, tcps.placement_discharge_reason_code
					, tcps.placement_discharge_reason
					, tcps.placement_care_auth_cd
					, tcps.placement_care_auth
					, tcps.placement_care_auth_tribe_cd
					, tcps.placement_care_auth_tribe
					, tcps.trial_return_home_cd
					, tcps.trial_return_home
					, tcps.trh_begin_date
					, tcps.trh_end_date
					, tcps.cd_srvc
					, tcps.tx_srvc
					, tcps.id_plcmnt_evnt
					, tcps.cd_plcmnt_evnt
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.dur_days
					, tcps.fl_dur_7
					, tcps.fl_dur_90
					, tcps.plcm_rank
					, tcps.plcm_total
					, tcps.plcm_ooh_rank
					, tcps.plcm_ooh_total
					, tcps.fl_close
					, tcps.fl_lst_ooh_plcm
					, tcps.fl_lst_plcm
					, tcps.eps_plcm_sort_asc
					, tcps.id_case
					, tcps.child_age_plcm_begin
					, tcps.child_age_plcm_end
					, pf.id_payment_fact
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)
					, std.cd_srvc
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 0 as prv_match
					, pf.AM_RATE
					, pf.AM_UNITS
					, pf.am_total_paid  as total_paid
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0
			from base.TBL_CHILD_PLACEMENT_SETTINGS tcps 
			 join dbo.payment_fact pf on pf.ID_PRSN_CHILD=tcps.ID_PRSN_CHILD and pf.am_total_paid > 0
				and ((dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) < isnull(tcps.Exit_Date,'12/31/3999') 
					and isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >  tcps.Entry_Date )
					OR
					(isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = tcps.entry_date 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=tcps.entry_date)
					OR (isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = isnull(tcps.Exit_Date,'12/31/3999') 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=isnull(tcps.Exit_Date,'12/31/3999') ))
			  join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
			   left join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
				left join base.placement_payment_services plc on  plc.id_payment_fact=pf.id_payment_fact 
			 left join base.tbl_ihs_services ihs on ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT
			 where plc.id_payment_fact is null and ihs.dtl_id_payment_fact is null
			
  
			


			  update PP 
			  set [fl_dup_payment] = 1
			  from base.placement_payment_services PP
			  join (select distinct 
					row_number() over (partition by pps.id_payment_fact  
						order by pps.id_payment_fact,eps_plcm_sort_asc asc) as row_num
					,pps.id_payment_fact,pps.id_placement_fact, pps.id_prsn_child,pps.id_removal_episode_fact,pps.eps_plcm_sort_asc,pps.entry_date,pps.exit_date,pps.pymt_cd_srvc,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date,pps.total_paid
					 from  base.placement_payment_services pps
					 join (
							select id_payment_fact,count(*) as cnt
							from  base.placement_payment_services
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					--order by pps.id_payment_fact,[row_num]
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
			
			commit tran step3
			begin tran step3a
			 delete PP from base.placement_payment_services PP where fl_dup_payment=1
			commit tran step3a


			-- get case payments
			begin tran step4
				if object_ID('tempDB..#casepay') is not null drop table #casepay
				CREATE TABLE #casepay(
								[id_prsn_child] [int] NULL,
								[entry_date_int] [int] NULL,
								[exit_date_int] [int] NULL,
								[entry_date] [datetime] NOT NULL,
								[exit_date] [datetime] NULL,
								[removal_county_cd] [int] NULL,
								[removal_county] [varchar](255) NULL,
								[placement_provider_caregiver_county_code] [int] NOT NULL,
								[placement_provider_caregiver_county] [varchar](200) NULL,
								[placement_provider_caregiver_id] [int] NULL,
								[placement_setting_type_code] [int] NOT NULL,
								[placement_setting_type] [varchar](200) NULL,
								[cd_epsd_type] [int] NULL,
								[tx_epsd_type] [varchar](200) NULL,
								[placement_end_reason_code] [int] NULL,
								[placement_end_reason] [varchar](200) NULL,
								[placement_discharge_reason_code] [int] NULL,
								[placement_discharge_reason] [varchar](200) NULL,
								[placement_care_auth_cd] [int] NULL,
								[placement_care_auth] [varchar](200) NULL,
								[placement_care_auth_tribe_cd] [int] NULL,
								[placement_care_auth_tribe] [varchar](200) NULL,
								[trial_return_home_cd] [int] NOT NULL,
								[trial_return_home] [varchar](1) NOT NULL,
								[trh_begin_date] [datetime] NULL,
								[trh_end_date] [datetime] NULL,
								[cd_srvc] [int] NULL,
								[tx_srvc] [varchar](40) NULL,
								[id_plcmnt_evnt] [int] NOT NULL,
								[cd_plcmnt_evnt] [varchar](3) NULL,
								[id_removal_episode_fact] [int] NOT NULL,
								[id_placement_fact] [int] NOT NULL,
								[dur_days] [int] NULL,
								[fl_dur_7] [smallint] NULL,
								[fl_dur_90] [smallint] NULL,
								[plcm_rank] [int] NULL,
								[plcm_total] [int] NULL,
								[plcm_ooh_rank] [int] NULL,
								[plcm_ooh_total] [int] NULL,
								[fl_close] [smallint] NULL,
								[fl_lst_ooh_plcm] [int] NOT NULL,
								[fl_lst_plcm] [int] NOT NULL,
								[eps_plcm_sort_asc] [int] NOT NULL,
								[id_case] [int] NULL,
								[child_age_plcm_begin] [int] NULL,
								[child_age_plcm_end] [int] NULL,
								[id_payment_fact] [int] NULL,
								[svc_begin_date] [date] NULL,
								[svc_end_date] [date] NULL,
								[pymt_cd_srvc] [int] NULL,
								[pymt_tx_srvc] [varchar](200) NULL,
								[fl_primary_srvc] [int] NULL,
								[srvc_match] [int] NULL,
								[prov_match] [int] NULL,
								rate [decimal](18, 6) NULL,
								unit [decimal](18, 6) NULL,
								[total_paid] [decimal](18, 2) NULL,
								[cd_budget_poc_frc] int ,
								[tx_budget_poc_frc] varchar(200),
								[cd_subctgry_poc_frc] int,
								[tx_subctgry_poc_frc] varchar(200),
								[fl_plc_svc] int,
								[fl_dup_payment] [int] NULL)
			
				insert into #casepay							
				select 	  tcps.id_prsn_child
					, tcps.entry_date_int
					, tcps.exit_date_int
					, tcps.entry_date
					, tcps.exit_date
					, tcps.removal_county_cd
					, tcps.removal_county
					, tcps.placement_provider_caregiver_county_code
					, tcps.placement_provider_caregiver_county
					, tcps.placement_provider_caregiver_id
					, tcps.placement_setting_type_code
					, tcps.placement_setting_type
					, tcps.cd_epsd_type
					, tcps.tx_epsd_type
					, tcps.placement_end_reason_code
					, tcps.placement_end_reason
					, tcps.placement_discharge_reason_code
					, tcps.placement_discharge_reason
					, tcps.placement_care_auth_cd
					, tcps.placement_care_auth
					, tcps.placement_care_auth_tribe_cd
					, tcps.placement_care_auth_tribe
					, tcps.trial_return_home_cd
					, tcps.trial_return_home
					, tcps.trh_begin_date
					, tcps.trh_end_date
					, tcps.cd_srvc
					, tcps.tx_srvc
					, tcps.id_plcmnt_evnt
					, tcps.cd_plcmnt_evnt
					, tcps.id_removal_episode_fact
					, tcps.id_placement_fact
					, tcps.dur_days
					, tcps.fl_dur_7
					, tcps.fl_dur_90
					, tcps.plcm_rank
					, tcps.plcm_total
					, tcps.plcm_ooh_rank
					, tcps.plcm_ooh_total
					, tcps.fl_close
					, tcps.fl_lst_ooh_plcm
					, tcps.fl_lst_plcm
					, tcps.eps_plcm_sort_asc
					, tcps.id_case
					, tcps.child_age_plcm_begin
					, tcps.child_age_plcm_end
					, pf.id_payment_fact
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)
					, dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END)
					, std.cd_srvc
					, pps.tx_srvc 
					, pps.fl_prim_plc_svc
					, 0 as srvc_match
					, 1 as prv_match
					, pf.AM_RATE
					, pf.AM_UNITS
					, pf.am_total_paid  as total_paid
					, pps.cd_budget_poc_frc
					, pps.tx_budget_poc_frc
					, pps.cd_subctgry_poc_frc
					, pps.tx_subctgry_poc_frc
					, pps.fl_plc_svc
					, 0 as fl_dup
				from base.TBL_CHILD_PLACEMENT_SETTINGS tcps 
				join dbo.payment_fact pf on pf.ID_CASE=tcps.ID_CASE and pf.am_total_paid > 0 and pf.ID_PRSN_CHILD is null
					and (
					(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN) < isnull(tcps.Exit_Date,'12/31/3999') 
					and isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END) ,'12/31/3999') >  tcps.Entry_Date )
					OR
					(isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = tcps.entry_date 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=tcps.entry_date)
					OR 
					(isnull(dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_END),'12/31/3999')  = isnull(tcps.Exit_Date,'12/31/3999') 
							and dbo.IntDate_to_CalDate( pf.ID_CALENDAR_DIM_SERVICE_BEGIN)=isnull(tcps.Exit_Date,'12/31/3999') ))
				join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM 
				left join base.tbl_ihs_services ihs on ihs.dtl_id_payment_fact=pf.ID_PAYMENT_FACT
				left join dbo.ref_service_category pps on pps.cd_srvc=std.cd_srvc and pps.fl_plc_svc=1
				left join base.placement_payment_services plc on  plc.id_payment_fact=pf.id_payment_fact
				where plc.id_payment_fact is null	and ihs.dtl_id_payment_fact is null

			commit  tran step4
			begin tran step4a
			  update PP 
			  set [fl_dup_payment] = 0
			  from #casepay PP

			  update PP 
			  set [fl_dup_payment] = 1
			  from #casepay PP
			  join (select distinct 
					row_number() over (partition by pps.id_payment_fact  
						order by pps.id_payment_fact,pps.child_age_plcm_begin desc) as row_num		
								,pps.id_payment_fact,pps.id_placement_fact, pps.id_prsn_child,pps.id_removal_episode_fact,pps.eps_plcm_sort_asc,pps.entry_date,pps.exit_date,pps.pymt_cd_srvc,pps.pymt_tx_srvc,pps.svc_begin_date,pps.svc_end_date,pps.total_paid
					 from  #casepay pps
					 join (
							select id_payment_fact,count(*) as cnt
							from  #casepay
							group by id_payment_fact
							having count(*) > 1
							) q on q.id_payment_fact=pps.id_payment_fact
					--order by pps.id_payment_fact,[row_num]
					) qry on qry.id_placement_fact=pp.id_placement_fact
				and qry.id_payment_fact=pp.id_payment_fact
				and qry.row_num > 1
			
				commit tran step4a
				begin tran step4b
				delete PP from #casepay PP where fl_dup_payment=1
				commit tran step4b

			begin tran step5
			insert into base.placement_payment_services
			(id_prsn_child
				,entry_date_int
				,exit_date_int
				,entry_date
				,exit_date
				,removal_county_cd
				,removal_county
				,placement_provider_caregiver_county_code
				,placement_provider_caregiver_county
				,placement_provider_caregiver_id
				,placement_setting_type_code
				,placement_setting_type
				,cd_epsd_type
				,tx_epsd_type
				,placement_end_reason_code
				,placement_end_reason
				,placement_discharge_reason_code
				,placement_discharge_reason
				,placement_care_auth_cd
				,placement_care_auth
				,placement_care_auth_tribe_cd
				,placement_care_auth_tribe
				,trial_return_home_cd
				,trial_return_home
				,trh_begin_date
				,trh_end_date
				,cd_srvc
				,tx_srvc
				,id_plcmnt_evnt
				,cd_plcmnt_evnt
				,id_removal_episode_fact
				,id_placement_fact
				,dur_days
				,fl_dur_7
				,fl_dur_90
				,plcm_rank
				,plcm_total
				,plcm_ooh_rank
				,plcm_ooh_total
				,fl_close
				,fl_lst_ooh_plcm
				,fl_lst_plcm
				,eps_plcm_sort_asc
				,id_case
				,child_age_plcm_begin
				,child_age_plcm_end
				,id_payment_fact
				,svc_begin_date
				,svc_end_date
				,pymt_cd_srvc
				,pymt_tx_srvc
				,fl_primary_srvc
				,srvc_match
				,prov_match
				,rate
				,unit
				,total_paid
				,cd_budget_poc_frc
				,tx_budget_poc_frc
				,cd_subctgry_poc_frc
				,tx_subctgry_poc_frc
				,fl_plc_svc		)
			select 
				 CP.id_prsn_child
				, cp.entry_date_int
				, cp.exit_date_int
				, cp.entry_date
				, cp.exit_date
				, cp.removal_county_cd
				, cp.removal_county
				, cp.placement_provider_caregiver_county_code
				, cp.placement_provider_caregiver_county
				, cp.placement_provider_caregiver_id
				, cp.placement_setting_type_code
				, cp.placement_setting_type
				, cp.cd_epsd_type
				, cp.tx_epsd_type
				, cp.placement_end_reason_code
				, cp.placement_end_reason
				, cp.placement_discharge_reason_code
				, cp.placement_discharge_reason
				, cp.placement_care_auth_cd
				, cp.placement_care_auth
				, cp.placement_care_auth_tribe_cd
				, cp.placement_care_auth_tribe
				, cp.trial_return_home_cd
				, cp.trial_return_home
				, cp.trh_begin_date
				, cp.trh_end_date
				, cp.cd_srvc
				, cp.tx_srvc
				, cp.id_plcmnt_evnt
				, cp.cd_plcmnt_evnt
				, cp.id_removal_episode_fact
				, cp.id_placement_fact
				, cp.dur_days
				, cp.fl_dur_7
				, cp.fl_dur_90
				, cp.plcm_rank
				, cp.plcm_total
				, cp.plcm_ooh_rank
				, cp.plcm_ooh_total
				, cp.fl_close
				, cp.fl_lst_ooh_plcm
				, cp.fl_lst_plcm
				, cp.eps_plcm_sort_asc
				, cp.id_case
				, cp.child_age_plcm_begin
				, cp.child_age_plcm_end
				, cp.id_payment_fact
				, cp.svc_begin_date
				, cp.svc_end_date
				, cp.pymt_cd_srvc
				, cp.pymt_tx_srvc
				, cp.fl_primary_srvc
				, cp.srvc_match
				, cp.prov_match
				, cp.rate
				, cp.unit
				, cp.total_paid
				, cp.cd_budget_poc_frc
				, cp.tx_budget_poc_frc
				, cp.cd_subctgry_poc_frc
				, cp.tx_subctgry_poc_frc
				, cp.fl_plc_svc		
			from #casepay cp
			LEFT JOIN base.placement_payment_services PPS ON PPS.id_payment_fact=CP.id_payment_fact
			WHERE CP.fl_dup_payment = 0 and pps.id_payment_fact is null
			commit tran step5

		
			
			

			----25578 without a primary service  --23834 without services
			--select distinct id_removal_episode_fact from base.TBL_CHILD_PLACEMENT_SETTINGS --where placement_setting_type_code not in  (20,15,3)
			--except
			--select id_removal_episode_Fact from base.placement_payment_services pps --where pps.fl_primary_srvc=1 
		
			--select distinct tcps.placement_setting_type_code,tcps.placement_setting_type,count(*) as cnt
			--from base.TBL_CHILD_PLACEMENT_SETTINGS tcps 
			--left join base.placement_payment_services pps on pps.id_placement_fact=tcps.id_placement_fact
			-- where pps.id_placement_fact is null and tcps.cd_epsd_type = 1
			--		 and tcps.placement_setting_type_code not in (20,15,3)
			--group by tcps.placement_setting_type_code,tcps.placement_setting_type
			--order by count(*) desc
		

		

		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
	






GO
