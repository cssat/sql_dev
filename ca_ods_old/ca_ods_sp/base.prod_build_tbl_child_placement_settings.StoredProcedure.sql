USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_tbl_child_placement_settings]    Script Date: 1/29/2014 1:56:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [base].[prod_build_tbl_child_placement_settings](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin

		set nocount on
		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from ref_last_DW_Transfer
		if object_ID('tempDB..##plcmnts') is not null drop table ##plcmnts;
		CREATE TABLE ##plcmnts(
				[ID_PRSN_CHILD] [int] NULL,
				[Entry_Date_INT] [int] NULL,
				[Exit_Date_INT] [int] NULL,
				[Entry_Date] [datetime] NULL,
				[Exit_Date] [datetime] NULL,
				[Removal_County_Cd] [int] NULL,
				[Removal_County] [varchar](255) NULL,
				[Placement_Provider_Caregiver_County_Code] [int]  NULL,
				[Placement_Provider_Caregiver_County] [varchar](200) NULL,
				[Placement_Provider_Caregiver_ID] [int] NULL,
				[Placement_Setting_Type_Code] [int]  NULL,
				[Placement_Setting_Type] [varchar](200) NULL,
				[CD_EPSD_TYPE] [int] NULL,
				[TX_EPSD_TYPE] [varchar](200) NULL,
				[Placement_End_Reason_Code] [int] NULL,
				[Placement_End_Reason] [varchar](200) NULL,
				[Placement_Discharge_Reason_Code] [int] NULL,
				[Placement_Discharge_Reason] [varchar](200) NULL,
				[Placement_Care_Auth_Cd] [int] NULL,
				[Placement_Care_Auth] [varchar](200) NULL,
				[Placement_Care_Auth_Tribe_Cd] [int] NULL,
				[Placement_Care_Auth_Tribe] [varchar](200) NULL,
				flg_is_TRH_Exit_Cd [smallint] NOT NULL,
				flg_is_TRH_Exit [varchar](1) NOT NULL,
				trh_begin_date datetime,
				trh_end_date datetime,
				[cd_srvc] [int] NULL,
				[tx_srvc] [varchar](40) NULL,
				[id_plcmnt_evnt] [int]  NULL,
				[cd_plcmnt_evnt] [varchar](3) NULL,
				[id_removal_episode_fact] [int] NOT NULL,
				[id_placement_fact] [int] NOT NULL,
				[dur_days] [int] NULL,
				[fl_dur_7] [smallint] NULL,
				[fl_dur_90] [smallint] NULL,
				[plcm_rank] [int] NULL,
				[plcm_total] [int] NULL,
				[plcm_OOH_rank] [int] NULL,
				[plcm_OOH_total] [int] NULL,
				[fl_close] [smallint] NULL,
				fl_lst_OOH_plcm int not null,
				fl_lst_plcm int not null,
				eps_plcm_sort_asc int,
				eps_plcm_sort_desc int,
				id_case int,
				child_age_plcm_begin int,
				child_age_plcm_end int
				) 

		insert into ##plcmnts
		select 
				  pf.ID_PRSN_CHILD
				, pf.ID_CALENDAR_DIM_BEGIN as Entry_Date_INT
				, pf.id_calendar_dim_end as Exit_Date_INT
				--, Q.exit_date_int as Force_Exit_Date_INT
				, convert(datetime,cast(pf.ID_CALENDAR_DIM_BEGIN as varchar(8)),112) as Entry_Date
				, case when pf.id_calendar_dim_end  <> 0 
						then convert(datetime,cast(pf.
						id_calendar_dim_end  as varchar(8)),112) 
						else null end as Exit_Date
				--, case when Q.exit_date_int <> 0 then convert(datetime,cast(Q.exit_date_int as varchar(8)),112) else null end as Force_Exit_Date
				, ce.Removal_County_Cd 
				, ce.Removal_County  
				, isnull(pd_cg.Cd_PHYS_COUNTY,-99) as Placement_Provider_Caregiver_County_Code
				, case when pd_cg.TX_PHYS_COUNTY ='Failed' then '-' else pd_cg.TX_PHYS_COUNTY  end as Placement_Provider_Caregiver_County
				, pf.ID_PROVIDER_DIM_CAREGIVER as Placement_Provider_Caregiver_ID
				, isnull(ptd.CD_PLCM_SETNG,-99) as Placement_Setting_Type_Code
				, ptd.TX_PLCM_SETNG as Placement_Setting_Type
				, ptd.CD_EPSD_TYPE 
				, ptd.TX_EPSD_TYPE
				, prd.CD_END_RSN as Placement_End_Reason_Code
				, prd.TX_END_RSN as Placement_End_Reason
				, drd.CD_PLCM_DSCH_RSN as Placement_Discharge_Reason_Code
				, drd.TX_PLCM_DSCH_RSN as Placement_Discharge_Reason
				, pcad.CD_PLACEMENT_CARE_AUTH as Placement_Care_Auth_Cd
				, case when pcad.CD_PLACEMENT_CARE_AUTH is null then null else pcad.TX_PLACEMENT_CARE_AUTH end as Placement_Care_Auth
				, pcad.CD_TRIBE as Placement_Care_Auth_Tribe_Cd
				, case when pcad.CD_TRIBE  is null then null else pcad.TX_TRIBE  end as Placement_Care_Auth_Tribe
				, case when prd.CD_END_RSN in (38,39,40) then 1 else 0 end as flg_is_TRH_Exit_Cd
				, case when prd.CD_END_RSN in (38,39,40) then 'Y' else 'N' end as flg_is_TRH_Exit
				, case when pf.id_calendar_dim_end  <> 0 and prd.CD_END_RSN in (38,39,40)
						then convert(datetime,cast(pf.id_calendar_dim_end  as varchar(8)),112) 
						else null end  as trh_begin_date
				, cast(null as datetime) as trh_end_date
				, std.cd_srvc
				, std.tx_srvc
				, case when CD_PLCM_SETNG=1 then 1
					when CD_PLCM_SETNG in (6,8) then 2
					when CD_PLCM_SETNG=2 then 3
					when CD_PLCM_SETNG in (4,7,14,16) then 4
					when CD_PLCM_SETNG in (3,9) then 5
					when CD_PLCM_SETNG=5 then 6
					when CD_PLCM_SETNG =17 then 8
					when CD_PLCM_SETNG in (10,11) then 9
					when CD_PLCM_SETNG in (12,13) then 10
					when CD_PLCM_SETNG =15 then 11
					when CD_PLCM_SETNG =18 then 13
					else 10
				  end as id_plcmnt_evnt
				, cast(null as varchar(3)) as cd_plcmnt_evnt
				, ce.id_removal_episode_fact
				, pf.id_placement_fact
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				,ce.ID_CASE
				,dbo.fnc_datediff_yrs(ce.DT_BIRTH,convert(datetime,cast(pf.ID_CALENDAR_DIM_BEGIN as varchar(8)),112))
				,case when pf.ID_CALENDAR_DIM_END <> 0 and pf.ID_CALENDAR_DIM_END is not null  
					then dbo.fnc_datediff_yrs(ce.DT_BIRTH,convert(datetime,cast(pf.ID_CALENDAR_DIM_END as varchar(8)),112))
					else null end 
		from dbo.placement_fact pf 
		join base.tbl_child_episodes ce 
			on ce.id_prsn_child=pf.id_prsn_child and ce.ID_REMOVAL_EPISODE_FACT=pf.ID_REMOVAL_EPISODE_FACT
		left join dbo.location_dim ld_rpt on ld_rpt.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_PLACEMENT
		left join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM
		left join dbo.provider_dim pd_cg on pd_cg.id_provider_dim=pf.ID_PROVIDER_DIM_CAREGIVER
		left join dbo.placement_result_dim prd on prd.ID_PLACEMENT_RESULT_DIM=pf.ID_PLACEMENT_RESULT_DIM
		left join dbo.PLACEMENT_TYPE_DIM ptd on ptd.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
		left join dbo.DISCHARGE_REASON_DIM drd on drd.ID_DISCHARGE_REASON_DIM=pf.ID_PLACEMENT_DISCHARGE_REASON_DIM
		left join dbo.PLACEMENT_CARE_AUTH_DIM pcad on pcad.ID_PLACEMENT_CARE_AUTH_DIM=pf.ID_PLACEMENT_CARE_AUTH_DIM 
				and pcad.ID_PLACEMENT_CARE_AUTH_DIM >=1
				and pcad.IS_CURRENT=1

	-- merged placements
		insert into ##plcmnts
		select distinct
				  pf.ID_PRSN_CHILD
				, pf.ID_CALENDAR_DIM_BEGIN as Entry_Date_INT
				, pf.id_calendar_dim_end as Exit_Date_INT
				--, Q.exit_date_int as Force_Exit_Date_INT
				, convert(datetime,cast(pf.ID_CALENDAR_DIM_BEGIN as varchar(8)),112) as Entry_Date
				, case when pf.id_calendar_dim_end  <> 0 
						then convert(datetime,cast(pf.
						id_calendar_dim_end  as varchar(8)),112) 
						else null end as Exit_Date
				--, case when Q.exit_date_int <> 0 then convert(datetime,cast(Q.exit_date_int as varchar(8)),112) else null end as Force_Exit_Date
				, ce.Removal_County_Cd 
				, ce.Removal_County  
				, isnull(pd_cg.Cd_PHYS_COUNTY,-99) as Placement_Provider_Caregiver_County_Code
				, case when pd_cg.TX_PHYS_COUNTY ='Failed' then '-' else pd_cg.TX_PHYS_COUNTY  end as Placement_Provider_Caregiver_County
				, pf.ID_PROVIDER_DIM_CAREGIVER as Placement_Provider_Caregiver_ID
				, isnull(ptd.CD_PLCM_SETNG,-99) as Placement_Setting_Type_Code
				, ptd.TX_PLCM_SETNG as Placement_Setting_Type
				, ptd.CD_EPSD_TYPE 
				, ptd.TX_EPSD_TYPE
				, prd.CD_END_RSN as Placement_End_Reason_Code
				, prd.TX_END_RSN as Placement_End_Reason
				, drd.CD_PLCM_DSCH_RSN as Placement_Discharge_Reason_Code
				, drd.TX_PLCM_DSCH_RSN as Placement_Discharge_Reason
				, pcad.CD_PLACEMENT_CARE_AUTH as Placement_Care_Auth_Cd
				, case when pcad.CD_PLACEMENT_CARE_AUTH is null then null else pcad.TX_PLACEMENT_CARE_AUTH end as Placement_Care_Auth
				, pcad.CD_TRIBE as Placement_Care_Auth_Tribe_Cd
				, case when pcad.CD_TRIBE  is null then null else pcad.TX_TRIBE  end as Placement_Care_Auth_Tribe
				, case when prd.CD_END_RSN in (38,39,40) then 1 else 0 end as flg_is_TRH_Exit_Cd
				, case when prd.CD_END_RSN in (38,39,40) then 'Y' else 'N' end as flg_is_TRH_Exit
				, case when pf.id_calendar_dim_end  <> 0 and prd.CD_END_RSN in (38,39,40)
						then convert(datetime,cast(pf.id_calendar_dim_end  as varchar(8)),112) 
						else null end  as trh_begin_date
				, cast(null as datetime) as trh_end_date
				, std.cd_srvc
				, std.tx_srvc
				, case when CD_PLCM_SETNG=1 then 1
					when CD_PLCM_SETNG in (6,8) then 2
					when CD_PLCM_SETNG=2 then 3
					when CD_PLCM_SETNG in (4,7,14,16) then 4
					when CD_PLCM_SETNG in (3,9) then 5
					when CD_PLCM_SETNG=5 then 6
					when CD_PLCM_SETNG =17 then 8
					when CD_PLCM_SETNG in (10,11) then 9
					when CD_PLCM_SETNG in (12,13) then 10
					when CD_PLCM_SETNG =15 then 11
					when CD_PLCM_SETNG =18 then 13
					else 10
				  end as id_plcmnt_evnt
				, cast(null as varchar(3)) as cd_plcmnt_evnt
				, tce.merge_episode_id
				, pf.id_placement_fact
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0
				, 0 
				, mrgCE.ID_CASE
				, dbo.fnc_datediff_yrs(ce.DT_BIRTH,convert(datetime,cast(pf.ID_CALENDAR_DIM_BEGIN as varchar(8)),112))
				, case when pf.ID_CALENDAR_DIM_END <> 0 and pf.ID_CALENDAR_DIM_END is not null  
					then dbo.fnc_datediff_yrs(ce.DT_BIRTH,convert(datetime,cast(pf.ID_CALENDAR_DIM_END as varchar(8)),112))
					else null end 
		from dbo.placement_fact pf 
		join base.tbl_child_episode_merge_id tce on tce.id_removal_episode_fact=pf.id_removal_episode_fact
		-- this is to keep the id_case consistent
		join base.tbl_child_episodes mrgCE on tce.merge_episode_id=mrgCE.id_removal_episode_fact
		join base.tbl_child_episode_orig_data_prior_cleanup ce on ce.id_removal_episode_fact=pf.id_removal_episode_fact and ce.fl_cleanup_type in ('M','N')
		left join dbo.location_dim ld_rpt on ld_rpt.ID_LOCATION_DIM=pf.ID_LOCATION_DIM_PLACEMENT
		left join dbo.service_type_dim std on std.ID_SERVICE_TYPE_DIM=pf.ID_SERVICE_TYPE_DIM
		left join dbo.provider_dim pd_cg on pd_cg.id_provider_dim=pf.ID_PROVIDER_DIM_CAREGIVER
		left join dbo.placement_result_dim prd on prd.ID_PLACEMENT_RESULT_DIM=pf.ID_PLACEMENT_RESULT_DIM
		left join dbo.PLACEMENT_TYPE_DIM ptd on ptd.ID_PLACEMENT_TYPE_DIM=pf.ID_PLACEMENT_TYPE_DIM
		left join dbo.DISCHARGE_REASON_DIM drd on drd.ID_DISCHARGE_REASON_DIM=pf.ID_PLACEMENT_DISCHARGE_REASON_DIM
		left join dbo.PLACEMENT_CARE_AUTH_DIM pcad on pcad.ID_PLACEMENT_CARE_AUTH_DIM=pf.ID_PLACEMENT_CARE_AUTH_DIM 
				and pcad.ID_PLACEMENT_CARE_AUTH_DIM >=1
				and pcad.IS_CURRENT=1
				



			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.ref_lookup_placement_event plc on plc.id_plcmnt_evnt=11
			where  cd_srvc=342 and R.id_plcmnt_evnt=10;




			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.[ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=3
			where  cd_srvc=1758 and R.id_plcmnt_evnt=10;



			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.[ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=10
			where  cd_srvc=245000 and R.id_plcmnt_evnt=10;




			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.[ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=5
			where  cd_srvc=2 



			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.[ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=12
			where  cd_srvc in (405,1768)


			update R
			set id_plcmnt_evnt=plc.id_plcmnt_evnt 
			from ##plcmnts R
			join dbo.[ref_lookup_placement_event]  plc on plc.id_plcmnt_evnt=7
			where  cd_srvc in (1776,1777)
			
			update R
			set cd_plcmnt_evnt=plc.cd_plcmnt_evnt
			from ##plcmnts r
			,dbo.ref_lookup_placement_event plc 
			where R.id_plcmnt_evnt=plc.id_plcmnt_evnt
			
			
			update R
			set eps_plcm_sort_asc = row_num
			from ##plcmnts R
			join (select id_removal_episode_fact,id_placement_fact,entry_date,exit_date,
					row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date asc,exit_date asc,id_placement_fact asc) as row_num
				  from ##plcmnts
				  ) q on q.id_placement_fact=r.id_placement_fact
				  
			update R
			set eps_plcm_sort_desc = row_num
			from ##plcmnts R
			join (select id_removal_episode_fact,id_placement_fact,entry_date,exit_date,
					row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date desc,exit_date desc,id_placement_fact desc) as row_num
				  from ##plcmnts
				  ) q on q.id_placement_fact=r.id_placement_fact
				  
			update R
			set fl_lst_OOH_plcm	=1
			from ##plcmnts r
			cross apply (select top 1 ##plcmnts.id_removal_episode_fact,##plcmnts.id_placement_Fact,##plcmnts.entry_date,##plcmnts.exit_date
						from ##plcmnts
						where cd_epsd_type=1
						and ##plcmnts.id_removal_episode_fact=r.id_removal_episode_fact
						order by ##plcmnts.id_removal_episode_fact,##plcmnts.entry_date desc,##plcmnts.exit_date desc) q
			where q.id_placement_fact=r.id_placement_fact
			
			
			update R
			set fl_lst_plcm	=1
			from ##plcmnts r
			where eps_plcm_sort_desc=1
				  
			update R
			set dur_days = datediff(dd,entry_date,(case when federal_discharge_date is not null 
															and exit_date 
																		> isnull(federal_discharge_date,'12/31/3999') 
															and federal_discharge_date >= entry_date
															then federal_discharge_date 
															else exit_date end)) + 1
			from ##plcmnts r
			left join base.tbl_child_episodes tce
				on tce.id_removal_episode_fact=r.id_removal_episode_fact and tce.federal_discharge_date is not null
			where exit_date is not null 
				and (r.Entry_Date <=tce.federal_discharge_date or tce.federal_discharge_date is null)
				and Entry_Date<=Exit_Date
			 	  
			
			--update R
			--set dur_days=datediff(dd,entry_date,dbo.lessorDate(isnull(federal_discharge_date,'12/31/3999'),@cutoff_date)) + 1
			--from ##plcmnts r
			--left join tbl_child_episodes eps on eps.id_removal_episode_fact=r.id_removal_episode_fact
			--	and federal_discharge_date is not null
			--where R.dur_days =0
			--and exit_date is null;
			
			update R
			set dur_days=datediff(dd,entry_date,dbo.lessorDate(isnull(federal_discharge_date,'12/31/3999'),@cutoff_date)) + 1
			from ##plcmnts r
			left join base.tbl_child_episodes eps on eps.id_removal_episode_fact=r.id_removal_episode_fact
				and federal_discharge_date is not null
			where R.fl_lst_OOH_plcm=1
			and R.dur_days =0
			and exit_date is null
			and  (federal_discharge_date >=r.Entry_Date or federal_discharge_date is null)
			;
			
			
			update R
			set dur_days=datediff(dd,entry_date,dbo.lessorDate(isnull(federal_discharge_date,'12/31/3999'),@cutoff_date)) + 1
			from ##plcmnts r
			left join base.tbl_child_episodes eps on eps.id_removal_episode_fact=r.id_removal_episode_fact
				and federal_discharge_date is not null
			where fl_lst_plcm=1
			and R.dur_days=0
			and exit_date is null
			and  (federal_discharge_date >=r.Entry_Date or federal_discharge_date is null);	
			
		
			
			if object_ID('tempDB..##trh') is not null drop table ##trh
			
			select 
				  ##plcmnts.id_removal_episode_fact
				, id_placement_fact
				, federal_discharge_date
				, exit_date as trh_begin_date
				, cast(null as datetime) as trh_end_date
				, 0 as ret_from_TRH
				, Placement_End_Reason_Code
				, Placement_End_Reason
				, 1 as nbr_trh_this_eps
				, cast(null as int) as nxt_id_placement_fact
				, cast(null as datetime) as nxt_entry_date
				, cast(null as datetime) as nxt_exit_date
				, null as nxt_plcm_stng_type_cd
				, cast(null as char(100)) as nxt_plcm_stng_type
				, cast(null as int) as nxt_tmp_id_placement_fact
				, cast(null as datetime) as nxt_tmp_entry_date
				, cast(null as datetime) as nxt_tmp_exit_date
				, null as nxt_tmp_plcm_stng_type_cd
				, cast(null as char(100)) as nxt_tmp_plcm_stng_type
				, 0 as nbr_tmp_plcmnt_after_trh
				, 0 as nbr_nonttmp_plcmnt_after_trh
				, 0 as nbr_all_plcmnt_after_trh
				, 0 as nxt_tmp_plcmnt_is_TRH
				, cast(null as int) as nxt_cd_srvc
				, cast(null as varchar(50)) as nxt_tx_srvc
				, cast(null as int) as nxt_tmp_cd_srvc
				, cast(null as varchar(50)) as nxt_tmp_tx_srvc
				, cast(null as int) as cnt_tmp_accpt_srvc
				, placement_provider_caregiver_id
				, 0 as nxt_is_tmp
				, fl_lst_plcm
				, fl_lst_ooh_plcm
				, eps_plcm_sort_asc
				, eps_plcm_sort_desc
			into ##trh
			from ##plcmnts
			join base.tbl_child_episodes 
				on tbl_child_episodes.id_removal_episode_fact=##plcmnts.id_removal_episode_fact
			where flg_is_TRH_Exit_Cd=1
			
			-- update the number of trh events 
			-- this is the count of events where flg_is_TRH_Exit_Cd=1
			update ##trh
			set nbr_trh_this_eps=nbr_trh
			from (
					select id_removal_episode_fact,count(*) as nbr_trh from ##trh
					group by id_removal_episode_fact
					having count(*) > 1 )q 
			where  q.id_removal_episode_Fact=##trh.id_removal_episode_Fact
					
			
			-- get the count of  placement events 
			update trh
			set nbr_all_plcmnt_after_trh = cnt_all
				,nbr_nonttmp_plcmnt_after_trh=cnt_nontemp_evt
				,nbr_tmp_plcmnt_after_trh=cnt_temp_evt
				,cnt_tmp_accpt_srvc=q.cnt_tmp_accpt_srvc
			from ##trh trh -- respite, BA/BN
			cross apply (select  tcps.id_removal_episode_fact,count(distinct tcps.id_placement_fact) as cnt_all
							,sum(case when tcps.cd_epsd_type=1 then 1 else 0 end) as cnt_nontemp_evt
							,sum(case when tcps.cd_epsd_type=5 then 1 else 0 end) as cnt_temp_evt
							,sum(case when tcps.cd_srvc in (1771,1776,1777) and tcps.cd_epsd_type=5 then 1 else 0 end) as cnt_tmp_accpt_srvc
						from ##plcmnts tcps
						where tcps.id_removal_episode_fact=trh.id_removal_episode_fact
						and tcps.eps_plcm_sort_asc > trh.eps_plcm_sort_asc
						and tcps.entry_date >=trh.trh_begin_date
						group by tcps.id_removal_episode_fact) q 
						
			-- mark whether next is out of home or temporary placement			
			update trh
			set nxt_is_tmp = q.nxt_plcm
			from ##trh trh
				cross apply (select top 1 tcps.id_removal_episode_fact,tcps.entry_date,tcps.exit_date
						,case when cd_epsd_type=5 then 1 else 0 end as nxt_plcm
						from ##plcmnts tcps
						where tcps.id_removal_episode_fact=trh.id_removal_episode_fact
						and tcps.entry_date >= trh.trh_begin_date
						and tcps.eps_plcm_sort_asc > trh.eps_plcm_sort_asc
						order by tcps.id_removal_episode_fact,tcps.entry_date asc) q	
			
						
			--  get the next placement that is NOT temporary
			--  these are kids returning from a TRH
			-- cd_srvc 
			update trh
			set nxt_id_placement_fact=q.id_placement_fact
			,trh_end_date=q.entry_date
			,nxt_plcm_stng_type=Placement_Setting_Type
			,nxt_plcm_stng_type_cd=Placement_Setting_Type_Code
			,nxt_tx_srvc=tx_srvc
			,nxt_cd_srvc=cd_srvc
			,ret_from_trh=1
			,nxt_entry_date=q.entry_date
			,nxt_exit_date=q.exit_date
			from ##trh trh
			cross apply (select top 1 tcps.id_removal_episode_fact,tcps.entry_date,tcps.exit_date,tcps.id_placement_fact
						,tcps.placement_end_reason_code,Placement_Setting_Type,Placement_Setting_Type_Code
						,tcps.tx_srvc,tcps.cd_srvc ,Placement_Care_Auth_Cd,Placement_Care_Auth
						from ##plcmnts tcps
						where tcps.id_removal_episode_fact=trh.id_removal_episode_fact
						and tcps.entry_date >= trh.trh_begin_date
						and tcps.eps_plcm_sort_asc > trh.eps_plcm_sort_asc
						and (cd_epsd_type=1 )
						order by tcps.id_removal_episode_fact,tcps.entry_date asc) q
						

			

			--  get the next temporary placement		
			update trh
			set nxt_tmp_id_placement_fact=q.id_placement_fact
			,nxt_tmp_plcm_stng_type=Placement_Setting_Type
			,nxt_tmp_plcm_stng_type_cd=Placement_Setting_Type_Code
			,nxt_tmp_tx_srvc=tx_srvc
			,nxt_tmp_cd_srvc=cd_srvc
			,nxt_tmp_entry_date=q.entry_date
			,nxt_tmp_exit_date=q.exit_date
			from ##trh trh	
			cross apply (select top 1 
							tcps.id_removal_episode_fact
							,tcps.entry_date
							,tcps.exit_date
							,tcps.id_placement_fact
							,Placement_Setting_Type
							,Placement_Setting_Type_Code
							,tx_srvc
							,cd_srvc
							,case when cd_epsd_type=5 then 1 else 0 end as nxt_plcm
						from ##plcmnts tcps
						where tcps.id_removal_episode_fact=trh.id_removal_episode_fact
							and tcps.entry_date >= trh.trh_begin_date
							and trh.nxt_is_tmp=1
							and tcps.eps_plcm_sort_asc > trh.eps_plcm_sort_asc
							and tcps.cd_epsd_type=5
						order by tcps.id_removal_episode_fact,tcps.entry_date asc) q	
						
						--select id_removal_episode_Fact,trh_begin_date,trh_end_date,nxt_tx_srvc,nxt_tmp_tx_srvc
						--		,nxt_plcm_stng_type ,nxt_tmp_plcm_stng_type
						--from ##trh 
						--where nxt_tmp_plcm_stng_type is not null
						
						
						--select 	nxt_tmp_tx_srvc,nxt_tmp_plcm_stng_type,count(*) as cnt_tmp,sum(case when trh_end_date is not null then 1 else 0 end) as cnt_trh_end
						--from ##trh	
						--group by nxt_tmp_tx_srvc,nxt_tmp_plcm_stng_type		
						--order by nxt_tmp_tx_srvc	,nxt_tmp_plcm_stng_type	
		
	

			-- if next temporary event is a TRH then end date with beginning of next trh
			update trh
			set trh_end_date=plc.entry_date
			--select trh.*
			from ##trh trh
			join ##plcmnts  plc 
				on plc.id_placement_fact=trh.nxt_tmp_id_placement_fact
					and plc.flg_is_trh_exit_cd=1 and placement_setting_type_code=-99
			where trh.trh_end_date is null and trh.nxt_is_tmp=1;
			
	
	

			-- update to lesser of (exit date, federal discharge date) 
			-- where next temporary  code in (1776,1777)
			update trh
			set trh_end_date=dbo.lessorDate(coalesce(federal_discharge_date,'12/31/3999'),coalesce(exit_date,'12/31/3999'))
			from ##trh trh	
			join ##plcmnts plc 
					on nxt_tmp_id_placement_fact=plc.id_placement_fact  and plc.placement_setting_type_code=-99
			where  plc.cd_srvc in (1776,1777)
			and dbo.lessorDate(coalesce(federal_discharge_date,'12/31/3999'),coalesce(exit_date,'12/31/3999')) <> '12/31/3999'
			and dbo.lessorDate(coalesce(federal_discharge_date,'12/31/3999'),coalesce(exit_date,'12/31/3999')) >=trh.trh_begin_date
			and trh.trh_end_date is null
		
				
			--  update to lesser of (last temporary placement exit date, federal discharge date) 
			-- where remaining temporary placements have cd_srvc in (1771,1776,1777)
			
			update trh
			set trh_end_date= dbo.lessorDate(coalesce(trh.federal_discharge_date,'12/31/3999'),coalesce(p.exit_date,'12/31/3999'))
			from ##trh  trh
			join ##plcmnts p on trh.id_removal_episode_fact=p.id_removal_episode_fact and p.eps_plcm_sort_desc=1
			left join ##trh nxt_trh on nxt_trh.id_removal_episode_fact=trh.id_removal_episode_fact
				and nxt_trh.trh_begin_date > trh.trh_begin_date
			where trh.trh_end_date is null
				and nxt_trh.id_removal_episode_fact is null
				and trh.nbr_tmp_plcmnt_after_trh=trh.cnt_tmp_accpt_srvc
				and trh.cnt_tmp_accpt_srvc=trh.nbr_all_plcmnt_after_trh
				and dbo .lessorDate(coalesce(trh.federal_discharge_date,'12/31/3999'),coalesce(p.exit_date,'12/31/3999')) <> '12/31/3999'
				and dbo.lessorDate(coalesce(trh.federal_discharge_date,'12/31/3999'),coalesce(p.exit_date,'12/31/3999')) >=trh.trh_begin_date
		
	
					
			update trh
			set trh_end_date=federal_discharge_date
			from ##trh trh
			where federal_discharge_date is not null and (fl_lst_plcm=1 or nbr_trh_this_eps=1)
			and trh_End_date is null
			and federal_discharge_date >=trh_begin_date
			
			update trh
			set trh_end_date=federal_discharge_date
			from ##trh trh
			where federal_discharge_date is not null and (fl_lst_ooh_plcm=1  or nbr_trh_this_eps=1)
			and trh_End_date is null
			and federal_discharge_date >=trh_begin_date  

			
			update trh
			set trh_end_date=p.entry_date
			from ##trh trh
			cross apply (select top 1 tcps.id_removal_episode_fact,tcps.entry_date,tcps.exit_date,tcps.id_placement_fact
						,tcps.placement_end_reason_code,Placement_Setting_Type,Placement_Setting_Type_Code
						,tcps.tx_srvc,tcps.cd_srvc ,Placement_Care_Auth_Cd,Placement_Care_Auth,[Placement_Provider_Caregiver_ID],tx_provider_type
						from ##plcmnts tcps
						join dbo.provider_dim on tcps.[Placement_Provider_Caregiver_ID]=id_provider_dim and cd_provider_type in (2,5,6,16,17,20)
						where tcps.id_removal_episode_fact=trh.id_removal_episode_fact
						and tcps.entry_date >= trh.trh_begin_date
						and tcps.eps_plcm_sort_asc > trh.eps_plcm_sort_asc
						and tcps.Placement_Provider_Caregiver_ID <> trh.placement_provider_caregiver_id
						and (cd_epsd_type=5 )
						and [Placement_Provider_Caregiver_ID] > 1
						order by tcps.id_removal_episode_fact,tcps.entry_date asc) p
			where trh.trh_end_date is null
	
	
	
			
			update trh
			set trh_end_date=federal_discharge_date
			from ##trh trh
			where federal_discharge_date is not null and (fl_lst_plcm=0 )
			and trh_End_date is null
			and federal_discharge_date >=trh_begin_date

			
				
			--select * from ##trh where federal_discharge_date is not null and trh_end_date is null
			--and nbr_trh_this_eps>1 and federal_discharge_date > trh_begin_date
			
			--select * from ##plcmnts where id_removal_episode_fact=134121 and (entry_date >='2009-10-13 00:00:00.000'
			--	or flg_is_trh_Exit_cd=1) order by eps_plcm_sort_asc
				
			--select * from ##trh where id_removal_episode_fact=134121  order by trh_begin_date 
				
			--	select * from ##plcmnts where id_removal_episode_fact=124863 and (entry_date >='2009-06-18 00:00:00.000'
			--	or flg_is_trh_Exit_cd=1) order by eps_plcm_sort_asc
		
		
			--	select * from ##plcmnts where id_removal_episode_fact=124863 and (entry_date >='2009-06-18 00:00:00.000'
			--	or flg_is_trh_Exit_cd=1) order by eps_plcm_sort_asc
		
				
			--select * from ##plcmnts where id_removal_episode_fact=97444 and (entry_date >='2006-06-26 00:00:00.000'
			--	or flg_is_trh_Exit_cd=1) order by eps_plcm_sort_asc
				
			--select * from ##trh where id_removal_episode_fact=97444  order by trh_begin_date 
		
		----  now update placements
			
			
			update plc
			set trh_end_date= trh.trh_end_date
			from ##plcmnts plc
			join ##trh trh on trh.id_placement_fact=plc.id_placement_Fact
			
		
			
			update ##plcmnts
			set fl_dur_7 =1
			where  dur_days <=7
			
			
			update ##plcmnts
			set fl_dur_90 =1
			where  dur_days <=90;

			update plc
			set fl_close =1
			from ##plcmnts plc
			left join base.tbl_child_episodes eps on eps.id_removal_episode_fact=plc.id_removal_episode_fact
				and federal_discharge_date is not null
			where coalesce(exit_date,'12/31/3999') <> '12/31/3999' or federal_discharge_date is not null;
			
			
		
			
			update ##plcmnts
			set plcm_total=q.eps_plcm_sort_desc
			from (select id_removal_episode_fact,eps_plcm_sort_desc
					from ##plcmnts
					where eps_plcm_sort_asc=1
					) q 
			where q.id_removal_episode_fact=##plcmnts.id_removal_episode_fact
			
			
			update R
			set plcm_OOH_total=q.row_desc
			from ##plcmnts R
			join (select 
					  id_removal_episode_fact
					, id_placement_fact,entry_date
					, exit_date
					, row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date asc,exit_date asc,id_placement_fact asc) as row_asc
					, row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date desc,exit_date desc,id_placement_Fact desc) as row_desc
				  from ##plcmnts
				  where cd_epsd_type=1
				  ) q on q.id_Removal_episode_fact=r.id_Removal_episode_fact
			and  q.row_asc=1 
				  
			
			-- set rank 1 for both out of home & all
	
			
			
			
		update plc
		set plcm_ooh_rank=row_num
		from ##plcmnts plc
		join (select 
				  id_removal_episode_fact
				, id_placement_fact,entry_date,exit_date
				, rank() over (partition by id_removal_episode_fact
										order by id_removal_episode_fact,entry_date asc,exit_date asc) as row_num
		 from ##plcmnts
		 where cd_epsd_type=1) qry on qry.id_placement_fact=plc.id_placement_fact
	
	
		
		update plc
		set plcm_rank=q.plcm_rank
		from ##plcmnts plc
		join (select id_removal_episode_fact,id_placement_fact,entry_date,exit_date,rank()
				over( partition by id_removal_episode_fact
						order by id_removal_episode_fact,entry_date asc,exit_date asc) as plcm_rank
				from  ##plcmnts  ) q on q.id_placement_fact=plc.id_placement_fact
					
				
				
			
	
		update plc
		set plcm_rank=q.plcm_rank
		from ##plcmnts plc
		cross apply (select pl.id_removal_episode_fact,pl.id_placement_fact,pl.entry_date,pl.exit_date,pl.plcm_rank
					from  ##plcmnts pl 
					where pl.plcm_ooh_rank<> 0
					and pl.id_removal_episode_fact=plc.id_removal_episode_fact
					) q 
		where  plc.cd_epsd_type=5
			and plc.entry_date between q.entry_date and q.exit_date
			and plc.exit_date between q.entry_date and q.exit_date		
					

	 	update plc
		set plcm_rank=q.plcm_rank2
		from ##plcmnts plc
		join (select id_removal_episode_fact,id_placement_fact,plcm_rank,rank()
				over( partition by id_removal_episode_fact
						order by id_removal_episode_fact,plcm_rank asc) as plcm_rank2
				from  ##plcmnts  ) q on q.id_placement_fact=plc.id_placement_fact


		update pl
		set plcm_OOH_rank=0
		--select pl.* 
		from ##plcmnts pl
		join (
		select id_Removal_episode_fact,plcm_OOH_rank,count(*) as cnt from ##plcmnts
		where plcm_OOH_rank <> 0
		group by id_Removal_episode_fact,plcm_OOH_rank
		having count(*) > 1) q on q.id_Removal_episode_fact=pl.id_Removal_episode_fact and q.plcm_OOH_rank=pl.plcm_OOH_rank
		cross apply (select top 1 r.id_Removal_episode_fact,r.id_placement_fact,r.placement_provider_caregiver_id
					from ##plcmnts r
					where q.id_Removal_episode_fact=r.id_Removal_episode_fact and q.plcm_OOH_rank=r.plcm_OOH_rank
					order by r.id_Removal_episode_fact,r.placement_provider_caregiver_id asc) q2 
		where q2.id_placement_fact=pl.id_placement_Fact




		update pl
		set plcm_OOH_rank=q.plcm_ooh_rank
		--select pl.* 
		from ##plcmnts pl
		join ( 
			select id_Removal_episode_fact,id_placement_fact,entry_date ,coalesce(exit_date ,'12/31/3999') as exit_date
					,rank() over (partition by  id_Removal_episode_fact
							order by entry_date asc,coalesce(exit_date ,'12/31/3999') asc) as plcm_ooh_rank 
			from ##plcmnts
			where plcm_OOH_rank <> 0 and cd_epsd_type=1
		) q on q.id_placement_fact=pl.id_placement_fact 
		where pl.plcm_ooh_rank <>q.plcm_ooh_rank
		
			update R
			set plcm_OOH_total=q.row_desc
			from ##plcmnts R
			join (select 
					  id_removal_episode_fact
					, id_placement_fact,entry_date
					, exit_date
					, row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date asc,exit_date asc,id_placement_fact asc) as row_asc
					, row_number() over (partition by id_removal_episode_fact
											order by id_removal_episode_fact,entry_date desc,exit_date desc,id_placement_fact desc) as row_desc
				  from ##plcmnts
				  where cd_epsd_type=1 and plcm_OOH_rank <> 0
				  ) q on q.id_Removal_episode_fact=r.id_Removal_episode_fact
			and  q.row_asc=1 
		
	

		if OBJECT_ID(N'[base].[TBL_CHILD_PLACEMENT_SETTINGS]',N'U')  is not null truncate table base.[TBL_CHILD_PLACEMENT_SETTINGS]	 
		insert into base.TBL_CHILD_PLACEMENT_SETTINGS
		([ID_PRSN_CHILD]
		  ,[Entry_Date_INT]
		  ,[Exit_Date_INT]
		  ,[Entry_Date]
		  ,[Exit_Date]
		  ,[Removal_County_Cd]
		  ,[Removal_County]
		  ,[Placement_Provider_Caregiver_County_Code]
		  ,[Placement_Provider_Caregiver_County]
		  ,[Placement_Provider_Caregiver_ID]
		  ,[Placement_Setting_Type_Code]
		  ,[Placement_Setting_Type]
		  ,[CD_EPSD_TYPE]
		  ,[TX_EPSD_TYPE]
		  ,[Placement_End_Reason_Code]
		  ,[Placement_End_Reason]
		  ,[Placement_Discharge_Reason_Code]
		  ,[Placement_Discharge_Reason]
		  ,[Placement_Care_Auth_Cd]
		  ,[Placement_Care_Auth]
		  ,[Placement_Care_Auth_Tribe_Cd]
		  ,[Placement_Care_Auth_Tribe]
		  ,[Trial_Return_Home_Cd]
		  ,[Trial_Return_Home]
		  ,[trh_begin_date]
		  ,[trh_end_date]
		  ,[cd_srvc]
		  ,[tx_srvc]
		  ,[id_plcmnt_evnt]
		  ,[cd_plcmnt_evnt]
		  ,[id_removal_episode_fact]
		  ,[id_placement_fact]
		  ,[dur_days]
		  ,[fl_dur_7]
		  ,[fl_dur_90]
		  ,[plcm_rank]
		  ,[plcm_total]
		  ,[plcm_OOH_rank]
		  ,[plcm_OOH_total]
		  ,[fl_close]
		  ,[fl_lst_OOH_plcm]
		  ,[fl_lst_plcm]
		  ,[eps_plcm_sort_asc]
		  ,[id_case]
		  ,[child_age_plcm_begin]
		  ,[child_age_plcm_end])
			select 
			  ID_PRSN_CHILD 
			, Entry_Date_INT 
			, Exit_Date_INT 
			, Entry_Date 
			, Exit_Date 
			, Removal_County_Cd 
			, Removal_County
			, Placement_Provider_Caregiver_County_Code 
			, Placement_Provider_Caregiver_County 
			, Placement_Provider_Caregiver_ID 
			, Placement_Setting_Type_Code 
			, Placement_Setting_Type 
			, CD_EPSD_TYPE 
			, TX_EPSD_TYPE 
			, Placement_End_Reason_Code 
			, Placement_End_Reason 
			, Placement_Discharge_Reason_Code 
			, Placement_Discharge_Reason 
			, Placement_Care_Auth_Cd 
			, Placement_Care_Auth 
			, Placement_Care_Auth_Tribe_Cd 
			, Placement_Care_Auth_Tribe 
			, flg_is_trh_exit_cd 
			, flg_is_trh_exit 
			, trh_begin_date 
			, trh_end_date 
			, cd_srvc 
			, tx_srvc 
			, id_plcmnt_evnt 
			, cd_plcmnt_evnt 
			, id_removal_episode_fact 
			, id_placement_fact 
			, dur_days 
			, fl_dur_7 
			, fl_dur_90 
			, plcm_rank 
			, plcm_total 
			, plcm_OOH_rank 
			, plcm_OOH_total 
			, fl_close 
			, fl_lst_OOH_plcm 
			, fl_lst_plcm 
			, eps_plcm_sort_asc 
			, id_case
			, child_age_plcm_begin
			, child_age_plcm_end
		from ##plcmnts
			
	update base.tbl_child_placement_settings 
	set fl_frst_plcm_in_eps=0


		update base.tbl_child_placement_settings 
		set fl_frst_plcm_in_eps=1
		from (select id_Removal_episode_fact,id_placement_fact,entry_date,exit_date
				,row_number() over (partition by id_removal_episode_fact order by entry_date asc,exit_date asc)  as row_num
				from base.tbl_child_placement_settings) q 
		where q.id_placement_fact=tbl_child_placement_settings.id_placement_fact and q.row_num=1

	

 
 
	update statistics base.tbl_child_placement_settings;
		
		
	end
else
begin
	select 'Need permission key to execute this --BUILDS TBL_CHILD_PLACEMENT_SETTINGS!' as [Warning]
end
GO
