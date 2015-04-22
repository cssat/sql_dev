
CREATE  procedure [prtl].[prod_build_ooh_point_in_time_child] (@permission_key datetime, @debug smallint = 0) 
as 

set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
	
	
		declare @startDate datetime
		declare @endDate datetime

		declare @int_filter_service_category  int
		declare @filter_service_budget  int
		declare @cutoff_date datetime



		declare @last_qtr_end datetime
		declare @last_year_end datetime
		declare @int_startDate int;
		declare @int_endDate int;

		-- initialize variables
		set @startDate='2000-01-01'
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer
		set @endDate=(select dateadd(dd,-1,[MONTH]) from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_qtr_end=(select [quarter] from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
		set @last_year_end=(select [year] from dbo.CALENDAR_DIM where calendar_date=@cutoff_date)	
				--first pull all episodes into a temp table to clean up dirty data
		set @int_startDate=(select convert(varchar(8),@startDate,112));
		set @int_endDate=(select convert(varchar(8),@endDate,112));
		
		set @int_filter_service_category = 1
		set @filter_service_budget=(select multiplier from dbo.ref_service_cd_budget_poc_frc where cd_budget_poc_frc=0 )

		
			if object_id('tempDB..#qtr') is not null drop table #qtr;
			if object_id('tempDB..#year') is not null drop table #year;

			select distinct [quarter] into #qtr from dbo.Calendar_dim where ID_CALENDAR_DIM between @int_startDate and @int_endDate;
			select distinct [year] into #year from dbo.Calendar_dim where ID_CALENDAR_DIM  between @int_startDate and @int_endDate;
			
			--  first get kids and cohort_dates
			if object_id('tempDB..#kids') is not null drop table #kids
			select child [id_prsn_child]
					,[quarter] [point_in_time_date]
					,eps.id_removal_episode_fact
					, id_placement_fact
					--,evt.removal_dt
					--,evt.discharge_dt
					,eps.removal_dt
					,eps.federal_discharge_date discharge_dt
					,evt.begin_date
					,evt.end_date
					,1 [date_type]
					,2 [qry_type]
					, ROW_NUMBER() over (partition by [quarter],eps.id_removal_episode_fact  order by datediff(dd,evt.begin_date,evt.end_date)  desc,id_placement_fact desc ) [row_num]
					, eps.birth_dt
					, bin_dep_cd
					, 0 [cnt_plcm]
					, 0  [bin_placement_cd]
					, 0  [max_bin_los_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
			-- select * from [ref_filter_access_type]
				, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
							+  fl_dlr * (select cd_multiplier from ref_filter_access_type where fl_name='fl_dlr')
							+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
							+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
							+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
							+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
							+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
							+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					--  select * from ref_filter_allegation
					,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
					+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
					+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
					+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
					+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
					--  select * from ref_filter_finding
					,(select cd_multiplier from ref_filter_finding where cd_finding=0)
					+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
					+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
					+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
					+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
					, pk_gndr
					, cd_race_census
					, census_Hispanic_Latino_Origin_cd
					, init_cd_plcm_setng
					,0 [long_cd_plcm_setng]
					,evt.derived_county [pit_county_cd]
					,cast(null as int) [age_grouping_cd_census]
					,cast(null as int) [age_grouping_cd_mix]
					,datediff(dd,eps.removal_dt,m.[quarter]) + 1  as dur_days
					,cast(null as int) as int_match_param_key_census
					,cast(null as int) as int_match_param_key_mix
					,@int_filter_service_category [int_filter_service_category]
					,@filter_service_budget [filter_service_budget]
					, case 
								when cd_plcm_setng in (1,2,4,5,18) then 1
								when cd_plcm_setng in  (10,11,15) then 3
								when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)  or cd_plcm_setng is null  then 4
							end [plctypc]
					,case 
						when cd_plcm_setng in (1,2,4,5,18) then cast('Family Setting (State Licensed Home)' as varchar(100))
						when cd_plcm_setng in  (10,11,15) then cast('Family Setting (Relative Placement)'as varchar(100))
						when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)   or cd_plcm_setng is null   then cast('Non-Family Setting (Group Home or Other Institution)' as varchar(100))
					end [plctypc_desc]
					, case when cd_plcm_setng in (2,5,10,11,15) and cd_epsd_type=1 then 1 else 0 end [qualevt]
					, case  when cd_plcm_setng in(10,11,15) and cd_epsd_type=1 then 1 else 0 end [kinmark]
					, case when cd_plcm_setng between 1 and 18 then 0 else 1 end as tempevt
					, cd_plcm_setng
					, prtl_cd_plcm_setng
					, 0 as fl_out_trial_return_home
					,evt.cd_end_rsn
					,evt.plcmnt_seq 
					,evt.id_provider_dim_caregiver
					,1 as step_id
			into #kids   
			from prtl.ooh_dcfs_eps eps
			join base.rptPlacement_Events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact 
			join #qtr m on  evt.begin_date <= m.[quarter]
				and evt.end_date >=m.[quarter]
				and eps.removal_dt< m.[quarter] 
				and eps.Federal_Discharge_Date >=m.[quarter]
			 ;

			

			insert into #kids
			select 
					child [id_prsn_child]
					,[year]  [point_in_time_date]
					,eps.id_removal_episode_fact
					, id_placement_fact
					--,evt.removal_dt
					--,evt.discharge_dt
					,eps.removal_dt
					,eps.federal_discharge_date discharge_dt
					,evt.begin_date
					,evt.end_date
					,2[date_type]
					,2 [qry_type]
					, ROW_NUMBER() over (partition by [year],eps.id_removal_episode_fact  order by datediff(dd,evt.begin_date,evt.end_date) desc ,id_placement_fact desc) [row_num]
					, eps.birth_dt
					, bin_dep_cd
					, 0 [cnt_plcm]
					, 0  [bin_placement_cd]
					, 0  [bin_max_los_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					-- select * from [ref_filter_access_type]
					, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
								+  fl_dlr * (select cd_multiplier from ref_filter_access_type where fl_name='fl_dlr')
								+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
								+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
								+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
								+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
								+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
								+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					--  select * from ref_filter_allegation
					--  select * from ref_filter_allegation
					,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
					+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
					+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
					+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
					+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
					--  select * from ref_filter_finding
					,(select cd_multiplier from ref_filter_finding where cd_finding=0)
					+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
					+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
					+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
					+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
					, pk_gndr
					, cd_race_census
					, census_Hispanic_Latino_Origin_cd
					, init_cd_plcm_setng
					,0 [long_cd_plcm_setng]
					,evt.derived_county [pit_county_cd]
					,cast(null as int) [age_grouping_cd_census]
					,cast(null as int) [age_grouping_cd_mix]
					,datediff(dd,eps.removal_dt,m.[year])  + 1 as dur_days
					,cast(null as int) as int_match_param_key_census
					,cast(null as int) as int_match_param_key_mix
					,@int_filter_service_category [int_filter_service_category]
					,@filter_service_budget [filter_service_budget]
					, case 
								when cd_plcm_setng in (1,2,4,5,18) then 1
								when cd_plcm_setng in  (10,11,15) then 3
								when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)  or cd_plcm_setng is null  then 4
							end [plctypc]
					,case 
						when cd_plcm_setng in (1,2,4,5,18) then cast('Family Setting (State Licensed Home)' as varchar(100))
						when cd_plcm_setng in  (10,11,15) then cast('Family Setting (Relative Placement)'as varchar(100))
						when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)   or cd_plcm_setng is null   then cast('Non-Family Setting (Group Home or Other Institution)' as varchar(100))
					end [plctypc_desc]
					, case when cd_plcm_setng in (2,5,10,11,15) and cd_epsd_type=1 then 1 else 0 end [qualevt]
					, case  when cd_plcm_setng in(10,11,15) and cd_epsd_type=1 then 1 else 0 end [kinmark]
					, case when cd_plcm_setng between 1 and 18 then 0 else 1 end as tempevt
					, cd_plcm_setng
					, prtl_cd_plcm_setng
					, 0 as fl_out_trial_return_home
					,evt.cd_end_rsn
					,evt.plcmnt_seq 
					,evt.id_provider_dim_caregiver
					,2 as step_id
			from prtl.ooh_dcfs_eps eps
			join base.rptPlacement_Events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact  
			join #year m on  evt.begin_date <= m.[year]
				and evt.end_date >=m.[year]
				and eps.removal_dt < m.[YEAR]
				and eps.Federal_Discharge_Date >=m.[YEAR]
