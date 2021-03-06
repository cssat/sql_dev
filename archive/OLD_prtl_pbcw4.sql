USE [dbCoreAdministrativeTables]
GO
/****** Object:  StoredProcedure [dbo].[prod_build_prtl_pbcw4]    Script Date: 11/26/2013 8:13:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--***  "PBC_W4_ChildrenwithSibs.sps" syntax for counting the number and percentage
--***  of children placed with siblings for all children in DCFS custody in placement
--***  at a given point-in-time; based on sibling groups identified using the FLDW sibling
--***  relationship table, which can include children identified as siblings despite having
--***  a different case ID; identical to PPM "FLDW_Children_withSibs.sps".
--***
--***  Excludes children in non-family home settings: respite, hospital, JRA, OTR, CRC, etc.,
--***  and excludes all children with time in care < 8 days.  Uses DW tables.
--***
--***   NOTE that "Return Home" (child no longer in care) for this measure is defined as
--***   the start of a TRH or the date of formal discharge from care, whichever comes first.
/********************************  CHANGES ***************************************************************
DATE			Author			Desc
2012-10-15		J.MESSERLY		Changed for Chapin Hall placement and CD_RACE_CENSUS
*********************************************************************************************************/
ALTER procedure [dbo].[prod_build_prtl_pbcw4](@permission_key datetime)
as 
if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
begin
set nocount on
	truncate table PRTL_PBCW4;
	declare @pit_date datetime
	set @pit_date='1/1/2000'

	declare @cutoff_date datetime
	declare @last_qtr datetime;
	declare @last_year datetime
	declare @date_type int;
	declare @loop_stop_date datetime;
	
	declare @age_grouping_stop int
	declare @age_grouping_start int

	set @age_grouping_start=(select age_grouping_cd from ref_age_groupings where age_begin=0 and age_lessthan_end < 18 and age_grouping_cd <> 0)
	set @age_grouping_stop=(select age_grouping_cd from ref_age_groupings where age_lessthan_end=18 and age_begin <> 0)

	select @cutoff_date=max(cutoff_date) from dbo.ref_Last_DW_Transfer
	set @loop_stop_date = (select max([Month]) from CA.calendar_dim where [Month] < @cutoff_date);
	--set @loop_stop_date='2/1/2000'



		while @pit_date < @loop_stop_date
		begin

				if object_ID('tempDB..#episodes') is not null drop table #episodes
					select    calendar_dim.calendar_date as pit_date
								  ,tce.[ID_PRSN_CHILD]
								  ,tce.ID_CASE
								  ,tce.First_Removal_date
								  ,tce.Latest_Removal_date
								  ,tce.[Removal_Region]
								  ,tce.[Removal_County_Cd]
								  ,tce.[Removal_County]
								  ,tce.[State_Custody_Start_Date]
								  ,tce.state_discharge_date
								  ,tce.[State_Discharge_Reason]
								  ,tce.[State_Discharge_Reason_Code]
								  ,tce.Federal_Discharge_Date_force_18 as [Federal_Discharge_Date]
								 ,tce.[ID_REMOVAL_EPISODE_FACT]
								 ,tce.[CD_GNDR]
								 ,tce.[TX_GNDR]
								 ,tce.[DT_BIRTH]
								,tce.cd_race_census
								,tce.census_hispanic_latino_origin_cd
								,G.PK_GNDR
								,frstdesc.tx_plcm_setng as init_tx_plcm_setng
								,frstplc.cd_plcm_setng as init_cd_plcm_setng
								,lastdesc.tx_plcm_setng as last_tx_plcm_setng
								,lastplc.cd_plcm_setng  as last_cd_plcm_setng
								,sdrx.CD_Discharge_Type  as dschtype
								,sdrx.Discharge_Type as dschtype_desc
								, pdrx.Placement_Discharge_Type_Cd as plcm_dschtype
								, pdrx.Placement_Discharge_Type  as plcm_dschtype_Desc		
								 ,tce.[Removal_ID_Location_Dim_Worker_County_Cd]
								  ,tce.[Removal_ID_Location_Dim_Worker_County]
								
								,0 as FL_NEGLECT
								,0 as FL_ABUSE
								,0 as FL_SEXUAL_ABUSE
								,0 as FL_OTHER_ABUSE
								,0 as FL_MISSING
								, datediff(dd,state_Custody_Start_Date,isnull(Federal_Discharge_Date_force_18,@cutoff_date)) as Time_In_Care
								, Age.Age_Grouping_Cd as Age_Grouping_Cd
								, Age.Age_Grouping as Age_Grouping
								,cast(0 as int) as Long_Term_FC
								 ,0 as qualEvent
								,0 as kinmark 
								  ,cast(null as int)  as Nbr_sibs_together
								  ,cast(null as int)  as Nbr_sibs_inplcmnt
								  ,cast(null as int)  as Nbr_sibs_qualplcmnt
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
									, cast(null as int) as  allsibs_together_grp
									, cast(null as int) as allorsomesibs_together_grp
									, cast(null as int) as allqualsibs_together_grp
									, cast(null as int) as allorsomequalsibs_together_grp
									,cast(null as int) as kincare_grp
									,cast(null as int) as sibgrpmark
									, 0 as nonDCFS_mark
						into #episodes
						from dbo.tbl_child_episodes tce 
						join CA.calendar_dim on calendar_dim.calendar_date=@pit_date
						left join dbo.ref_Age_Groupings Age on CHILD_AGE_REMOVAL_BEGIN >=Age.age_begin and CHILD_AGE_REMOVAL_BEGIN < age.Age_LessThan_End
								and age.age_grouping_cd between @age_grouping_start and  @age_grouping_stop
						left join dbo.ref_state_discharge_xwalk sdrx on sdrx.state_discharge_reason_code=tce.state_discharge_reason_code and sdrx.state_discharge_reason_code >0
						left join dbo.ref_plcm_discharge_reason_xwalk pdrx on pdrx.Removal_Plcm_Discharge_Reason_Cd = tce.Removal_Plcm_Discharge_Reason_Cd
						left join dbo.ref_lookup_placement_event frstplc on frstplc.id_plcmnt_evnt=tce.init_id_plcmnt_evnt
						left join dbo.ref_lookup_placement_event lastplc on lastplc.id_plcmnt_evnt=tce.last_id_plcmnt_evnt
						left join dbo.ref_lookup_plcmnt frstdesc on frstplc.cd_plcm_setng=frstdesc.cd_plcm_setng
						left join dbo.ref_lookup_plcmnt lastdesc on lastplc.cd_plcm_setng=lastdesc.cd_plcm_setng
							left join dbo.ref_lookup_gender G on G.CD_GNDR=tce.CD_GNDR
						left join dbo.ref_lookup_county cnty on cnty.County_Cd=tce.Removal_County_Cd
					where --**  select cohort; children in care at point in time for at least 8 days
							datediff(dd,state_custody_start_date,@pit_date)  >=8
							and tce.state_custody_start_date <= @pit_date
							and coalesce(Federal_Discharge_Date_force_18,@cutoff_date)>@pit_date
					ORDER BY  tce.ID_PRSN_CHILD,TCE.STATE_CUSTODY_START_DATE
					
			--delete episodes where start date greater than federal_discharge_date_force_18 which is now federal_discharge_date		
			delete from #episodes where state_custody_start_date > federal_discharge_date;

			-- there may be more than 1 point in time episode because of dirty data
				-- remove dirty data
				delete eps  from #episodes eps
				left join (select id_prsn_child,state_custody_start_date,row_number() over (partition by id_prsn_child
							order by id_prsn_child,state_custody_start_date asc,federal_discharge_date asc) as firstplc
							from #episodes ) firstplc
							on eps.id_prsn_child=firstplc.id_prsn_child
							and eps.state_custody_start_date=firstplc.state_custody_start_date and firstplc=1
				where firstplc.id_prsn_child is null;

			create index idx_date_prsn on #episodes(id_prsn_child,state_custody_start_date,pit_date)
	
				--  exclude children not in  DCFS custody at cohort begin date
				update eps
				set nonDCFS_mark=1
				from #episodes eps
				join (
						select PBCW3_Mark.id_removal_episode_fact
								,PBCW3_Mark.state_custody_start_date
								,PBCW3_Mark.federal_discharge_date
								,nd.*
								,row_number() 
									over (partition by nd.id_prsn 
										order by nd.id_prsn,nd.cust_begin asc,nd.cust_end asc) as fnc_FIRST
						from  (select id_prsn_child
									,id_removal_episode_fact
									,state_custody_start_date
									,federal_discharge_date 
								from #episodes) PBCW3_Mark
						join dbo.WRK_NONDCFS_ALL nd on nd.id_prsn=PBCW3_Mark.id_prsn_child   
						where nd.cust_begin<= @pit_date
							and ( nd.cust_end> @pit_date or nd.cust_end is null)
						) nonDCFS on nonDCFS.id_removal_episode_fact = eps.id_removal_episode_fact and fnc_FIRST=1;
			
			
						
					--**  exclude children not in DCFS custody at point in time

					delete eps  
					from #episodes eps where nonDCFS_mark = 1;
						
				/******************************  EVENTS **************************************************/			
				--**  save placement episode start and end dates for events matching
				--**  merge placement episode start and end dates into events file;
				--**  mark non-temporary, QUALIFYING cohort events
				--**  mark qualifying events (exclude non-family settings such as detention, hospital, CRC etc.;
				--**  all temporary events also excluded)
				--differs from David .. will NOT have multiple entry on same day because we are using tbl_child_placement_settings
				if object_ID('tempDB..#events') is not null drop table #events;
				select PBC4_mark.pit_date
						, PBC4_mark.state_custody_start_date
						, PBC4_mark.state_discharge_date
						,tcps.id_removal_episode_fact
						, tcps.Placement_Setting_Type_Code
						, pf.ID_PRVD_ORG_CAREGIVER
						, case when Placement_Setting_Type_Code in (2,5,10,11,15) then 1 else 0 end as qualevt
					--**  mark relative/non-relative events; save event information file
						, case  Placement_Setting_Type_Code  when 10 then 1 when 11 then 1 when 15 then 1 else 0 end as kinmark
						, pf.id_location_dim_worker as id_location_dim_worker_evt
					--,row_number() over (partition by tcps.id_removal_episode_fact
					--		order by tcps.id_removal_episode_fact,case when Placement_Setting_Type_Code in (2,5,10,11,15) then 1 else 0 end  desc) as casenum
						, tcps.id_prsn_child as ID_PRSN_PRIMCHILD
				into #events
				from dbo.tbl_child_placement_settings tcps
				join (select id_prsn_child,id_removal_episode_fact,state_custody_start_date,state_discharge_date, pit_date 
						from #episodes) PBC4_mark
				on tcps.id_prsn_child=PBC4_mark.id_prsn_child
					and tcps.id_removal_episode_fact=PBC4_mark.id_removal_episode_fact
				join CA.placement_fact pf on tcps.id_placement_fact=pf.id_placement_fact
				where tcps.entry_date <=PBC4_mark.pit_date				
						and (tcps.exit_date > PBC4_mark.pit_date or tcps.exit_date is null)
						and tcps.cd_epsd_type=1;

				update eps
				set qualEvent=qualevt,kinmark=evt.kinmark
				from #episodes eps
				join #events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact;


				update eps
				set 	[Removal_ID_Location_Dim_Worker_County_Cd] = cd_cnty
						 ,[Removal_ID_Location_Dim_Worker_County] = tx_cnty
				from #episodes eps
				join #events evt on evt.id_removal_episode_fact=eps.id_removal_episode_fact
				join CA.location_dim ld on ID_LOCATION_DIM=id_location_dim_worker_evt and cd_cnty <> '-'
				where cd_cnty <> [Removal_ID_Location_Dim_Worker_County_Cd]

				--**  use sibling relationship table to identify/count children placed together
				--**  match qualifying event marker to SIBLING ID: since table is reciprocal,
				--**  this connects the qualifying events marker to all siblings in a group
				if object_ID('tempDB..#siblings') is not null drop table #siblings;
				SELECT e.ID_PRSN_CHILD as ID_PRSN_PRIMCHILD
							,qualevent
							,pit_date
							,ID_SIBLING_RELATIONSHIP_FACT
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
					FROM CA.SIBLING_RELATIONSHIP_FACT
					join #episodes e on e.ID_PRSN_CHILD=SIBLING_RELATIONSHIP_FACT.ID_PRSN_SIBLING
					where dbo.IntDate_To_CalDate(id_calendar_dim_begin) <=pit_date
						and (dbo.IntDate_To_CalDate(id_calendar_dim_end) >pit_date 
								or dbo.IntDate_To_CalDate(id_calendar_dim_end)  is null)
				--**  add aggregate counts to working file		



				update #episodes
				set Nbr_sibs_together=N_sibs_together
						,Nbr_sibs_inplcmnt=N_sibs_inplcmnt
						,Nbr_sibs_qualplcmnt=N_sibs_qualplcmnt 
						,Nbr_Fullsibs=N_Fullsibs
						,Nbr_Halfsibs=N_Halfsibs
						,Nbr_Stepsibs=N_Stepsibs
						,Nbr_Totalsibs=N_Totalsibs
				from (select ID_PRSN_CHILD
									, sum(isnull(FL_TOGETHER,0)) as N_sibs_together
									, sum(isnull(FL_SIBLING_IN_PLACEMENT,0)) as N_sibs_inplcmnt
									, sum(isnull(sibqualplc,0)) as N_sibs_qualplcmnt
									, sum(isnull(Fullsib,0)) as N_Fullsibs
									, sum(isnull(Halfsib,0)) as N_Halfsibs
									, sum(isnull(Stepsib,0)) as N_Stepsibs
									, isnull(count(*),0) as N_Totalsibs
							from #siblings
							group by ID_PRSN_CHILD) q 
				where  q.id_prsn_child=#episodes.id_prsn_child

				--**  compute measures; note criterion for PRIMARY child also in a qualifying
				--**  placement to be included in the qualifying placement measures

				update #episodes
				set allsibs_together=1
				where 	Nbr_sibs_inplcmnt>0
				and Nbr_sibs_together=Nbr_sibs_inplcmnt
						

				update #episodes
				set somesibs_together = 1
				where Nbr_sibs_inplcmnt > 1 
				AND Nbr_sibs_together > 0 
				AND Nbr_sibs_together < Nbr_sibs_inplcmnt

				update #episodes
				set allorsomesibs_together = 1
				where allsibs_together = 1 or somesibs_together = 1

				update #episodes
				set allorsomequalsibs_together = 1
				where somequalsibs_together=1 or allqualsibs_together=1

				update #episodes
				set allsibs_together=case when allsibs_together is null then 0 else allsibs_together end
					,somesibs_together=case when somesibs_together is null then 0 else somesibs_together end
					,allorsomesibs_together=case when allorsomesibs_together is null then 0 else allorsomesibs_together end
				where Nbr_sibs_inplcmnt > 0;

				update #episodes
				set allqualsibs_together=1
				where qualEvent=1
				and Nbr_sibs_qualplcmnt > 0 AND Nbr_sibs_together = Nbr_sibs_qualplcmnt;

				update #episodes
				set somequalsibs_together=1
				where qualEvent = 1 AND Nbr_sibs_qualplcmnt > 1 AND Nbr_sibs_together > 0 
						 AND Nbr_sibs_together < Nbr_sibs_qualplcmnt;
				        
				update #episodes
				set  allorsomequalsibs_together=1
				where allqualsibs_together=1 or  somequalsibs_together=1 ;

				update #episodes
				set allqualsibs_together=case when allqualsibs_together is null then 0 else allqualsibs_together end
					,somequalsibs_together=case when somequalsibs_together is null then 0 else somequalsibs_together end
					,allorsomequalsibs_together=case when allorsomequalsibs_together is null then 0 else allorsomequalsibs_together end
				where Nbr_sibs_inplcmnt > 0 and qualEvent=1;


				--**  breakout by relative/nonrelative; for sibling groups where only some of the 
				--**  sibs are placed together, mark as (some) with relatives (vs. none with relatives)

				update eps
				set kincare=1
				from #episodes eps 
				where allorsomequalsibs_together=1 and kinmark>0;

				update eps
				set kincare=1
				from #episodes eps 
				where somequalsibs_together=0 and kinmark=qualEvent and kincare is null;

				update eps
				set kincare =0
				from #episodes eps 
				where allorsomequalsibs_together <=1 and kincare is null

				--**  compute markers for sibling group-based results'
				update #episodes
				set allsibs_together_grp=q.allsibs_together_grp
					,allorsomesibs_together_grp=q.allorsomesibs_together_grp
					,allqualsibs_together_grp=q.allqualsibs_together_grp
					,allorsomequalsibs_together_grp=q.allorsomequalsibs_together_grp
				from (
						select  ID_CASE
							,MAX(isnull(allsibs_together,0)) as allsibs_together_grp
							,MAX(isnull(allorsomesibs_together,0)) as allorsomesibs_together_grp
							,MAX(isnull(allqualsibs_together,0)) as allqualsibs_together_grp
							,MAX(isnull(allorsomequalsibs_together,0)) as allorsomequalsibs_together_grp
							,MAX(isnull(kincare,0)) as kincare_grp
						from #episodes
						group by ID_CASE ) q 
				where  q.id_case=#episodes.id_case


				update #episodes
				set sibgrpmark=1
				from (
							select * 
								,row_number() over (partition by id_case order by id_case) as casenum
							from #episodes
							where qualEvent=1   AND Nbr_sibs_qualplcmnt > 0 
						)tbl 
				where  tbl.id_removal_episode_fact=#episodes.id_removal_episode_fact
							and casenum=1;
							
				update #episodes
				set  allsibs_together_grp=null
					, allorsomesibs_together_grp=null
					 , allqualsibs_together_grp=null
					,  allorsomequalsibs_together_grp = null
					,  kincare_grp = null
				where sibgrpmark is null;

				----all siblings placed together	 				
				--select #episodes.kincare,allqualsibs_together,round(count(*) *1.00/  totK.cnt * 100,1)as prcnt_per_kin,
				--round(count(*) *1.00/  tot.cnt * 100,1)as prcnt_tot
				--from #episodes 
				--join  (select kincare, count(*) * 1.0000 as cnt from #episodes where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--	and allqualsibs_together in (0,1)  and kincare in (0,1)
				--	group by kincare
				--	) totK on totK.kincare=#episodes.kincare
				--,(select count(*) * 1.0000 as cnt from #episodes where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--	and allqualsibs_together in (0,1)  and kincare in (0,1)) tot
				--where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--and allqualsibs_together in (0,1)  and #episodes.kincare in (0,1)
				--group by #episodes.kincare,allqualsibs_together,totK.cnt,tot.cnt
				--order by allqualsibs_together,#episodes.kincare

				----all or some siblings placed together					
				--select #episodes.kincare,allorsomequalsibs_together,round(count(*) *1.00/  totK.cnt * 100,1)as prcnt_per_kin,
				--round(count(*) *1.00/  tot.cnt * 100,1)as prcnt_tot
				--from #episodes 
				--join  (select kincare, count(*) * 1.0000 as cnt from #episodes where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--	and allorsomequalsibs_together in (0,1)  and kincare in (0,1)
				--	group by kincare
				--	) totK on totK.kincare=#episodes.kincare
				--,(select count(*) * 1.0000 as cnt from #episodes where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--	and allorsomequalsibs_together in (0,1)  and kincare in (0,1)) tot
				--where qualEvent=1 and Nbr_sibs_qualplcmnt > 0
				--and allorsomequalsibs_together in (0,1)  and #episodes.kincare in (0,1)
				--group by #episodes.kincare,allorsomequalsibs_together,totK.cnt,tot.cnt
				--order by allorsomequalsibs_together,#episodes.kincare
				
				
			insert into  PRTL_PBCW4 
			 (		[pit_date]
				   ,[Age_Grouping_Cd]
				   ,[PK_GNDR]
				   ,[CD_RACE]
				   ,[census_hispanic_latino_origin_cd]
				   ,[init_cd_plcm_setng]
				   ,[last_cd_plcm_setng]
				   ,[Removal_County_Cd]
				   ,[Removal_ID_Location_Dim_Worker_County_Cd]
				   ,[FL_NEGLECT]
				   ,[FL_ABUSE]
				   ,[FL_SEXUAL_ABUSE]
				   ,[FL_OTHER_ABUSE]
				   ,[FL_MISSING]
				   ,[kincare]
				   ,[Nbr_Siblings]
				   ,[all_sib_together]
				   ,[some_sib_together]
				   ,[no_sib_together]
				   ,[total])
			SELECT         
			 pit_date
			 , Age_Grouping_Cd
			 , isnull(PK_GNDR,3) as PK_GNDR
			 , cd_race_census
			 , census_hispanic_latino_origin_cd
			 , init_cd_plcm_setng
			 , last_cd_plcm_setng
			 , Removal_County_Cd
			 , cast(Removal_ID_Location_Dim_Worker_County_Cd as int) as Removal_ID_Location_Dim_Worker_County_Cd 
			 , FL_NEGLECT
			 , FL_ABUSE
			 , FL_SEXUAL_ABUSE
			 , FL_OTHER_ABUSE
			 , FL_MISSING
			 ,  kincare
			 --, Nbr_Totalsibs
			 , Nbr_sibs_qualplcmnt
			 , sum(allqualsibs_together) as all_sib_together
			 , sum(somequalsibs_together) as some_sib_together
			 , sum(case when allorsomequalsibs_together = 0 then 1 else 0 end) as  no_sib_together
			 , count(*) as total
			FROM  #episodes
			where age_grouping_cd is not null
			and  qualEvent=1 and Nbr_sibs_qualplcmnt > 0
			group by pit_date
			 , Age_Grouping_Cd
			 , PK_GNDR
			 , cd_race_census
			 , census_hispanic_latino_origin_cd
			 , init_cd_plcm_setng
			 , last_cd_plcm_setng
			 , Removal_County_Cd
			 , Removal_ID_Location_Dim_Worker_County_Cd
			 , FL_NEGLECT
			 , FL_ABUSE
			 , FL_SEXUAL_ABUSE
			 , FL_OTHER_ABUSE
			 , FL_MISSING
			 ,  kincare
			 , Nbr_sibs_qualplcmnt
			order by 
				pit_date
			 ,	Age_Grouping_Cd
			 ,	PK_GNDR
			 ,	cd_race_census
			 ,  census_hispanic_latino_origin_cd
			 ,	init_cd_plcm_setng
			 ,	last_cd_plcm_setng
			 ,	Removal_County_Cd
			 ,	Removal_ID_Location_Dim_Worker_County_Cd
			 ,	FL_NEGLECT
			 ,	FL_ABUSE
			 ,	FL_SEXUAL_ABUSE
			 ,	FL_OTHER_ABUSE
			 ,	FL_MISSING
			 ,  kincare
			 ,	Nbr_sibs_qualplcmnt;

				
				set @pit_date = dateadd(mm,1,@pit_date);
	end
end --permission
else 
begin
	select 'Need permission key to execute this --BUILDS COHORTS!' as [Warning]
end
