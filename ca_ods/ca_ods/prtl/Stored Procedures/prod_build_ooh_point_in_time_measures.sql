/***********************************************************  POINT IN TIME       **************************/
CREATE procedure [prtl].[prod_build_ooh_point_in_time_measures](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin

	set nocount on


						if OBJECT_ID('tempDB..#evt') is not null drop table #evt

						SELECT evt.qry_type
								, evt.[date_type]
								,  evt.point_in_time_date [start_date]
								, convert(int,convert(varchar(8),point_in_time_date,112)) int_start_date
								, evt.[bin_dep_cd]
								, evt.[max_bin_los_cd]
								, evt.[bin_placement_cd]
								, evt.[bin_ihs_svc_cd]
								, evt.[cd_reporter_type]
								, evt.filter_access_type 
								, evt.filter_allegation 
								, evt.filter_finding 
								, evt.int_filter_service_category [filter_service_category]
								, evt.filter_service_budget
								, evt.age_grouping_cd_census
								, evt.age_grouping_cd_mix
								, evt.cd_race_census [cd_race]
								, evt.[census_hispanic_latino_origin_cd]
								, evt.[pk_gndr]
								, evt.[init_cd_plcm_setng]
								, evt.[long_cd_plcm_setng]
								, evt.pit_county_cd [county_cd]
								, evt.int_match_param_key_census [int_match_param_key]
								, evt.int_match_param_key_mix
								, evt.id_prsn_child 
								, 0 as Fl_Family_Setting
								, 0  as FL_DCFS_Family_Setting
								, 0 as FL_PA_Family_Setting
								, 0 as FL_Relative_Care
								, 0 as FL_Grp_Inst_Care
								, 0  [PAmark]
								, evt.qualevt_w3w4 [qualEvent]
								, kinmark 
								, cast(null as int)  as Nbr_sibs_together
								, cast(null as int)  as Nbr_sibs_inplcmnt
								, cast(null as int)  as bin_sibling_group_size
								, cast(null as int)  as Nbr_Fullsibs
								, cast(null as int)  as Nbr_Halfsibs
								, cast(null as int)  as Nbr_Stepsibs
								, cast(null as int)  as Nbr_Totalsibs
								, cast(null as int)  as Allsibs_together
								, cast(null as int) as somesibs_together
								, cast(null as int) as allorsomesibs_together
								, cast(null as int) as allqualsibs_together
								, cast(null as int) as somequalsibs_together
								, cast(null as int) as allorsomequalsibs_together
								, cast(null as int) as kincare
								, iif(fl_out_trial_return_home=1, 0,iif(date_type=2,1,0))  as fl_w3
								, iif(date_type=2,1,0)  as fl_w4
								,1 as fl_poc1ab
								, evt.plctypc
								, evt.plctypc_desc
								, evt.tempevt
								, evt.id_placement_fact
							into #evt
						  from  prtl.ooh_point_in_time_child evt
						  join prtl.ooh_dcfs_eps   eps 
								on eps.id_removal_episode_fact=evt.id_removal_episode_fact;
					




						CREATE NONCLUSTERED INDEX idx_insert_qry
						ON #evt ([date_type],[qry_type])
						INCLUDE ([start_date],[bin_dep_cd],[max_bin_los_cd],[bin_placement_cd],[bin_ihs_svc_cd]
						,[cd_reporter_type],filter_access_type,filter_allegation,filter_finding
						,filter_service_category,filter_service_budget
						, [int_match_param_key],int_match_param_key_mix,[id_prsn_child])

				create nonclustered index idx_evt_id_placement_fact on #evt([id_placement_fact])

				update evt
				set PAmark=1,plctypc=2 
				,plctypc_desc='Family Setting (Child Placing Agency Home)' 
				from #evt evt
				join base.placement_payment_services pps on pps.id_placement_fact=evt.id_placement_fact
				where pymt_cd_srvc  IN (298,299,300,301,302,303,304,468,473,475,477,
																	 878,879,880,881,882,883,1499,1500,1501,1502,
																	 1503,1504,119003) 
				
					
				update eps
				set FL_DCFS_Family_Setting=1
				from #evt eps 
				where eps.plctypc=1 and fl_w3=1;
				
				update eps
				set FL_PA_Family_Setting=1
				from #evt eps 
				where eps.plctypc=2 and fl_w3=1;
					
				update eps
				set FL_Relative_Care=1
				from #evt eps 
				where eps.plctypc=3 and fl_w3=1;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #evt eps 
				where eps.plctypc=4 and fl_w3=1;
				
				update eps
				set FL_Family_Setting=1
				from #evt eps 
				where FL_DCFS_Family_Setting = 1 or FL_PA_Family_Setting=1 or FL_Relative_Care=1;
				
				update eps
				set FL_Grp_Inst_Care=1
				from #evt eps 
				where (FL_Family_Setting = 0  and FL_Grp_Inst_Care=0 ) and fl_w3=1;

			

		CREATE NONCLUSTERED INDEX  idx_w4w4_2
		ON #evt  ([id_prsn_child],[int_start_date])
		INCLUDE ([qualEvent])

			if object_ID('tempDB..#siblings') is not null drop table #siblings;
				SELECT e.ID_PRSN_CHILD as ID_PRSN_PRIMCHILD
							, qualevent
							, [start_date]
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
							, IIF( charindex('Full ',TX_RELATIONSHIP_TYPE)>0  , 1 , 0 ) as Fullsib
							,  IIF( charindex('Half ',TX_RELATIONSHIP_TYPE)>0  or charindex('Sibling',TX_RELATIONSHIP_TYPE)>0   , 1 , 0 ) as Halfsib
							,  IIF( charindex('Step ',TX_RELATIONSHIP_TYPE)>0  , 1 , 0 ) as Stepsib
					--**  compute flag of sibling in QUALIFYING placement
							, iif( qualevent=1 and FL_SIBLING_IN_PLACEMENT=1, 1,0) [sibqualplc]
					into  #siblings
					FROM dbo.SIBLING_RELATIONSHIP_FACT
					join #evt  e on e.id_prsn_child=SIBLING_RELATIONSHIP_FACT.ID_PRSN_SIBLING
					where id_calendar_dim_begin <=[int_start_date]
						and (id_calendar_dim_end >[int_start_date] 
								or id_calendar_dim_end=0)

						

				update #evt
				set Nbr_sibs_together=N_sibs_together
						,Nbr_sibs_inplcmnt=N_sibs_inplcmnt
						,bin_sibling_group_size=N_sibs_qualplcmnt 
						,Nbr_Fullsibs=N_Fullsibs
						,Nbr_Halfsibs=N_Halfsibs
						,Nbr_Stepsibs=N_Stepsibs
						,Nbr_Totalsibs=N_Totalsibs
				from (select ID_PRSN_CHILD,[start_date],qry_type,date_type
									, sum(isnull(FL_TOGETHER,0)) as N_sibs_together
									, sum(isnull(FL_SIBLING_IN_PLACEMENT,0)) as N_sibs_inplcmnt
									, sum(isnull(sibqualplc,0)) as N_sibs_qualplcmnt
									, sum(isnull(Fullsib,0)) as N_Fullsibs
									, sum(isnull(Halfsib,0)) as N_Halfsibs
									, sum(isnull(Stepsib,0)) as N_Stepsibs
									, isnull(count(*),0) as N_Totalsibs
							from #siblings
							group by ID_PRSN_CHILD ,[start_date],date_type,qry_type) q 
							where  q.id_prsn_child=#evt.id_prsn_child and q.[start_date]=#evt.[start_date]
								and q.date_type=#evt.date_type
								and q.qry_type=#evt.qry_type

				update #evt
				set allsibs_together=1
				where 	Nbr_sibs_inplcmnt>0
				and Nbr_sibs_together=Nbr_sibs_inplcmnt
						

				update #evt
				set somesibs_together = 1
				where Nbr_sibs_inplcmnt > 1 
				AND Nbr_sibs_together > 0 
				AND Nbr_sibs_together < Nbr_sibs_inplcmnt

				update #evt
				set allorsomesibs_together = 1
				where allsibs_together = 1 or somesibs_together = 1

				update #evt
				set allorsomequalsibs_together = 1
				where somequalsibs_together=1 or allqualsibs_together=1

				update #evt
				set allsibs_together=case when allsibs_together is null then 0 else allsibs_together end
					,somesibs_together=case when somesibs_together is null then 0 else somesibs_together end
					,allorsomesibs_together=case when allorsomesibs_together is null then 0 else allorsomesibs_together end
				where Nbr_sibs_inplcmnt > 0;

				update #evt
				set allqualsibs_together=1
				where qualEvent=1
				and bin_sibling_group_size > 0 AND Nbr_sibs_together = bin_sibling_group_size;

				update #evt
				set somequalsibs_together=1
				where qualEvent = 1 AND bin_sibling_group_size > 1 AND Nbr_sibs_together > 0 
						 AND Nbr_sibs_together < bin_sibling_group_size;
				        
				update #evt
				set  allorsomequalsibs_together=1
				where allqualsibs_together=1 or  somequalsibs_together=1 ;

				update #evt
				set allqualsibs_together=case when allqualsibs_together is null then 0 else allqualsibs_together end
					,somequalsibs_together=case when somequalsibs_together is null then 0 else somequalsibs_together end
					,allorsomequalsibs_together=case when allorsomequalsibs_together is null then 0 else allorsomequalsibs_together end
				where Nbr_sibs_inplcmnt > 0 and qualEvent=1;
				
				update eps
				set kincare=1
				from #evt eps 
				where allorsomequalsibs_together=1 and kinmark>0;

				update eps
				set kincare=1
				from #evt eps 
				where somequalsibs_together=0 and kinmark=qualEvent and kincare is null;

				update eps
				set kincare =0
				from #evt eps 
				where allorsomequalsibs_together <=1 and kincare is null


			ALTER TABLE  prtl.ooh_point_in_time_measures  NOCHECK CONSTRAINT ALL 
			 truncate table prtl.ooh_point_in_time_measures;
			
			insert into prtl.ooh_point_in_time_measures
			select [start_date]
			,date_type
			,qry_type as qry_type
			,age_grouping_cd_mix
			,age_grouping_cd_census
			,pk_gndr
			,cd_race
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,county_cd
			,int_match_param_key_mix
			,int_match_param_key int_match_param_key_census
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			, filter_access_type
			,filter_allegation
			,filter_finding
			, filter_service_category
			, filter_service_budget
			,  coalesce(kincare,0) kincare
			, coalesce(iif(bin_sibling_group_size > 4 , 4 , bin_sibling_group_size ),0) [bin_sibling_group_size]
			, sum(Fl_Family_Setting) as family_setting_cnt
			, sum(fl_dcfs_family_Setting) as family_setting_DCFS_cnt
			, sum(FL_PA_Family_Setting) as family_setting_private_agency_cnt
			, sum(FL_Relative_Care) as relative_care
			, sum(FL_Grp_Inst_Care) as group_inst_care_cnt
			, coalesce(sum(allqualsibs_together),0) as all_sib_together
			, coalesce(sum(somequalsibs_together) ,0)as some_sib_together
			, coalesce(sum(iif(allorsomequalsibs_together = 0 , 1 , 0 )) ,0)as  no_sib_together
			, count(distinct id_prsn_child)  as cnt_child_unique
			, count(id_prsn_child) as cnt_child
			,fl_w3
			,iif(qualEvent=1 and bin_sibling_group_size > 0 and date_type=2,1,0) fl_w4
			,fl_poc1ab
			from #evt
			group by 		[start_date]	
			 ,date_type
			,qry_type
			,age_grouping_cd_mix
			,age_grouping_cd_census
			,pk_gndr
			,cd_race
			,census_hispanic_latino_origin_cd 
			,init_cd_plcm_setng
			,long_cd_plcm_setng
			,county_cd
			,int_match_param_key_mix
			,int_match_param_key 
			,bin_dep_cd
			,max_bin_los_cd
			,bin_placement_cd
			,cd_reporter_type
			,bin_ihs_svc_cd
			, filter_access_type
			,filter_allegation
			,filter_finding
			, filter_service_category
			, filter_service_budget
			, coalesce(kincare,0)
			, coalesce(iif(bin_sibling_group_size > 4 , 4 , bin_sibling_group_size ),0)
			, iif(qualEvent=1 and bin_sibling_group_size > 0 and date_type=2,1,0)
			, fl_w3
			, fl_poc1ab

			
			ALTER TABLE  prtl.ooh_point_in_time_measures  CHECK CONSTRAINT ALL 

		update statistics prtl.ooh_point_in_time_measures;

			update prtl.prtl_tables_last_update
			set    [last_build_date] = getdate()
			  ,[row_count]=(select count(*) from prtl.ooh_point_in_time_measures)
		  FROM [prtl].[prtl_tables_last_update] where tbl_name='ooh_point_in_time_measures'

	end

	