--  first only
		insert into #kids
			select 
					child [id_prsn_child]
					,[quarter]  [point_in_time_date]
					,eps.id_removal_episode_fact
					, id_placement_fact
					--,evt.removal_dt
					--,evt.discharge_dt
					,eps.removal_dt
					,eps.federal_discharge_date discharge_dt
					,evt.begin_date
					,evt.end_date
					,1 [date_type]
					,1 [qry_type]
					, ROW_NUMBER() over (partition by [quarter],eps.id_removal_episode_fact  order by datediff(dd,evt.begin_date,evt.end_date) desc ,id_placement_fact desc) [row_num]
					, eps.birth_dt
					, bin_dep_cd
					, 0 [cnt_plcm]
					, 0  [bin_placement_cd]
					, 0  [bin_max_los_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					-- select * from [ref_filter_access_type]
				, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
							+  fl_dlr * (select cd_multiplier from ref_filter_access_type where fl_name='fl_dlr')
							+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
							+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
							+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
							+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
							+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
							+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					--  select * from ref_filter_allegation
					,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
					+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
					+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
					+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
					+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
					--  select * from ref_filter_finding
					,(select cd_multiplier from ref_filter_finding where cd_finding=0)
					+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
					+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
					+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
					+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
					, pk_gndr
					, cd_race_census
					, census_Hispanic_Latino_Origin_cd
					, init_cd_plcm_setng
					,0 [long_cd_plcm_setng]
					,evt.derived_county [pit_county_cd]
					,cast(null as int) [age_grouping_cd_census]
					,cast(null as int) [age_grouping_cd_mix]
					,datediff(dd,eps.removal_dt,m.[quarter]) + 1  as dur_days
					,cast(null as int) as int_match_param_key_census
					,cast(null as int) as int_match_param_key_mix
					,@int_filter_service_category [int_filter_service_category]
					,@filter_service_budget [filter_service_budget]
					, case 
								when cd_plcm_setng in (1,2,4,5,18) then 1
								when cd_plcm_setng in  (10,11,15) then 3
								when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)  or cd_plcm_setng is null  then 4
							end [plctypc]
					,case 
						when cd_plcm_setng in (1,2,4,5,18) then cast('Family Setting (State Licensed Home)' as varchar(100))
						when cd_plcm_setng in  (10,11,15) then cast('Family Setting (Relative Placement)'as varchar(100))
						when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)   or cd_plcm_setng is null   then cast('Non-Family Setting (Group Home or Other Institution)' as varchar(100))
					end [plctypc_desc]
					, case when cd_plcm_setng in (2,5,10,11,15) and cd_epsd_type=1 then 1 else 0 end [qualevt]
					, case  when cd_plcm_setng in(10,11,15) and cd_epsd_type=1 then 1 else 0 end [kinmark]
					, case when cd_plcm_setng between 1 and 18 then 0 else 1 end as tempevt
					, cd_plcm_setng
					, prtl_cd_plcm_setng
					, 0 as fl_out_trial_return_home
					,evt.cd_end_rsn
					,evt.plcmnt_seq 
					,evt.id_provider_dim_caregiver
					,3 as step_id
			from prtl.ooh_dcfs_eps eps
			join base.rptPlacement_Events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact  
			join #qtr m on  evt.begin_date <= m.[quarter]
				and evt.end_date >=m.[quarter]
				and eps.removal_dt < m.[quarter]
				and eps.Federal_Discharge_Date >=m.[quarter]
			where eps.removal_dt=first_removal_dt;

			insert into #kids
			select 
					child [id_prsn_child]
					,[year]  [point_in_time_date]
					,eps.id_removal_episode_fact
					, id_placement_fact
					,evt.removal_dt
					--,evt.removal_dt
					--,evt.discharge_dt
					,eps.removal_dt
					,eps.federal_discharge_date discharge_dt
					,evt.end_date
					,2[date_type]
					,1 [qry_type]
					, ROW_NUMBER() over (partition by [year],eps.id_removal_episode_fact  order by datediff(dd,evt.begin_date,evt.end_date) desc ,id_placement_fact desc) [row_num]
					, eps.birth_dt
					, bin_dep_cd
					, 0 [cnt_plcm]
					, 0  [bin_placement_cd]
					, 0  [bin_max_los_cd]
					,[bin_ihs_svc_cd]
					,[cd_reporter_type]
					-- select * from [ref_filter_access_type]
				, (select cd_multiplier from ref_filter_access_type where cd_access_type=0 )
							+  fl_dlr * (select cd_multiplier from ref_filter_access_type where fl_name='fl_dlr')
							+  fl_far * (select cd_multiplier from ref_filter_access_type where fl_name='fl_far')
							+  fl_cps_invs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cps_invs')
							+ fl_alternate_intervention  * (select cd_multiplier from ref_filter_access_type where fl_name='fl_alternate_intervention')
							+ fl_frs * (select cd_multiplier from ref_filter_access_type where fl_name='fl_frs')
							+ fl_risk_only * (select cd_multiplier from ref_filter_access_type where fl_name='fl_risk_only')
							+ fl_cfws * (select cd_multiplier from ref_filter_access_type where fl_name='fl_cfws')   [filter_access_type]
					--  select * from ref_filter_allegation
					--  select * from ref_filter_allegation
					,(select cd_multiplier from ref_filter_allegation where cd_allegation=0)
					+ ( [fl_phys_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_phys_abuse'))
					+ ([fl_sexual_abuse] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_sexual_abuse'))
					+ ([fl_neglect] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_neglect'))
					+ ([fl_any_legal] * (select cd_multiplier from ref_filter_allegation where fl_name='fl_any_legal')) [filter_allegation]
					--  select * from ref_filter_finding
					,(select cd_multiplier from ref_filter_finding where cd_finding=0)
					+ ([fl_founded_phys_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_phys_abuse'))
					+ ([fl_founded_sexual_abuse] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_sexual_abuse'))
					+ ([fl_founded_neglect] * (select cd_multiplier from ref_filter_finding where fl_name='fl_founded_neglect'))
					+ ([fl_found_any_legal] * (select cd_multiplier from ref_filter_finding where fl_name='fl_any_finding_legal')) [filter_finding]
					, pk_gndr
					, cd_race_census
					, census_Hispanic_Latino_Origin_cd
					, init_cd_plcm_setng
					,0 [long_cd_plcm_setng]
					,evt.derived_county [pit_county_cd]
					,cast(null as int) [age_grouping_cd_census]
					,cast(null as int) [age_grouping_cd_mix]
					,datediff(dd,eps.removal_dt,m.[year])  + 1 as dur_days
					,cast(null as int) as int_match_param_key_census
					,cast(null as int) as int_match_param_key_mix
					,@int_filter_service_category [int_filter_service_category]
					,@filter_service_budget [filter_service_budget]
					, case 
								when cd_plcm_setng in (1,2,4,5,18) then 1
								when cd_plcm_setng in  (10,11,15) then 3
								when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)  or cd_plcm_setng is null  then 4
							end [plctypc]
					,case 
						when cd_plcm_setng in (1,2,4,5,18) then cast('Family Setting (State Licensed Home)' as varchar(100))
						when cd_plcm_setng in  (10,11,15) then cast('Family Setting (Relative Placement)'as varchar(100))
						when cd_plcm_setng in (3,6,7,8,9,14,16,-99,12,13,17,19)   or cd_plcm_setng is null   then cast('Non-Family Setting (Group Home or Other Institution)' as varchar(100))
					end [plctypc_desc]
					, case when cd_plcm_setng in (2,5,10,11,15) and cd_epsd_type=1 then 1 else 0 end [qualevt]
					, case  when cd_plcm_setng in(10,11,15) and cd_epsd_type=1 then 1 else 0 end [kinmark]
					, case when cd_plcm_setng between 1 and 18 then 0 else 1 end as tempevt
					, cd_plcm_setng
					, prtl_cd_plcm_setng
					, 0 as fl_out_trial_return_home
					,evt.cd_end_rsn
					,evt.plcmnt_seq 
					,evt.id_provider_dim_caregiver
					,4 as step_id
			from prtl.ooh_dcfs_eps eps
			join base.rptPlacement_Events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact  
			join #year m on  evt.begin_date <= m.[year]
				and evt.end_date >=m.[year]
				and eps.removal_dt < m.[year]
				and eps.Federal_Discharge_Date >=m.[year]
			where first_removal_dt=eps.removal_dt;
	
	
			IF OBJECT_ID (N'debug.kids1', N'U') IS NOT NULL
				DROP TABLE debug.kids1;

			if @debug = 1 select * into debug.kids1 
			from #kids;
			
			-- remove multiple placements keeping longest	
			delete from #kids where row_num > 1;
			
			-- now remove multiple episodes	keeping longest
			delete k
			from #kids k
			join (
					select *, ROW_NUMBER() over (partition by date_type,qry_type,id_prsn_child,point_in_time_date
								order by datediff(dd,removal_dt,discharge_dt) desc) as eps_num
					from #kids
					 ) q on q.eps_num > 1
					 and q.id_prsn_child=k.id_prsn_child
					and q.date_type=k.date_type
					and q.qry_type=k.qry_type
					and q.point_in_time_date=k.point_in_time_date
					and q.id_removal_episode_fact=k.id_removal_episode_fact
	
	-- get point in time placement count & max_bin_los_cd 
		update kids
		set cnt_plcm=q.cnt_plcm
		from #kids kids
		join (
		select k.id_removal_episode_fact,k.id_placement_fact,k.point_in_time_date,count(distinct evt.id_placement_fact) [cnt_plcm]
		from #kids k
		join base.rptPlacement_Events evt on evt.id_removal_episode_fact=k.id_removal_episode_fact
		where evt.begin_date < point_in_time_date
		group by k.id_removal_episode_fact,k.id_placement_fact,k.point_in_time_date )  q
		on q.point_in_time_date=kids.point_in_time_date
		and q.id_placement_fact=kids.id_placement_fact
		and q.id_removal_episode_fact=kids.id_removal_episode_fact



		update #kids
		set bin_placement_cd=q.bin_placement_cd
		from ref_filter_nbr_placement q 
		where q.bin_placement_cd <> 0
		and #kids.cnt_plcm between q.nbr_placement_from and q.nbr_placement_thru


		update kids
		set max_bin_los_cd=q.max_bin_los_cd
		from #kids kids
		join (
		select  point_in_time_date,id_removal_episode_fact,id_placement_fact,max(bin_los_cd) as max_bin_los_cd
		from #kids kids
		join ref_filter_los los on kids.dur_days between los.dur_days_from and  los.dur_days_thru
		group by point_in_time_date,id_removal_episode_fact,id_placement_fact) q
		on q.point_in_time_date=kids.point_in_time_date
		and q.id_placement_fact=kids.id_placement_fact
		and q.id_removal_episode_fact=kids.id_removal_episode_fact


			update k
			set age_grouping_cd_census=census_child_group_cd
			,age_grouping_cd_mix=cdc_census_mix_age_cd
			--select k.birth_dt,k.point_in_time_date,ad.census_child_group_cd,ad.census_child_group_tx
			from #kids k
			join age_dim ad on ad.age_mo=dbo.fnc_datediff_mos(birth_dt,point_in_time_date)		
					
		-- delete kids 18 and over
		delete 		--select id_prsn_child,birth_dt,point_in_time_date
		 from #kids	 where	age_grouping_cd_census = -99

		

		update kds
		set long_cd_plcm_setng=qry.prtl_cd_plcm_setng
		--  select  prtl_cd_plcm_setng,*
		from #kids kds
		join (
		select point_in_time_date
				, pe.id_removal_episode_fact
				, pe.id_placement_fact
				,pe.begin_date
				,pe.end_date
				,prtl_cd_plcm_setng
				,row_number() over (partition by point_in_time_date,pe.id_removal_episode_fact
						order by (datediff(dd,pe.begin_date
							,case when pe.end_date > getdate() 
										then   point_in_time_date   
										else case when pe.end_date < point_in_time_date
												then pe.end_date
												else point_in_time_date
												end  end)) + 1 desc) row_num
		from base.rptPlacement_Events pe
		join (select distinct point_in_time_date, id_removal_episode_fact
					from #kids) kds on kds.id_removal_episode_fact=pe.id_removal_episode_fact
					and pe.begin_date <kds.point_in_time_date 
					) qry
					on qry.row_num=1
					and qry.id_removal_episode_fact=kds.id_removal_episode_fact
					and qry.point_in_time_date=kds.point_in_time_date
		--  where kds.id_removal_episode_fact=75307 order by kds.point_in_time_date;
		
		
		--  update service & budget codes
		update kids
		--set kids.int_filter_service_category=qry.filter_service_category_todate
		--		,kids.filter_service_budget=qry.filter_service_budget_todate
				set kids.int_filter_service_category=xw.int_filter_service_category
				,kids.filter_service_budget=qry.filter_service_budget_todate
		--  select qry.filter_service_budget_todate,qry.filter_service_category_todate,kids.*
		from #kids kids
		join (
				select  max(pps.filter_service_category_todate) over
								(partition by  kids.point_in_time_date,pps.id_placement_fact
									order by pps.svc_begin_date desc) [filter_service_category_todate]
							,max(pps.filter_service_budget_todate) over
								(partition by  point_in_time_date,pps.id_placement_fact
									order by pps.svc_begin_date desc) filter_service_budget_todate
				,kids.id_removal_episode_fact,kids.point_in_time_date,kids.date_type,kids.qry_type
				from #kids kids
				join base.placement_payment_services pps
					on kids.id_placement_fact=pps.id_placement_fact
					and point_in_time_date between svc_begin_date and svc_end_date 
					) qry on qry.point_in_time_date=kids.point_in_time_date
					and qry.date_type=kids.date_type
					and qry.id_removal_episode_fact=kids.id_removal_episode_fact
					and qry.qry_type=kids.qry_type
		join ref_service_category_flag_xwalk xw on xw.filter_service_category=qry.filter_service_category_todate;



		update #kids
		set int_match_param_key_census=	 cast(power(10.0,8) + 
					  (power(10.0,7) * coalesce(age_grouping_cd_census,0)) + 
						(power(10.0,6) * coalesce(cd_race_census,7)) +
							(power(10.0,5) * coalesce(census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(pk_gndr,3)) + 
									(power(10.0,3) * init_cd_plcm_setng) +
										(power(10.0,2) * long_cd_plcm_setng) + 
											(power(10.0,0) * (abs(pit_county_cd))) as decimal(9,0))
			, int_match_param_key_mix=cast(power(10.0,8) + 
					  (power(10.0,7) * coalesce(age_grouping_cd_mix,0)) + 
						(power(10.0,6) * coalesce(cd_race_census,7)) +
							(power(10.0,5) * coalesce(census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(pk_gndr,3)) + 
									(power(10.0,3) * init_cd_plcm_setng) +
										(power(10.0,2) * long_cd_plcm_setng) + 
											(power(10.0,0) * (abs(pit_county_cd))) as decimal(9,0))

			update eps
			set fl_out_trial_return_home=1
			--  select eps.*
			 from #kids eps
			 join  base.rptPlacement_events tcps
					on  eps.id_removal_episode_fact=tcps.id_removal_episode_fact
					and tcps.cd_end_rsn in (38,39,40) -- TRH
					and tcps.plcmnt_seq=eps.plcmnt_seq-1
			where eps.cd_end_rsn = 22
							and eps.id_provider_dim_caregiver <=1


		IF OBJECT_ID (N'debug.kids2', N'U') IS NOT NULL
			DROP TABLE debug.kids2;

		if @debug = 1 select * into debug.kids2
			from #kids;


		if OBJECT_ID(N'prtl.ooh_point_in_time_child',N'U') is not null truncate table  prtl.ooh_point_in_time_child
		INSERT INTO [prtl].[ooh_point_in_time_child]
           ([id_prsn_child]
           ,[point_in_time_date]
           ,[id_removal_episode_fact]
           ,[id_placement_fact]
           ,[removal_dt]
           ,[discharge_dt]
           ,[begin_date]
           ,[end_date]
           ,[date_type]
           ,[qry_type]
           ,[row_num]
           ,[birth_dt]
           ,[bin_dep_cd]
           ,[bin_placement_cd]
           ,[max_bin_los_cd]
           ,[bin_ihs_svc_cd]
           ,[cd_reporter_type]
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[pk_gndr]
           ,[cd_race_census]
           ,[census_Hispanic_Latino_Origin_cd]
           ,[init_cd_plcm_setng]
           ,[long_cd_plcm_setng]
           ,[pit_county_cd]
           ,[age_grouping_cd_census]
           ,[age_grouping_cd_mix]
           ,[dur_days]
           ,[int_match_param_key_census]
           ,[int_match_param_key_mix]
           ,[int_filter_service_category]
           ,[filter_service_budget]
           ,[plctypc]
           ,[plctypc_desc]
           ,[qualevt_w3w4]
           ,[kinmark]
           ,[tempevt]
           ,[cd_plcm_setng]
           ,[curr_prtl_cd_plcm_setng]
		   ,fl_out_trial_return_home)
     		select  [id_prsn_child]
           ,[point_in_time_date]
           ,[id_removal_episode_fact]
           ,[id_placement_fact]
           ,[removal_dt]
           ,[discharge_dt]
           ,[begin_date]
           ,[end_date]
           ,[date_type]
           ,[qry_type]
           ,[row_num]
           ,[birth_dt]
           ,[bin_dep_cd]
           ,[bin_placement_cd]
           ,[max_bin_los_cd]
           ,[bin_ihs_svc_cd]
           ,[cd_reporter_type]
           ,[filter_access_type]
           ,[filter_allegation]
           ,[filter_finding]
           ,[pk_gndr]
           ,[cd_race_census]
           ,[census_Hispanic_Latino_Origin_cd]
           ,[init_cd_plcm_setng]
           ,[long_cd_plcm_setng]
           ,[pit_county_cd]
           ,[age_grouping_cd_census]
           ,[age_grouping_cd_mix]
           ,[dur_days]
           ,[int_match_param_key_census]
           ,[int_match_param_key_mix]
           ,[int_filter_service_category]
           ,[filter_service_budget]
           ,[plctypc]
           ,[plctypc_desc]
           ,[qualevt]
           ,[kinmark]
           ,[tempevt]
           ,[cd_plcm_setng]
           ,[prtl_cd_plcm_setng]
           ,[fl_out_trial_return_home]	from #kids;

		--	

			update statistics prtl.ooh_point_in_time_child;

		update prtl.prtl_tables_last_update
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.ooh_point_in_time_child)
		where tbl_id=46
	
	drop table #kids;
		end
	else
		begin
			print 'NEED PERMISSION KEY TO RUN THIS PROCEDURE'
		end
