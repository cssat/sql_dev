USE [CA_ODS]
GO
/****** Object:  StoredProcedure [prtl].[prod_build_prtl_pbcw3_pbcw4]    Script Date: 4/28/2014 12:05:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [prtl].[prod_build_prtl_pbcw3_pbcw4](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
set nocount on
	
	declare @cohort_begin_date datetime;
	declare @cutoff_date datetime;
	declare @date_type int;

	set @cohort_begin_date='1/1/2000'
	set @cutoff_date = (select cutoff_date from ref_Last_DW_Transfer)
	set @date_type=2;

	--if object_id('tempDB..#year') is not null drop table #year;
	-- select distinct [Year] into #year
	-- from dbo.CALENDAR_DIM cd where cd.year >= @cohort_begin_date and cd.year <= dateadd(yy,-1,@cutoff_date)

   
	if object_ID('tempDB..#eps') is not null drop table #eps
	select distinct 
		point_in_time_date as cohort_begin_date
		,date_type as date_type
		,qry_type as qry_type
		,eps.id_prsn_child
		,eps.id_removal_episode_fact
		,discharge_type
		,cd_discharge_type
		,first_removal_dt [first_removal_date]
		,fl_first_removal
		,eps.removal_dt [state_custody_start_date]
		,orig_removal_dt
		,federal_discharge_date
		,orig_federal_discharge_date
		,evt.age_grouping_cd_mix
		,evt.pk_gndr
		,evt.cd_race_census
		,evt.census_Hispanic_Latino_Origin_cd
		,evt.init_cd_plcm_setng
		,evt.long_cd_plcm_setng
	   , evt.pit_county_cd
		, evt.int_match_param_key_mix
		,evt.bin_dep_cd
		,evt.max_bin_los_cd
		,evt.bin_placement_cd
		,evt.cd_reporter_type
		,evt.filter_access_type
		,evt.filter_allegation
		,evt.filter_finding
		,evt.bin_ihs_svc_cd
		,evt.[filter_service_category]
		,evt.[filter_service_budget]
		,prsn_cnt
		,eps.exit_within_month_mult3 [exit_within_min_month_mult3]
		,eps.nxt_reentry_within_min_month_mult3
		,fl_nondcfs_eps
		,fl_nondcfs_within_eps
		,fl_nondcfs_overlap_eps
		,dependency_dt
		,fl_dep_exist
		,fl_reentry
		,next_reentry_date [nxt_reentry_date]
		,child_eps_rank_asc [prsn_eps_sort_asc]
		,child_eps_rank_desc [prsn_eps_sort_desc]
		,evt.id_placement_fact
		,0 as Fl_Family_Setting
		,0  as FL_DCFS_Family_Setting
		,0 as FL_PA_Family_Setting
		,0 as FL_Relative_Care
		,0 as FL_Grp_Inst_Care
		,evt.qualevt_w3w4 [qualEvent]
		, kinmark 
		,cast(null as int)  as Nbr_sibs_together
		,cast(null as int)  as Nbr_sibs_inplcmnt
		,cast(null as int)  as bin_sibling_group_size
		,cast(null as int)  as Nbr_Fullsibs
		,cast(null as int)  as Nbr_Halfsibs
		,cast(null as int)  as Nbr_Stepsibs
		,cast(null as int)  as Nbr_Totalsibs
		, cast(null as int)  as Allsibs_together
		, cast(null as int) as somesibs_together
		,cast(null as int) as allorsomesibs_together
		,cast(null as int) as allqualsibs_together
		,cast(null as int) as somequalsibs_together
		,cast(null as int) as allorsomequalsibs_together
		,cast(null as int) as kincare
		,1  as fl_w3
		, evt.plctypc
		, evt.plctypc_desc
		, evt.tempevt
		, evt.fl_out_trial_return_home
		, 0 as PAmark
	into #eps
	-- select *
	from prtl.ooh_dcfs_eps eps
	join prtl.ooh_point_in_time_child  evt 
		on evt.id_removal_episode_fact=eps.id_removal_episode_fact;

		create index idx_pbcw4_1 on #eps (id_placement_fact);
	
		
			 --remove trial return home if it occurs during the point in time
			update eps
			set fl_w3=0
			from #eps eps
			where fl_out_trial_return_home=1;
			 

	--			 select  rptPlacement_Events.id_provider_dim_caregiver, begin_date,end_date,cd_end_rsn,tx_end_rsn from base.rptPlacement_Events where id_removal_episode_fact=119643 order by begin_date
			
	--			select * from #eps where id_removal_episode_fact=116520 order by cohort_begin_date


		--  add private agency marker from payment table service codes	
		--  add PA markers to working events file
				update evt
				set PAmark=1,plctypc=2 
				,plctypc_desc='Family Setting (Child Placing Agency Home)' 
				from #eps evt
				join base.placement_payment_services pps on pps.id_placement_fact=evt.id_placement_fact
				where pymt_cd_srvc  IN (298,299,300,301,302,303,304,468,473,475,477,
																	 878,879,880,881,882,883,1499,1500,1501,1502,
																	 1503,1504,119003) 
				
					
				update eps
				set FL_DCFS_Family_Setting=1
				from #eps eps 
				where eps.plctypc=1 and fl_w3=1;
				
				update eps
				set FL_PA_Family_Setting=1
				from #eps eps 
				where eps.plctypc=2 and fl_w3=1;
					
				update eps
				set FL_Relative_Care=1
				from #eps eps 
				where eps.plctypc=3 and fl_w3=1;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #eps eps 
				where eps.plctypc=4 and fl_w3=1;
				
				update eps
				set FL_Family_Setting=1
				from #eps eps 
				where FL_DCFS_Family_Setting = 1 or FL_PA_Family_Setting=1 or FL_Relative_Care=1;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #eps eps 
				where (FL_Family_Setting = 0  and FL_Grp_Inst_Care=0 ) and fl_w3=1;

		CREATE NONCLUSTERED INDEX  idx_w4w4_2
		ON #eps  ([id_prsn_child],[cohort_begin_date])
		INCLUDE ([qualEvent])

			if object_ID('tempDB..#siblings') is not null drop table #siblings;
				SELECT e.ID_PRSN_CHILD as ID_PRSN_PRIMCHILD
							, qualevent
							, cohort_begin_date
							, date_type
							, qry_type
							, ID_SIBLING_RELATIONSHIP_FACT
							, ID_CALENDAR_DIM_BEGIN
							, ID_CALENDAR_DIM_END
							, ID_CASE_DIM_CHILD
							, ID_PEOPLE_DIM_CHILD
							, ID_PEOPLE_DIM_SIBLING
							, TX_RELATIONSHIP_TYPE
							, FL_SIBLING_IN_PLACEMENT
							, FL_TOGETHER
							, CHILD_AGE
							, SIBLING_AGE
							, SIBLING_RELATIONSHIP_FACT.ID_PRSN_CHILD
							, ID_PRSN_SIBLING
							, ID_CASE_CHILD  
							, dbo.IntDate_To_CalDate(id_calendar_dim_begin) as sibrel_begin
							, dbo.IntDate_To_CalDate(id_calendar_dim_end) as sibrel_end
							, case when charindex('Full ',TX_RELATIONSHIP_TYPE)>0 then 1
							  when charindex('Half ',TX_RELATIONSHIP_TYPE)>0 then 2
							  when charindex('Sibling',TX_RELATIONSHIP_TYPE)>0 then 2
							  else 3 end as sibtypc
							, case when charindex('Full ',TX_RELATIONSHIP_TYPE)>0  then 1 else 0 end as Fullsib
							, case when charindex('Half ',TX_RELATIONSHIP_TYPE)>0  or charindex('Sibling',TX_RELATIONSHIP_TYPE)>0  then 1 else 0 end as Halfsib
							, case when charindex('Step ',TX_RELATIONSHIP_TYPE)>0 then 1 else 0 end as Stepsib
					--**  compute flag of sibling in QUALIFYING placement
							, case when qualevent=1 and FL_SIBLING_IN_PLACEMENT=1 then 1
								when qualevent=0 then 0  end as sibqualplc
					into  #siblings
					FROM dbo.SIBLING_RELATIONSHIP_FACT
					join #eps e on e.id_prsn_child=SIBLING_RELATIONSHIP_FACT.ID_PRSN_SIBLING
					where dbo.IntDate_To_CalDate(id_calendar_dim_begin) <=cohort_begin_date
						and (dbo.IntDate_To_CalDate(id_calendar_dim_end) >cohort_begin_date 
								or dbo.IntDate_To_CalDate(id_calendar_dim_end)  is null)



				update #eps
				set Nbr_sibs_together=N_sibs_together
						,Nbr_sibs_inplcmnt=N_sibs_inplcmnt
						,bin_sibling_group_size=N_sibs_qualplcmnt 
						,Nbr_Fullsibs=N_Fullsibs
						,Nbr_Halfsibs=N_Halfsibs
						,Nbr_Stepsibs=N_Stepsibs
						,Nbr_Totalsibs=N_Totalsibs
				from (select ID_PRSN_CHILD,cohort_begin_date,qry_type,date_type
									, sum(isnull(FL_TOGETHER,0)) as N_sibs_together
									, sum(isnull(FL_SIBLING_IN_PLACEMENT,0)) as N_sibs_inplcmnt
									, sum(isnull(sibqualplc,0)) as N_sibs_qualplcmnt
									, sum(isnull(Fullsib,0)) as N_Fullsibs
									, sum(isnull(Halfsib,0)) as N_Halfsibs
									, sum(isnull(Stepsib,0)) as N_Stepsibs
									, isnull(count(*),0) as N_Totalsibs
							from #siblings
							group by ID_PRSN_CHILD ,cohort_begin_date,date_type,qry_type) q 
				where  q.id_prsn_child=#eps.id_prsn_child and q.cohort_begin_date=#eps.cohort_begin_date
					and q.date_type=#eps.date_type
					and q.qry_type=#eps.qry_type

				update #eps
				set allsibs_together=1
				where 	Nbr_sibs_inplcmnt>0
				and Nbr_sibs_together=Nbr_sibs_inplcmnt
						

				update #eps
				set somesibs_together = 1
				where Nbr_sibs_inplcmnt > 1 
				AND Nbr_sibs_together > 0 
				AND Nbr_sibs_together < Nbr_sibs_inplcmnt

				update #eps
				set allorsomesibs_together = 1
				where allsibs_together = 1 or somesibs_together = 1

				update #eps
				set allorsomequalsibs_together = 1
				where somequalsibs_together=1 or allqualsibs_together=1

				update #eps
				set allsibs_together=case when allsibs_together is null then 0 else allsibs_together end
					,somesibs_together=case when somesibs_together is null then 0 else somesibs_together end
					,allorsomesibs_together=case when allorsomesibs_together is null then 0 else allorsomesibs_together end
				where Nbr_sibs_inplcmnt > 0;

				update #eps
				set allqualsibs_together=1
				where qualEvent=1
				and bin_sibling_group_size > 0 AND Nbr_sibs_together = bin_sibling_group_size;

				update #eps
				set somequalsibs_together=1
				where qualEvent = 1 AND bin_sibling_group_size > 1 AND Nbr_sibs_together > 0 
						 AND Nbr_sibs_together < bin_sibling_group_size;
				        
				update #eps
				set  allorsomequalsibs_together=1
				where allqualsibs_together=1 or  somequalsibs_together=1 ;

				update #eps
				set allqualsibs_together=case when allqualsibs_together is null then 0 else allqualsibs_together end
					,somequalsibs_together=case when somequalsibs_together is null then 0 else somequalsibs_together end
					,allorsomequalsibs_together=case when allorsomequalsibs_together is null then 0 else allorsomequalsibs_together end
				where Nbr_sibs_inplcmnt > 0 and qualEvent=1;
				
				update eps
				set kincare=1
				from #eps eps 
				where allorsomequalsibs_together=1 and kinmark>0;

				update eps
				set kincare=1
				from #eps eps 
				where somequalsibs_together=0 and kinmark=qualEvent and kincare is null;

				update eps
				set kincare =0
				from #eps eps 
				where allorsomequalsibs_together <=1 and kincare is null




    truncate table prtl.prtl_pbcw3
	insert into prtl.prtl_pbcw3 ( cohort_begin_date
      ,date_type
      ,qry_type
      ,age_grouping_cd
      ,pk_gndr
      ,cd_race_census
      ,census_hispanic_latino_origin_cd
      ,init_cd_plcm_setng
      ,long_cd_plcm_setng
      ,county_cd
      ,int_match_param_key
      ,bin_dep_cd
      ,max_bin_los_cd
      ,bin_placement_cd
      ,cd_reporter_type
      ,bin_ihs_svc_cd
      ,filter_access_type
      ,filter_allegation
      ,filter_finding
      ,filter_service_category
      ,filter_service_budget
      ,family_setting_cnt
      ,family_setting_DCFS_cnt
      ,family_setting_private_agency_cnt
      ,relative_care
      ,group_inst_care_cnt
      ,total)


	select cohort_begin_date
			,date_type
			,qry_type as qry_type
			,age_grouping_cd_mix
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,pit_county_cd
			,int_match_param_key_mix
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			-- select * from ref_filter_access_type
			, filter_access_type
			-- select * from ref_filter_allegation
			,filter_allegation
			-- select * from ref_filter_finding
			,filter_finding
			-- select * from [dbo].[ref_service_cd_subctgry_poc]
			, filter_service_category
			, filter_service_budget
			, sum(Fl_Family_Setting) as family_setting_cnt
			, sum(fl_dcfs_family_Setting) as family_setting_DCFS_cnt
			, sum(FL_PA_Family_Setting) as family_setting_private_agency_cnt
			, sum(FL_Relative_Care) as relative_care
			, sum(FL_Grp_Inst_Care) as group_inst_care_cnt
			, sum(prsn_cnt) as total
			from #eps
			where fl_w3 = 1
			group by 
			cohort_begin_date
			,date_type
			,qry_type
			,age_grouping_cd_mix
			,pk_gndr
			,cd_race_census
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,pit_county_cd
			,int_match_param_key_mix
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			,filter_access_type
			,filter_allegation
			,filter_finding
			, filter_service_category
			, filter_service_budget


			
				--		select    cohort_begin_date   , qry_type,date_type, round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
    --    , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
    --    , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
    --    , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
				--from CA_ODS.prtl.prtl_pbcw3
				
				--group by cohort_begin_date   , qry_type,date_type
				--order by cohort_begin_date   , qry_type,date_type
		


--------------------------------------------------------   PBCW4   --------------------------------------------------------
		  truncate table prtl.prtl_pbcw4	
		   insert into prtl.prtl_pbcw4
		   (pit_date
			  ,date_type
			  ,qry_type
			  ,age_grouping_cd
			  ,pk_gndr
			  ,cd_race_census
			  ,census_hispanic_latino_origin_cd
			  ,init_cd_plcm_setng
			  ,long_cd_plcm_setng
			  ,county_cd
			  ,int_match_param_key
			  ,bin_dep_cd
			  ,max_bin_los_cd
			  ,bin_placement_cd
			  ,cd_reporter_type
			  ,bin_ihs_svc_cd
			  ,filter_access_type
			  ,filter_allegation
			  ,filter_finding
			, filter_service_category
			, filter_service_budget
			  ,kincare
			  ,bin_sibling_group_size
			  ,all_sib_together
			  ,some_sib_together
			  ,no_sib_together
			  ,total)
			SELECT         
			  cohort_begin_date as pit_date
			, date_type
			, qry_type
			, age_grouping_cd_mix as age_grouping_cd
			, pk_gndr
			, cd_race_census
			, census_hispanic_latino_origin_cd 
			, init_cd_plcm_setng
			, long_cd_plcm_setng
			, pit_county_cd
			, int_match_param_key_mix as int_match_param_key
			, bin_dep_cd
			, max_bin_los_cd
			, bin_placement_cd
			, cd_reporter_type
			, bin_ihs_svc_cd
			, filter_access_type
			, filter_allegation
			, filter_finding			
			, filter_service_category
			, filter_service_budget
			, kincare
			, case when bin_sibling_group_size > 4 then 4 else bin_sibling_group_size end
			, sum(allqualsibs_together) as all_sib_together
			, sum(somequalsibs_together) as some_sib_together
			, sum(case when allorsomequalsibs_together = 0 then 1 else 0 end) as  no_sib_together
			, count(*) as total
			FROM  #eps
			where age_grouping_cd_mix is not null
			and  qualEvent=1 and bin_sibling_group_size > 0
			group by 			
			  cohort_begin_date
			, date_type
			,qry_type
			, age_grouping_cd_mix
			, pk_gndr
			, cd_race_census
			, census_hispanic_latino_origin_cd 
			, init_cd_plcm_setng
			, long_cd_plcm_setng
			, pit_county_cd
			, int_match_param_key_mix
			, bin_dep_cd
			, max_bin_los_cd
			, bin_placement_cd
			, cd_reporter_type
			, bin_ihs_svc_cd
			, filter_access_type
			, filter_allegation
			, filter_finding			
			, filter_service_category
			, filter_service_budget
			 , kincare
			 , case when bin_sibling_group_size > 4 then 4 else bin_sibling_group_size end
			order by 
			cohort_begin_date 
			, date_type
			,qry_type
			, age_grouping_cd_mix 
			, pk_gndr
			, cd_race_census
			, census_hispanic_latino_origin_cd 
			, init_cd_plcm_setng
			, long_cd_plcm_setng
			, pit_county_cd
			, int_match_param_key_mix
			, bin_dep_cd
			, max_bin_los_cd
			, bin_placement_cd
			, cd_reporter_type
			, bin_ihs_svc_cd
			, filter_access_type
			, filter_allegation
			, filter_finding			
			, filter_service_category
			, filter_service_budget
			 , kincare
			 , case when bin_sibling_group_size > 4 then 4 else bin_sibling_group_size end;		
	
			  			
	

			update prtl.prtl_tables_last_update		
			set last_build_date=getdate()
				,row_count=(select count(*) from prtl.PRTL_PBCW3)
			where tbl_id=8;	
	
	
			update prtl.prtl_tables_last_update		
			set last_build_date=getdate()
				,row_count=(select count(*) from prtl.PRTL_PBCW4)
			where tbl_id=9;		
			
		

			update statistics prtl.PRTL_PBCW3;
			update statistics prtl.PRTL_PBCW4;
--		--select * from PRTL_PBCW3 ;
end --permission
else
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end






		--	select    cohort_begin_date   , round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
  --      , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
  --      , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
  --      , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
		--		from dbCoreAdministrativeTables.dbo.prtl_pbcw3
		--		where month(cohort_begin_date)=1
		--		group by cohort_begin_date
		--		order by cohort_begin_date


		--						select    cohort_begin_date   , round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as "Family Setting (State Foster Home)"
  --      , round((sum(Family_Setting_Private_Agency_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)   as  "Family Setting (Private Foster Home)"
  --      , round((sum(Relative_Care)* 1.0000)/(sum(total) * 1.0000) * 100,2)  as  "Family Setting (Kin Placement)"
  --      , round((sum(Group_Inst_Care_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2)    as "Non-Family Setting"
		--,round((sum(Family_Setting_DCFS_Cnt)* 1.0000)/(sum(total) * 1.0000) * 100,2) 
		--		from prtl.prtl_pbcw3 where qry_type=0 and date_type=2 and bin_dep_cd=0 and bin_los_cd=1
		--		group by cohort_begin_date
		--		order by cohort_begin_date
