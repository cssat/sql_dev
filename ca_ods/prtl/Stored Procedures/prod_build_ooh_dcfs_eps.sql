-- exec [prtl].[prod_build_ooh_dcfs_eps] '2014-08-08'			
CREATE procedure [prtl].[prod_build_ooh_dcfs_eps] (@permission_key datetime)
as 
set nocount on
if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin
		-- set nocount on
		declare @start_date datetime
		declare @cutoff_date datetime
		select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer	
		set @start_date = '2000-01-01'


			if OBJECT_ID('tempDB..#eps') is not null drop table #eps
			select  distinct
					  cd.[Year]  as cohort_entry_year
					, cd.[Month] as cohort_entry_month
					, cast(null as datetime) as cohort_exit_year
					, cast(null as datetime) as cohort_exit_month
					, rpt.child
					, rpt.id_case
					-- replaced birthdate from rptPlacement as this field is the first of the month following the DOB not the actual DOB
					, pd.dt_birth [birthdate]
					, rpt.id_removal_episode_fact
					, dsch.discharge_type
					, rpt.cd_discharge_type
					, first_removal_dt
					, case when rpt.first_removal_dt=rpt.[removal_dt] then 1 else 0 end as fl_first_removal
					, rpt.removal_dt
					, rpt.removal_dt as orig_removal_dt
					, discharge_dt as federal_discharge_date
					, discharge_dt as orig_federal_discharge_date
					, evt.last_placement_end_date as last_placement_discharge_date
					, (AgeEntry.cdc_census_mix_age_cd) as entry_cdc_census_mix_age_cd
					, ageentry.census_child_group_cd  as entry_census_child_group_cd
					, ageentry.developmental_age_cd as entry_developmental_age_cd
					, cast(null as int) as exit_cdc_census_mix_age_cd
					, cast(null as int) as exit_census_child_group_cd
					, cast(null as int) as exit_developmental_age_cd
					, cast(null as int) as last_plcm_exit_census_mix_age_cd
					, cast(null as int) as last_plcm_exit_census_child_group_cd
					, cast(null as int) as last_plcm_exit_census_developmental
					, 0 as fl_exit_over_17
					, rpt.pk_gndr
					, (coalesce(rpt.cd_race_census,7)) as cd_race_census
					, (coalesce(rpt.census_Hispanic_Latino_Origin_cd,5)) as census_Hispanic_Latino_Origin_cd
					, (rpt.init_cd_plcm_setng) as init_cd_plcm_setng
					, (rpt.long_cd_plcm_setng)  as long_cd_plcm_setng
					, removal_county_cd
					 , evt.derived_county as exit_county_cd
					, (cast(power(10.0,8) + 
					  (power(10.0,7) * coalesce(ageEntry.cdc_census_mix_age_cd,0)) + 
						(power(10.0,6) * coalesce(rpt.cd_race_census,7)) +
							(power(10.0,5) * coalesce(rpt.census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(rpt.pk_gndr,3)) + 
									(power(10.0,3) * rpt.init_cd_plcm_setng) +
										(power(10.0,2) * rpt.long_cd_plcm_setng) + 
											(power(10.0,0) * removal_county_cd) as decimal(9,0))
						) as entry_int_match_param_key_cdc_census_mix
					, (cast(power(10.0,8) + 
					  (power(10.0,7) * coalesce(AgeEntry.census_child_group_cd,0)) + 
						(power(10.0,6) * coalesce(rpt.cd_race_census,7)) +
							(power(10.0,5) * coalesce(rpt.census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(rpt.pk_gndr,3)) + 
									(power(10.0,3) * rpt.init_cd_plcm_setng) +
										(power(10.0,2) * rpt.long_cd_plcm_setng) + 
											(power(10.0,0) * removal_county_cd) as decimal(9,0))
						) as entry_int_match_param_key_census_child_group
					, (cast(power(10.0,8) + 
					  (power(10.0,7) * coalesce(ageentry.developmental_age_cd,0)) + 
						(power(10.0,6) * coalesce(rpt.cd_race_census,7)) +
							(power(10.0,5) * coalesce(rpt.census_Hispanic_Latino_Origin_cd,5)) + 
								(power(10.0,4) * coalesce(rpt.pk_gndr,3)) + 
									(power(10.0,3) * rpt.init_cd_plcm_setng) +
										(power(10.0,2) * rpt.long_cd_plcm_setng) + 
											(power(10.0,0) * removal_county_cd) as decimal(9,0))
						) as entry_int_match_param_key_developmental
					, cast(null as  decimal(9,0)) as  exit_int_match_param_key_cdc_census_mix
					, cast(null as  decimal(9,0)) as  exit_int_match_param_key_census_child_group
					, cast(null as decimal(9,0)) as exit_int_match_param_key_developmental
					, cast(null as  decimal(9,0)) as  plcm_exit_int_match_param_key_cdc_census_mix
					, cast(null as  decimal(9,0)) as  plcm_exit_int_match_param_key_census_child_group
					, cast(null as decimal(9,0)) as plcm_exit_int_match_param_key_developmental
					, (coalesce(rpt.bin_dep_cd,1)) as bin_dep_cd
					, (coalesce(rpt.max_bin_los_cd,0)) as max_bin_los_cd
					, (coalesce(rpt.bin_placement_cd,0)) as bin_placement_cd
					, (coalesce(rpt_intk.collapsed_cd_reporter_type,-99))as cd_reporter_type
					, (coalesce(si.[fl_cps_invs],0)) as fl_cps_invs
					, (coalesce(si.[fl_cfws],0)) as fl_cfws
					, (coalesce(si.[fl_risk_only],0)) as [fl_risk_only]
					, (coalesce(si.[fl_alternate_intervention],0)) as [fl_alternate_intervention]
					, (coalesce(si.[fl_frs],0)) as [fl_frs]
					, coalesce(si.fl_dlr,0) [fl_dlr]
					,coalesce(si.fl_far,0) [fl_far]
					, iif(si.[cnt_intk_grp_phys_abuse] > 0 , 1 , 0) [fl_phys_abuse]
					, iif( si.[cnt_intk_grp_sexual_abuse]  > 0 , 1, 0 )  [fl_sexual_abuse]
					, iif(si.[cnt_intk_grp_neglect]  > 0,1, 0)  [fl_neglect]
					, iif(si.[cnt_intk_grp_phys_abuse]>0
							or si.[cnt_intk_grp_sexual_abuse] > 0
							or  si.[cnt_intk_grp_neglect]  > 0 , 1 , 0 ) [fl_any_legal]
					, iif( si.[cnt_intk_grp_founded_phys_abuse]  > 0 , 1 , 0 )  [fl_founded_phys_abuse]
					, iif( si.[cnt_intk_grp_founded_sexual_abuse]  > 0 , 1 , 0 )  [fl_founded_sexual_abuse]
					, iif( si.[cnt_intk_grp_founded_neglect]  > 0 , 1 , 0 )  [fl_founded_neglect]
					, iif( si.[cnt_intk_grp_founded_any_legal]  > 0 , 1 , 0 ) [fl_found_any_legal]
					, (rpt.bin_ihs_svc_cd) as bin_ihs_svc_cd
--					, (coalesce(nondcfs.CUST_BEGIN,'12/31/9999')) as nonDCFS_Cust_Begin
--					, cast(nondcfs.CUST_End as datetime) as nonDCFS_Cust_End
					, 1 as prsn_cnt
					, rpt.exit_within_month_mult3
					, rpt.nxt_reentry_within_min_month_mult3
					, (case when nondcfs.id_prsn is not null  then 1 else 0 end) as fl_nondcfs_eps
					, (case when nondcfs_eps_within.id_prsn is not null and  nondcfs.id_prsn is null then 1 else 0 end) as fl_nondcfs_within_eps
					, case when nondcfs_overlap.id_prsn is not null and nondcfs.id_prsn is null then 1 else 0 end as fl_nondcfs_overlap_eps
					, (rpt.dependency_dt) as dependency_dt
					, (rpt.fl_dep_exist) as fl_dep_exist
					, 0 as fl_reentry
					, rpt.next_reentry_date
					, child_eps_rank as child_eps_rank_asc
					, cast(null as int) as child_eps_rank_desc
				into #eps  
				from base.rptPlacement rpt
					join dbo.PEOPLE_DIM pd on pd.id_prsn=rpt.child and IS_CURRENT=1
					join dbo.calendar_dim cd on cd.id_calendar_dim=rpt.id_calendar_dim_begin 
					-- get derived county for EXIT cohort (last placement)
					join (select id_placement_fact, id_removal_episode_fact, begin_date, derived_county,end_date as last_placement_end_date
							,row_number() over (partition by id_removal_episode_fact
												order by begin_date desc) as row_num_desc
												from  base.rptPlacement_Events  ) evt on evt.id_removal_episode_fact=rpt.id_removal_episode_fact
													and evt.row_num_desc=1
					left join age_dim AgeEntry on rpt.age_at_removal_mos =AgeEntry.age_mo  
					left join dbo.vw_intakes_screened_in si on si.id_intake_fact=rpt.id_intake_fact
					left join base.tbl_ihs_episodes ihs on ihs.id_intake_fact=rpt.id_intake_fact and ihs.id_case=rpt.id_case
					left join dbo.ref_xwlk_reporter_type rpt_intk on rpt_intk.cd_reporter_type=si.cd_reporter
					left join dbo.ref_lookup_gender G on G.pk_gndr=rpt.pk_gndr
					left join ref_lookup_cd_discharge_type_exits dsch on dsch.cd_discharge_type=rpt.cd_discharge_type
				-- non-DCFS custody start date discharge date within episode
					left join vw_nondcfs_combine_adjacent_segments nondcfs_eps_within on nondcfs_eps_within.ID_PRSN=rpt.child
						and nondcfs_eps_within.CUST_BEGIN between rpt.removal_dt
							and coalesce(rpt.discharge_dt,'12/31/9999')
						and nondcfs_eps_within.CUST_END between rpt.removal_dt
							and coalesce(rpt.discharge_dt,'12/31/9999')
			-- non-DCFS custody overlaps
					left join vw_nondcfs_combine_adjacent_segments nondcfs_overlap on nondcfs_overlap.ID_PRSN=rpt.child
							and nondcfs_overlap.cust_begin < coalesce(rpt.discharge_dt,'12/31/9999')
							and nondcfs_overlap.cust_end > removal_dt
			--   non-DCFS custody concatenate adjacent segments and exclude episodes contained within
					left join vw_nondcfs_combine_adjacent_segments
						 nondcfs  on nondcfs.ID_PRSN=rpt.child
								and nondcfs.cust_begin <= rpt.removal_dt
								and nondcfs.cust_end >= coalesce(rpt.discharge_dt,'12/31/9999')
						-- match on state discharge reason code ... CD_DSCH_RSN
				where --**  select entry cohort
						removal_dt <= coalesce(rpt.discharge_dt,'12/31/9999')
					and ((removal_dt <=@start_date and coalesce(rpt.discharge_dt,'12/31/9999') >=@start_date)
						or removal_dt >=@start_date)
						and rpt.age_at_removal_mos is not null 
						and ageEntry.age_mo < (216)  and  ageEntry.age_mo>=0
						and AgeEntry.cdc_census_mix_age_cd is not null 
					--	and nondcfs_eps_within.ID_PRSN is null
	

	---  discharge 18 and over
		update #eps
		set orig_federal_discharge_date=federal_discharge_date
				,Federal_Discharge_Date=dateadd(yy,18,birthdate)
				,cd_discharge_type=ex.cd_discharge_type
				,discharge_type=ex.discharge_type
--		select  removal_dt,Federal_Discharge_Date ,dateadd(yy,18,birthdate)  	from #eps
		from ref_lookup_cd_discharge_type_exits ex
		where  ex.cd_discharge_type=5
		and ((dateadd(yy,18,birthdate) <  Federal_Discharge_Date and federal_discharge_date<> '12/31/9999' )
		or (dateadd(yy,18,birthdate) < (select cutoff_date from ref_last_dw_transfer) and federal_discharge_date = '12/31/9999' ))
		and dateadd(yy,18,birthdate) > removal_dt

		update rpt
		set	child_eps_rank_desc = q.row_num_desc
		from #eps rpt 
		join (select rpt.*   ,row_number() over (-- only want one episode per cohort_period
						partition by rpt.child
							order by cohort_entry_year asc ,removal_dt desc,federal_discharge_date desc) as row_num_desc
							from #eps rpt
							-- order by  rpt.child,rpt.cohort_entry_year
							) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact



					

							

		-- reset state custody start dates
		update eps
		set removal_dt=cust_end
			,cohort_entry_year =cd.[year]
		from #eps eps
		 join vw_nondcfs_combine_adjacent_segments nondcfs on nondcfs.ID_PRSN=eps.child
			and nondcfs.CUST_BEGIN between eps.removal_dt
				and coalesce(eps.federal_discharge_date,'12/31/9999')
			and nondcfs.CUST_END between eps.removal_dt
				and coalesce(eps.federal_discharge_date,'12/31/9999')
		join dbo.CALENDAR_DIM cd on cd.CALENDAR_DATE=nondcfs.cust_end
			-- non-DCFS custody start date within episode
		where removal_dt=cust_begin
			and cust_end < federal_discharge_date
			and fl_nondcfs_within_eps=1



		-- move federal discharge date up to custody begin date where child is in nonDCFS custody until exit
		update eps
		set Federal_Discharge_Date=cust_begin
			, cd_discharge_type=case when orig_federal_discharge_date='12/31/9999' and cd_discharge_type=0
				then 6 else eps.cd_discharge_type end
			, discharge_type=case when orig_federal_discharge_date='12/31/9999' and cd_discharge_type=0
				then 'Other' else eps.discharge_type end
			--  select child,orig_removal_dt,removal_dt,federal_discharge_date,cust_begin,cust_end
		from #eps eps
		 join vw_nondcfs_combine_adjacent_segments nondcfs on nondcfs.ID_PRSN=eps.child
			and nondcfs.CUST_BEGIN between eps.removal_dt
				and coalesce(eps.federal_discharge_date,'12/31/9999')
			and nondcfs.CUST_END between eps.removal_dt
				and coalesce(eps.federal_discharge_date,'12/31/9999')
		 where eps.fl_nondcfs_within_eps = 1 
		 and  Federal_Discharge_Date = cust_end


	
			
		update eps
		set eps.cohort_entry_month=cd.[month]
			,eps.cohort_entry_year=cd.[year]
		from #eps eps
		join dbo.CALENDAR_DIM cd on cd.CALENDAR_DATE=removal_dt
		where removal_dt <> orig_removal_dt
		
		update eps
		set eps.cohort_exit_month=cd.[month]
			,eps.cohort_exit_year=cd.[year]
		from #eps eps
		join dbo.CALENDAR_DIM cd on cd.CALENDAR_DATE=Federal_Discharge_Date
		where Federal_Discharge_Date <> '12/31/9999'

--  select child,removal_dt,count(*) from #eps group by child,removal_dt having count(*) > 1


		if object_ID('tempDB..#nondcfs') is not null drop table #nondcfs;
		select distinct eps.id_removal_episode_fact,eps.child,null as bin_los_cd,eps.removal_dt,eps.federal_discharge_date
				,dcfs.cust_begin
				,iif(dcfs.cust_end='12/31/9999' 
							and  eps.federal_discharge_date  < dcfs.cust_end
					, eps.federal_discharge_date  
					, dcfs.cust_end) as cust_end 
				,row_number() over (partition by eps.id_removal_episode_fact
						order by eps.id_removal_episode_fact,dcfs.cust_begin asc
						,dcfs.cust_end asc) as sort_asc
				,row_number() over (partition by eps.id_removal_episode_fact
						order by eps.id_removal_episode_fact,dcfs.cust_begin desc,dcfs.cust_end desc) as sort_desc 
				,0 as fl_update
		into #nondcfs
		from (select distinct id_removal_episode_fact,child,removal_dt,federal_discharge_date,fl_nondcfs_overlap_eps from #eps where fl_nondcfs_overlap_eps=1) eps
		join vw_nondcfs_combine_adjacent_segments dcfs on dcfs.id_prsn=eps.child
		and dcfs.cust_begin < isnull(federal_discharge_date,'12/31/9999')
		and dcfs.cust_end > removal_dt
		where fl_nondcfs_overlap_eps = 1

		
	-- begin split segments
		if object_ID('tempDB..#tmp') is not null drop table #tmp
		create table #tmp
		( id_removal_episode_fact int
			,removal_dt datetime
			,federal_discharge_date datetime
			,fl_multiple int 
			, bin_los_cd int
			, entry_month_date datetime
			, entry_year_date datetime
			, exit_month_date datetime
			, exit_year_date datetime )

		insert into #tmp(id_removal_episode_fact,removal_dt,federal_discharge_date,fl_multiple)
		-- use custody begin date as federal discharge date  for the first part ot the split
		select  id_removal_episode_fact,removal_dt,cust_begin as federal_discharge_date,0 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc=1
		and removal_dt < cust_begin
		union 
		-- use custody end date as the state custody start date for the next split segment where the custody end date is less than the federal discharge date where there is only 1 segment
		select  id_removal_episode_fact,cust_end,federal_discharge_date,0 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc=1
		and cust_end < federal_discharge_date
		union --- get the first segment for the multiple custody segments
		select  id_removal_episode_fact,removal_dt,cust_begin as federal_discharge_date,1 as fl_multiple
		from #nondcfs where sort_asc=1 and sort_desc<>1
			and removal_dt < cust_begin
			

		declare @maxNbrCustSeg int
		declare @rowcount int
							
		select @maxNbrCustSeg=max(sort_desc) -1  from #nondcfs;
		--loop through getting the next custody segment
		set @rowcount=1
		while @rowcount < @maxNbrCustSeg
		begin
					
			insert into #tmp(id_removal_episode_fact,removal_dt,federal_discharge_date,fl_multiple)
			select  n1.id_removal_episode_fact,n1.cust_end,dbo.lessorDate(n2.federal_discharge_date,n2.cust_begin)
			,1 as fl_multiple
			from #nondcfs n1
			join #nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_asc=@rowcount + 1
				
			where n1.sort_asc=@rowcount 
			and n1.removal_dt < n1.cust_begin
			and n1.cust_end < n2.cust_begin
						
			set @rowcount=@rowcount + 1;
		end
		
					
		--now get last multiple custody segment
		insert into #tmp(id_removal_episode_fact,removal_dt,federal_discharge_date,fl_multiple)
		select  n1.id_removal_episode_fact,n2.cust_end,dbo.lessorDate(n1.federal_discharge_date,n1.cust_begin),1 as fl_multiple
		from #nondcfs n1
		join #nondcfs n2 on n2.id_removal_episode_fact=n1.id_removal_episode_fact and n2.sort_desc=2
		where n1.sort_desc=1
		and n1.removal_dt < n1.cust_begin
		and n2.cust_end < n1.cust_begin
		except
		select id_removal_episode_fact,removal_dt,federal_discharge_date,1 from #tmp

		-- now insert remaining segment if last cust_end is less than federal_discharge_date
		insert into #tmp(id_removal_episode_fact,removal_dt,federal_discharge_date,fl_multiple)
		select  n1.id_removal_episode_fact,n1.cust_end,federal_discharge_date,1 as fl_multiple
		from #nondcfs n1
		where n1.sort_desc=1 and federal_discharge_date > n1.cust_end


		update #tmp
		set entry_month_date=calendar_dim.[month]
			,  entry_year_date =calendar_dim.[year]
		from dbo.CALENDAR_DIM 
		where CALENDAR_DATE=removal_dt


		update #tmp
		set exit_month_date=calendar_dim.[month]
			,  exit_year_date =calendar_dim.[year]
		from dbo.CALENDAR_DIM 
		where CALENDAR_DATE=federal_discharge_date

		
		if object_ID('tempDB..#bkp_eps') is not null drop table #bkp_eps;
		select 	tmp.entry_year_date as cohort_entry_year
      , tmp.entry_month_date as cohort_entry_month
      , tmp.exit_year_date as  cohort_exit_year
      , tmp.exit_month_date as cohort_exit_month
      , ae.child
	  ,ae.id_case
	  , ae.birthdate
      , tmp.id_removal_episode_fact
      , case when coalesce(orig_federal_discharge_date,'9999-12-31') ='9999-12-31' and tmp.federal_discharge_date <> '9999-12-31'
			and cd_discharge_type=0 then 'Other' else discharge_type end	as  discharge_type
		, case when coalesce(orig_federal_discharge_date,'9999-12-31') ='9999-12-31' and tmp.federal_discharge_date <> '9999-12-31'
			and cd_discharge_type=0 then 6 else cd_discharge_type end as cd_discharge_type
      , ae.first_removal_dt
      , ae.fl_first_removal
      , tmp.removal_dt
	  , ae.orig_removal_dt
      , tmp.federal_discharge_date
      , ae.orig_federal_discharge_date
	  , ae.last_placement_discharge_date
      , ae.entry_cdc_census_mix_age_cd
	  ,ae.entry_census_child_group_cd
	  ,ae.entry_developmental_age_cd
	  , ae.exit_cdc_census_mix_age_cd
	  , ae.exit_census_child_group_cd
	  , ae.exit_developmental_age_cd
	  , ae.last_plcm_exit_census_mix_age_cd
	  , ae.last_plcm_exit_census_child_group_cd
	  ,ae.last_plcm_exit_census_developmental
	  , ae.fl_exit_over_17
      , ae.pk_gndr
      , ae.cd_race_census
      , ae.census_Hispanic_Latino_Origin_cd
      , ae.init_cd_plcm_setng
      , ae.long_cd_plcm_setng
      , ae.removal_county_cd
	  , ae.exit_county_cd
	  , ae.entry_int_match_param_key_cdc_census_mix
      , ae.exit_int_match_param_key_cdc_census_mix
	  , ae.entry_int_match_param_key_census_child_group
	  , ae.exit_int_match_param_key_census_child_group
	  , ae.entry_int_match_param_key_developmental
	  , ae.exit_int_match_param_key_developmental
	  , ae.plcm_exit_int_match_param_key_cdc_census_mix
	  , ae.plcm_exit_int_match_param_key_census_child_group
	  ,ae.plcm_exit_int_match_param_key_developmental
      , ae.bin_dep_cd
      , ae.max_bin_los_cd
      , ae.bin_placement_cd
      , ae.cd_reporter_type
      , ae.fl_cps_invs
      , ae.fl_cfws
      , ae.fl_risk_only
      , ae.fl_alternate_intervention
      , ae.fl_frs
	  , ae.fl_dlr
	  , ae.fl_far
      , ae.fl_phys_abuse
      , ae.fl_sexual_abuse
      , ae.fl_neglect
      , ae.fl_any_legal
      , ae.fl_founded_phys_abuse
      , ae.fl_founded_sexual_abuse
      , ae.fl_founded_neglect
      , ae.fl_found_any_legal
      , ae.bin_ihs_svc_cd
      , ae.prsn_cnt
      , ae.exit_within_month_mult3
      , ae.nxt_reentry_within_min_month_mult3
      , ae.fl_nondcfs_eps
	  , ae.fl_nondcfs_within_eps
	  , ae.fl_nondcfs_overlap_eps
      , ae.dependency_dt
      , ae.fl_dep_exist
      , ae.fl_reentry
      , ae.next_reentry_date
      , ae.child_eps_rank_asc
      , ae.child_eps_rank_desc
		into #bkp_eps
		from #eps ae
		join #tmp tmp on ae.id_removal_episode_fact=tmp.id_removal_episode_fact 

	
		if object_ID('tempDB..#dcfs_alleps') is not null drop table #dcfs_alleps;
		select distinct
				 ae.cohort_entry_year
				, ae.cohort_entry_month
				, ae.cohort_exit_year
				, ae.cohort_exit_month
				, ae.child
				,ae.id_case
				, ae.birthdate
				, ae.id_removal_episode_fact
				, ae.discharge_type
				, ae.cd_discharge_type
				, ae.first_removal_dt
				, ae.fl_first_removal
				, ae.removal_dt
				, ae.orig_removal_dt
				, ae.federal_discharge_date
				, ae.orig_federal_discharge_date
				 , ae.last_placement_discharge_date
			  , ae.entry_cdc_census_mix_age_cd
			  ,ae.entry_census_child_group_cd
			  ,ae.entry_developmental_age_cd
			  , ae.exit_cdc_census_mix_age_cd
			  , ae.exit_census_child_group_cd
			  , ae.exit_developmental_age_cd
			  , ae.last_plcm_exit_census_mix_age_cd
			  , ae.last_plcm_exit_census_child_group_cd
			  , ae.last_plcm_exit_census_developmental
			  , ae.fl_exit_over_17
				, ae.pk_gndr
				, ae.cd_race_census
				, ae.census_Hispanic_Latino_Origin_cd
				, ae.init_cd_plcm_setng
				, ae.long_cd_plcm_setng
				,ae.removal_county_cd
			  , ae.exit_county_cd
			  , ae.entry_int_match_param_key_cdc_census_mix
			  , ae.exit_int_match_param_key_cdc_census_mix
			  , ae.entry_int_match_param_key_census_child_group
			  , ae.exit_int_match_param_key_census_child_group
			  ,ae.entry_int_match_param_key_developmental
			  ,ae.exit_int_match_param_key_developmental
			 , ae.plcm_exit_int_match_param_key_cdc_census_mix
			  , ae.plcm_exit_int_match_param_key_census_child_group
			  ,ae.plcm_exit_int_match_param_key_developmental
				, ae.bin_dep_cd
				, ae.max_bin_los_cd
				, ae.bin_placement_cd
				, ae.cd_reporter_type
				, ae.fl_cps_invs
				, ae.fl_cfws
				, ae.fl_risk_only
				, ae.fl_alternate_intervention
				, ae.fl_frs
				  , ae.fl_dlr
				  , ae.fl_far
				, ae.fl_phys_abuse
				, ae.fl_sexual_abuse
				, ae.fl_neglect
				, ae.fl_any_legal
				, ae.fl_founded_phys_abuse
				, ae.fl_founded_sexual_abuse
				, ae.fl_founded_neglect
				, ae.fl_found_any_legal
				, ae.bin_ihs_svc_cd
				, ae.prsn_cnt
				, ae.exit_within_month_mult3
				, ae.nxt_reentry_within_min_month_mult3
				, ae.fl_nondcfs_eps
				, ae.fl_nondcfs_within_eps
				, ae.fl_nondcfs_overlap_eps
				, ae.dependency_dt
				, ae.fl_dep_exist
				, ae.fl_reentry
				, ae.next_reentry_date
				, ae.child_eps_rank_asc
				, ae.child_eps_rank_desc
				into #dcfs_alleps 
			from #eps ae
			where fl_nondcfs_eps=0 and ae.id_removal_episode_fact not in (select id_removal_episode_fact from #tmp) 
					
			--insert our SPLIT DCFS removal_dt and federal_discharge_date	
			insert into #dcfs_alleps
			SELECT  distinct
			*
			from #bkp_eps ae;


		if object_id('tempDB..#age') is not null drop table #age;
		select id_removal_episode_fact,child,removal_dt,birthdate,federal_discharge_date
		, dbo.fnc_datediff_mos(birthdate,federal_discharge_date) [age_mo]
		into #age
		from #dcfs_alleps
		where federal_discharge_date is not null and federal_discharge_date < '9999-12-31'  


		update eps
		set fl_exit_over_17=1
		 from #dcfs_alleps eps
		 join #age age on age.id_removal_episode_fact=eps.id_removal_episode_fact   and age.federal_discharge_date=eps.federal_discharge_date and age.removal_dt=eps.removal_dt
		 where age.age_mo >= 18*12 		and eps.federal_discharge_date <  getdate();



	update eps 
	set exit_cdc_census_mix_age_cd=iif(age.age_mo< 18*12 ,AgeExit.cdc_census_mix_age_cd,iif(fl_exit_over_17=1,cma.cdc_census_mix_age_cd,0))
			,exit_census_child_group_cd=iif( age.age_mo< 18*12 ,AgeExit.census_child_group_cd,iif(fl_exit_over_17=1,ccg.census_child_group_cd,0))
	from #dcfs_alleps eps
	join #age age on age.id_removal_episode_fact=eps.id_removal_episode_fact   and age.federal_discharge_date=eps.federal_discharge_date and age.removal_dt=eps.removal_dt
	join age_dim AgeExit on AgeExit.age_mo =age.age_mo
	join  (select max(cdc_census_mix_age_cd) [cdc_census_mix_age_cd] from age_dim where age_yr=17) cma on 1=1
	join (select max(census_child_group_cd) [census_child_group_cd] from age_dim where age_yr=17) ccg on 1=1
	where eps.federal_discharge_date is not null and eps.federal_discharge_date < '9999-12-31'

	CREATE NONCLUSTERED INDEX  idx_discharge_dt
ON #dcfs_alleps ([federal_discharge_date])
INCLUDE ([cohort_entry_year],[cohort_entry_month],[cohort_exit_year],[cohort_exit_month],[child],[birthdate],[id_removal_episode_fact],[discharge_type],[cd_discharge_type],[first_removal_dt],[fl_first_removal],[removal_dt],[orig_removal_dt],[orig_federal_discharge_date],[last_placement_discharge_date],[entry_cdc_census_mix_age_cd],[entry_census_child_group_cd],[entry_developmental_age_cd],[exit_cdc_census_mix_age_cd],[exit_census_child_group_cd],[exit_developmental_age_cd],[last_plcm_exit_census_mix_age_cd],[last_plcm_exit_census_child_group_cd],[last_plcm_exit_census_developmental],[fl_exit_over_17],[pk_gndr],[cd_race_census],[census_Hispanic_Latino_Origin_cd],[init_cd_plcm_setng],[long_cd_plcm_setng],[removal_county_cd],[exit_county_cd],[entry_int_match_param_key_cdc_census_mix],[exit_int_match_param_key_cdc_census_mix],[entry_int_match_param_key_census_child_group],[exit_int_match_param_key_census_child_group],[entry_int_match_param_key_developmental],[exit_int_match_param_key_developmental],[plcm_exit_int_match_param_key_cdc_census_mix],[plcm_exit_int_match_param_key_census_child_group],[plcm_exit_int_match_param_key_developmental],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[cd_reporter_type],[fl_cps_invs],[fl_cfws],[fl_risk_only],[fl_alternate_intervention],[fl_frs],[fl_dlr],[fl_far],[fl_phys_abuse],[fl_sexual_abuse],[fl_neglect],[fl_any_legal],[fl_founded_phys_abuse],[fl_founded_sexual_abuse],[fl_founded_neglect],[fl_found_any_legal],[bin_ihs_svc_cd],[prsn_cnt],[exit_within_month_mult3],[nxt_reentry_within_min_month_mult3],[fl_nondcfs_eps],[fl_nondcfs_within_eps],[fl_nondcfs_overlap_eps],[dependency_dt],[fl_dep_exist],[fl_reentry],[next_reentry_date],[child_eps_rank_asc],[child_eps_rank_desc])

create nonclustered index idx_age_mo_discharge_dt
on #age([age_mo],[federal_discharge_date])
INCLUDE ([id_removal_episode_fact],[removal_dt])
--- LOH 9/18
	update eps
	set exit_developmental_age_cd=iif(age.age_mo< 18*12 ,ref_age.developmental_age_cd,iif(fl_exit_over_17=1,da.[developmental_age_cd],0))
		,last_plcm_exit_census_developmental=iif(age.age_mo < 18*12 ,ref_age.developmental_age_cd,iif(fl_exit_over_17=1,da.[developmental_age_cd],0))
	from #dcfs_alleps eps
	join #age age on age.id_removal_episode_fact=eps.id_removal_episode_fact   and age.federal_discharge_date=eps.federal_discharge_date 
				and age.removal_dt=eps.removal_dt
	join ref_age_developmental ref_age  on ref_age.age_mo=age.age_mo
	join (select max(developmental_age_cd) [developmental_age_cd] from age_dim where age_yr=17) da on 1=1
	where eps.federal_discharge_date is not null and eps.federal_discharge_date < '9999-12-31'
	and age.age_mo=iif(day(eps.federal_discharge_date)<  day(eps.birthdate) ,datediff(mm,eps.birthdate,eps.federal_discharge_date) - 1 ,datediff(mm,eps.birthdate,eps.federal_discharge_date))


update eps 
	set last_plcm_exit_census_mix_age_cd=iif( age.age_mo< 18*12 ,ageexit.cdc_census_mix_age_cd,iif(fl_exit_over_17=1,cma.cdc_census_mix_age_cd,0))
		, last_plcm_exit_census_child_group_cd=iif( age.age_mo< 18*12 ,ageexit.census_child_group_cd,iif(fl_exit_over_17=1,ccg.[census_child_group_cd],0))
	from #dcfs_alleps eps
	join #age age on age.id_removal_episode_fact=eps.id_removal_episode_fact   and age.federal_discharge_date=eps.federal_discharge_date and age.removal_dt=eps.removal_dt
	join age_dim AgeExit on AgeExit.age_mo =age.age_mo
	join (select max(cdc_census_mix_age_cd) [cdc_census_mix_age_cd ]from age_dim where age_yr=17) cma on 1=1
	join (select max(census_child_group_cd) [census_child_group_cd] from age_dim where age_yr=17) ccg on 1=1
	where eps.federal_discharge_date is not null and eps.federal_discharge_date < '9999-12-31'
	and AgeExit.age_mo =iif(day(eps.last_placement_discharge_date)<  day(eps.birthdate) ,datediff(mm,eps.birthdate,eps.last_placement_discharge_date) - 1 ,datediff(mm,eps.birthdate,eps.last_placement_discharge_date))


	update eps
	set exit_int_match_param_key_cdc_census_mix = 	(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.exit_cdc_census_mix_age_cd,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
			, exit_int_match_param_key_census_child_group=	(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.exit_census_child_group_cd,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
			, exit_int_match_param_key_developmental=	(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.exit_developmental_age_cd,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
		, plcm_exit_int_match_param_key_cdc_census_mix=(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.last_plcm_exit_census_mix_age_cd,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
		, plcm_exit_int_match_param_key_census_child_group=(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.last_plcm_exit_census_child_group_cd,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
																				
		, plcm_exit_int_match_param_key_developmental=(cast(power(10.0,8) + 
				(power(10.0,7) * coalesce(eps.last_plcm_exit_census_developmental,0)) + 
				(power(10.0,6) * coalesce(eps.cd_race_census,7)) +
					(power(10.0,5) * coalesce(eps.census_Hispanic_Latino_Origin_cd,5)) + 
						(power(10.0,4) * coalesce(eps.pk_gndr,3)) + 
							(power(10.0,3) * eps.init_cd_plcm_setng) +
								(power(10.0,2) * eps.long_cd_plcm_setng) + 
									(power(10.0,0) *  ( case when   eps.exit_county_cd between 1 and 39 
																				then  eps.exit_county_cd else  99 end	)) as decimal(9,0)))
FROM #dcfs_alleps eps
where federal_discharge_date is not null and  eps.federal_discharge_date < '9999-12-31'




CREATE NONCLUSTERED INDEX idx_tmp_33 on #dcfs_alleps (id_removal_episode_fact,[removal_dt],[federal_discharge_date])
	

	
		UPDATE EPS
		set exit_within_month_mult3= case when iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))
		<3 then 3 
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<6 then 6
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<9 then 9
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<12 then 12
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<15 then 15
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<18 then 18
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<21 then 21
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<24 then 24
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<27 then 27
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<30 then 30
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<33 then 33
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<36 then 36
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<39 then 39
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<42 then 42
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<45 then 45
									when  iif(day(eps.federal_discharge_date)<  day(eps.removal_dt) ,datediff(mm,eps.removal_dt,eps.federal_discharge_date) - 1 ,datediff(mm,eps.removal_dt,eps.federal_discharge_date))<48 then 48
								end
		from #dcfs_alleps eps;

		--declare @start_date datetime
		--declare @cutoff_date datetime
		--select @cutoff_date=cutoff_date from dbo.ref_Last_DW_Transfer	
		--set @start_date = '2000-01-01'

		update eps
		set max_bin_los_cd=q.max_bin_los_cd
		from #dcfs_alleps eps
		 join (
				select id_removal_episode_fact,removal_dt,federal_discharge_date,max(los.bin_los_cd) as max_bin_los_cd
				from #dcfs_alleps
				join ref_last_dw_transfer dw on dw.cutoff_date=dw.cutoff_date
				join ref_filter_los los on datediff(dd,removal_dt,case when federal_discharge_date = '12/31/9999' 
						then cutoff_date else federal_discharge_date end) + 1  between los.dur_days_from and los.dur_days_thru
				  --and id_removal_episode_fact=90216  --  select * from #eps where id_Removal_episode_fact=90216
				group by id_removal_episode_fact,removal_dt,federal_discharge_date
				) q on q.id_removal_episode_fact=eps.id_removal_episode_fact
					and q.removal_dt=eps.removal_dt
					and q.Federal_Discharge_Date=eps.Federal_Discharge_Date
		where eps.max_bin_los_cd <> q.max_bin_los_cd or eps.max_bin_los_cd is null


		update eps
		set child_eps_rank_asc=q.row_num_asc,
		child_eps_rank_desc = q.row_num_desc
		from #dcfs_alleps eps 
		join (select tce.* ,row_number() over (-- only want one episode per cohort_period
						partition by tce.child
							order by cohort_entry_year asc ,removal_dt asc,federal_discharge_date asc) as row_num_asc
							,row_number() over (-- only want one episode per cohort_period
						partition by tce.child
							order by cohort_entry_year asc ,removal_dt desc,federal_discharge_date desc) as row_num_desc
							from #dcfs_alleps tce
							-- order by  rpt.child,rpt.cohort_entry_year
							) q on q.id_removal_episode_fact=eps.id_removal_episode_fact
							
		-- for non-dcfs split episodes update discharge to other for all but last discharge				
		update eps
		set cd_discharge_type=6,discharge_type='Other'
		-- select q.*,eps.*
		from #dcfs_alleps eps 
		join (select distinct id_removal_episode_fact,removal_dt,federal_discharge_date from #tmp)  q 
				on q.id_removal_episode_fact=eps.id_removal_episode_fact and q.removal_dt=eps.removal_dt
		where eps.child_eps_rank_desc <> 1

		update eps
		set eps.first_removal_dt=q.first_removal_dt
		from #dcfs_alleps eps
		join (select #dcfs_alleps.child,min(removal_dt) as first_removal_dt
			 from #dcfs_alleps group by child
			) q on eps.child=q.child


			-- update for the dcfs episodes
		alter table #dcfs_alleps
		alter column bin_dep_cd int null;

		update rpt
		set bin_dep_cd=null,dependency_dt=null,fl_dep_exist=0
		from #dcfs_alleps rpt 
		join (select id_removal_episode_fact,removal_dt
				,ROW_NUMBER() over (partition by id_removal_episode_fact order by removal_dt asc) as row_num from #dcfs_alleps
				where id_removal_episode_fact in (select id_removal_episode_fact from #tmp)) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact
						and q.removal_dt =rpt.removal_dt
						and q.row_num > 1
				
				
		update rpt
		set dependency_dt= q.[eff_date]
		--select rpt.id_removal_episode_fact,child,rpt.removal_dt,rpt.federal_discharge_date,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from #dcfs_alleps rpt
		join (			select distinct id_removal_episode_fact
							,FAMLINKID
							,removal_dt
							,federal_discharge_date
							,dateadd(dd,79,aoc.petition_date) [eff_date]
							,datediff(dd,tce.removal_dt,dateadd(dd,79,aoc.Petition_date)) as days_frm_state_custody
							,row_number() over (partition by child ,removal_dt
									order by datediff(dd,tce.removal_dt,dateadd(dd,79,aoc.petition_date))  asc) as row_num
						from aoc.aoc_petition aoc
						join #dcfs_alleps  tce on 
						 tce.child=aoc.FAMLINKID
							and dateadd(dd,79,aoc.petition_date) >= dateadd(dd,-79,dateadd(yy,-1,tce.removal_dt ))
									and dateadd(dd,79,aoc.petition_date) < isnull(tce.federal_discharge_date,(select cutoff_date from ref_last_dw_transfer))
						and petition ='DEPENDENCY PETITION' 
						where tce.bin_dep_cd is null
				) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact  
					and rpt.removal_dt=q.removal_dt
					and q.federal_discharge_date=rpt.Federal_Discharge_Date
					and q.row_num=1
		where rpt.bin_dep_cd is null


		update rpt
		set bin_dep_cd=dep.bin_dep_cd
		--select rpt.id_removal_episode_fact,child,rpt.removal_dt,rpt.federal_discharge_date,q.days_frm_state_custody,q.petition_date as petition_dependency_date
		from #dcfs_alleps rpt		
			join ref_filter_dependency dep on datediff(dd,rpt.removal_dt,dependency_dt) between diff_days_from and diff_days_thru and dep.bin_dep_cd > 1
		where rpt.bin_dep_cd is null and rpt.dependency_dt is not null


	 

		update  #dcfs_alleps 
		set bin_dep_cd =1
		where bin_dep_cd is null;

	

	
		update dcfs
		set fl_reentry=1
			,next_reentry_date= nxt.removal_dt
		from #dcfs_alleps dcfs
		join #dcfs_alleps nxt on dcfs.child=nxt.child and  nxt.child_eps_rank_asc=dcfs.child_eps_rank_asc + 1


			update #dcfs_alleps
		set nxt_reentry_within_min_month_mult3= 
			case when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 3 then 3
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date)) < 6 then 6
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 9 then 9
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 12 then 12
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 15 then 15
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 18 then 18
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 21then 21
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 24 then 24
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 27 then 27
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 30 then 30
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 33 then 33
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 36 then 36
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 39 then 39
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 42 then 42
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 45 then 45
				 when  iif(day(next_reentry_date)<  day(federal_discharge_date) ,datediff(mm,federal_discharge_date,next_reentry_date) - 1 ,datediff(mm,federal_discharge_date,next_reentry_date))  < 48 then 48
			end;

			

		--  if object_ID(N'prtl.ooh_eps',N'U') is not null truncate table  prtl.ooh_eps
		if object_ID(N'prtl.ooh_dcfs_eps',N'U') is not null truncate table  prtl.ooh_dcfs_eps
		

		insert into prtl.ooh_dcfs_eps
		SELECT [cohort_entry_year]
      ,[cohort_entry_month]
      ,[cohort_exit_year]
      ,[cohort_exit_month]
      ,child
	  , dateadd(dd,1,eomonth(birthdate)) as  birthdate
      ,[id_removal_episode_fact]
      ,[discharge_type]
      ,[cd_discharge_type]
      ,[first_removal_dt]
      ,[fl_first_removal]
      ,[removal_dt]
	  , orig_removal_dt
      ,[Federal_Discharge_Date]
      ,[orig_federal_discharge_date]
	  , last_placement_discharge_date
      ,[entry_cdc_census_mix_age_cd]
      ,[entry_census_child_group_cd]
	  ,entry_developmental_age_cd
      ,[exit_cdc_census_mix_age_cd]
      ,[exit_census_child_group_cd]
	  ,exit_developmental_age_cd
	  ,fl_exit_over_17
	--  ,last_plcm_exit_census_mix_age_cd
--	  ,last_plcm_exit_census_child_group_cd
      ,coalesce([pk_gndr],3) as pk_gndr
      ,[cd_race_census]
      ,[census_Hispanic_Latino_Origin_cd]
      ,[init_cd_plcm_setng]
      ,[long_cd_plcm_setng]
      ,[Removal_County_Cd]
	  , exit_county_cd
      ,[entry_int_match_param_key_cdc_census_mix]
      ,[entry_int_match_param_key_census_child_group]
	  ,entry_int_match_param_key_developmental
      ,[exit_int_match_param_key_cdc_census_mix]
      ,[exit_int_match_param_key_census_child_group]
	  ,exit_int_match_param_key_developmental
	 -- ,plcm_exit_int_match_param_key_cdc_census_mix
	--  ,plcm_exit_int_match_param_key_census_child_group
      ,[bin_dep_cd]
      ,[max_bin_los_cd]
      ,[bin_placement_cd]
      ,[cd_reporter_type]
      ,[fl_cps_invs]
      ,[fl_cfws]
      ,[fl_risk_only]
      ,[fl_alternate_intervention]
      ,[fl_frs]
	  ,fl_dlr
	  ,fl_far
      ,[fl_phys_abuse]
      ,[fl_sexual_abuse]
      ,[fl_neglect]
      ,[fl_any_legal]
      ,[fl_founded_phys_abuse]
      ,[fl_founded_sexual_abuse]
      ,[fl_founded_neglect]
      ,[fl_found_any_legal]
      ,[bin_ihs_svc_cd]
      ,[prsn_cnt]
      ,[exit_within_month_mult3]
      ,[nxt_reentry_within_min_month_mult3]
	, fl_nondcfs_eps
	, fl_nondcfs_within_eps
	, fl_nondcfs_overlap_eps

      ,[dependency_dt]
      ,[fl_dep_exist]
      ,[fl_reentry]
      ,[next_reentry_date]
      ,child_eps_rank_asc
      ,child_eps_rank_desc
	  ,id_case
		from #dcfs_alleps;

update eps
set first_removal_dt=rpt.first_removal_dt
--  select rpt.first,eps.first_removal_dt
from prtl.ooh_dcfs_eps eps
join base.rptPlacement rpt
on rpt.id_removal_episode_fact=eps.id_removal_episode_fact
where rpt.first_removal_dt <> eps.first_removal_dt

		update prtl.ooh_dcfs_eps
		set fl_first_removal = 0 where removal_dt <> first_removal_dt and fl_first_removal=1



--update prtl.ooh_eps
--set federal_discharge_date='12/31/9999' where federal_discharge_date is null;

update prtl.ooh_dcfs_eps
set federal_discharge_date='12/31/9999' where federal_discharge_date is null;


update prtl.prtl_tables_last_update
	  set last_build_date=getdate()
	  ,row_count=(select count(*) from prtl.ooh_dcfs_eps)
where tbl_id=39

update statistics prtl.ooh_dcfs_eps;
end
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end
