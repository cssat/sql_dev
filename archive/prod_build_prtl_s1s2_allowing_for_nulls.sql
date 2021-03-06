--USE [dbCoreAdministrativeTables]
--GO
--/****** Object:  StoredProcedure [dbo].[prod_build_prtl_pbcs1s2]    Script Date: 10/17/2013 1:24:38 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
----USE [dbCoreAdministrativeTables]
----GO
----/****** Object:  StoredProcedure [dbo].[prod_build_PRTL_PBCS1S2]    Script Date: 10/15/2012 14:07:56 ******/
----SET ANSI_NULLS ON
----GO
----SET QUOTED_IDENTIFIER ON
----GO
----/********************************  TRACKING ***************************************************************
----DEScription by David Marshall taken from spss code
----***   "PBC_S1&S2_RepeatReferral.sps", syntax for computing PBC version of
----***    repeat referral rates, with breakouts for those receiving in-home services
----***    and/or entering placement following CPS referral, using 6-month initial cohorts;
----***    tracking investigated victims of both unfounded and founded referrals.
----***    Uses DW tables.
----***    07/2010  DBM


----DATE			Author			Desc
----2012-10-15		J.MESSERLY		Changed for  CD_RACE_CENSUS
----2012-11-27		J.MESSERLY		Changed @stopDate to get LAST FULL QUARTER OF DATA.
----2012-12-13		J.Messerly		Changed ADDED CENSUS_HISPANIC_LATINO_ORIGIN & initial @chstart
----***********************************************************************************************************/
--ALTER procedure [dbo].[prod_build_prtl_pbcs1s2](@permission_key datetime)
--as 
--if @permission_key=(select cutoff_date from ref_last_DW_transfer) 
--begin
		set nocount on
		truncate table PRTL_PBCS1S2;
		declare @chstart datetime
		declare @chend datetime
		--declare @studpdat datetime
		
		declare @date_type int
		set @date_type=1;
		--
		declare @stopDate datetime
		declare @cutoff_date datetime
		set @cutoff_date=(select max(cutoff_date) from ref_Last_DW_Transfer);

		declare @age_grouping_stop int
		declare @age_grouping_start int
		set @age_grouping_start=(select age_grouping_cd from ref_age_groupings where age_begin=0 and age_lessthan_end < 18 and age_grouping_cd <> 0)
		
		set @age_grouping_stop=(select age_grouping_cd from ref_age_groupings where age_lessthan_end=18 and age_begin <> 0)


		set @chstart = '2012-10-01 00:00:00.000'

		--set @chstart = '2008-01-01'
		if @date_type=1 
				begin	
					  
					set @chend=dateadd(mm,3,@chstart)
					-- set @stopDate= dateadd(mm,-3,(select max([Quarter]) from calendar_dim where [quarter] < @cutoff_date));
					set @stopDate= (select max_date_any from ref_lookup_max_date where id=6 );
				end
			else
				begin
					set @chend=dateadd(yy,1,@chstart)
					set @stopDate= (select dateadd(yy,-1,[Year]) from CA.calendar_dim where CALENDAR_DATE= @cutoff_date)
				end
	
		print @stopDate

		--set @stopDate= '2008-04-01'
		while @date_type <=2
		begin
				while @chstart <= @stopDate
				begin
				
				
					if object_id('tempdb..#pbcs1s2_work1') is not null drop table #pbcs1s2_work1

							select ivf.ID_INTAKE_VICTIM_FACT
									,ivf.ID_ACCESS_REPORT
									,ivf.ID_INVS
									,ivf.ID_PRSN_VCTM as ID_PRSN_CHILD
									,ivf.ID_INTAKE_FACT
									,ivf.ID_CALENDAR_DIM_IFF_RESPONSE_ATTEMPT
									,ivf.ID_CALENDAR_DIM_IFF_RESPONSE_COMPLETED
									,ivf.ID_CALENDAR_DIM_VICTIM_ADDED
									,ivf.ID_PEOPLE_DIM_CHILD
									,inf.ID_RESPONSE_TIME_EXP_DIM
									,ivf.CD_ACTIVITY_LOCATION_IFF
									,ivf.TX_ACTIVITY_LOCATION_IFF
									,ivf.ACTUAL_RESPONSE_TIME
									,ivf.ATTEMPTED_RESPONSE_TIME
									,ivf.DT_EXTENSION
									,ivf.DT_IFF_ATTEMPTED
									,ivf.DT_IFF_COMPLETED
									,ivf.DT_VICTIM_ADDED
									,inf.ID_WORKER_DIM_INTAKE
									,inf.ID_WORKER_DIM_INTAKE_SUPERVISOR
									,inf.ID_WORKER_DIM_CPS_SUPERVISOR
									,inf.ID_LOCATION_DIM_INTAKE_WORKER
									,inf.ID_PRVD_ORG_INTAKE
									,inf.ID_INTAKE_TYPE_DIM
									,inf.ID_CASE
									,inf.ID_INTAKE_ATTRIBUTE_DIM
									,dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_ACCESS_RCVD) as rfrd_date
									,(case
										when dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_INCD) IS NULL
										then dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_ACCESS_RCVD)
										else dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_INCD)
									end) as incd_date
									,dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_CPS_SPVR_DSCN) as spvrdscn_date
									--construct licensing flag at intake (non-missing provider ID) intlic_flag 0 'CPS' 1 'DLR' .
									,(case
										when inf.ID_PRVD_ORG_INTAKE = 0
										then 1
										else 0
									end) as intlic_flag 
							into #pbcs1s2_work1
							from CA.INTAKE_FACT inf
								 join CA.INTAKE_TYPE_DIM itd
									on inf.ID_INTAKE_TYPE_DIM = itd.ID_INTAKE_TYPE_DIM
							--connect intakes to all associated/identified victims;
								 join CA.INTAKE_VICTIM_FACT ivf
									on inf.ID_ACCESS_REPORT = ivf.ID_ACCESS_REPORT 
							where -- select screened-in CPS referrals received on or after entry cohort start date
								--dbo.IntDate_to_CalDate(inf.ID_CALENDAR_DIM_ACCESS_RCVD) >= @chstart 
								 inf.DT_ACCESS_RCVD >=@chstart
								and itd.CD_ACCESS_TYPE = 1 
								and itd.CD_FINAL_DECISION = 1
								--select investigated allegations
								--and (inf.DT_ACCESS_RCVD is not null and ivf.ID_INVS is not null)
								and ivf.ID_INVS is not null

			
							create nonclustered index idx_prsn_intake on #pbcs1s2_work1(id_intake_fact,ID_PRSN_CHILD);
			
							
							if object_id('tempdb..#vicalleg_list_prep') is not null 
								drop table #vicalleg_list_prep
						 
							select currow.ID_INTAKE_FACT
									,currow.ID_PRSN_CHILD as ID_PRSN_VICTIM
									,alf.ID_INVESTIGATION_ASSESSMENT_FACT
									--compute collapsed findings
									--0 'No finding/pending/missing' 1 'Unfounded/Inconclusive'   2 'Founded'
									
									,case when fnd.CD_FINDING in (-99,1,2,3,4,6,9,11) then 0
											when fnd.cd_finding in (7,8,10) then 1
											when fnd.cd_finding=5 then 2
									end as MCFfind
									--,(case		 
									--	when fnd.CD_FINDING=-99 then 0
									--	when 1 <= fnd.CD_FINDING AND fnd.CD_FINDING <=4 then 0
									--	when fnd.CD_FINDING=5 then 2
									--	when fnd.CD_FINDING=6 then 0
									--	when fnd.CD_FINDING=7 then 1
									--	when fnd.CD_FINDING=8 then 1
									--	when fnd.CD_FINDING=9 then 0
									--	when fnd.CD_FINDING=10 then 1
									--	when fnd.CD_FINDING=11 then 0
									--end) as MCFfind
									--,(case		 
									--	when fnd.CD_FINDING=5 then 1
									--	when fnd.CD_FINDING is null then 0
									--	else 0
									--end) as finding
									,(case		 
										when fnd.CD_FINDING=5 then 1
										else 0
									end) as finding
									--construct collapsed type of abuse variables
									--1 'Abandonment' 2 'Neglects' 3 'Physical Abuse/Death' 4 'Sexual Abuse' 5 'Sexual Exploitation'
									--,(case
									--	when 8 <= atd.CD_ALLEGATION and atd.CD_ALLEGATION <=12 then 2
									--	when atd.CD_ALLEGATION=1 then 1
									--	when atd.CD_ALLEGATION=2 then 2
									--	when atd.CD_ALLEGATION=3 then 3
									--	when atd.CD_ALLEGATION=7 then 3
									--	when atd.CD_ALLEGATION=5 then 4
									--	when atd.CD_ALLEGATION=6 then 5
									--end) as MCF_CAN
									,(case
										when atd.CD_ALLEGATION in (2,8,9,10,11,12) then 2
										when atd.CD_ALLEGATION in (3,7) then 3
										when atd.CD_ALLEGATION=5 then 4
										when atd.CD_ALLEGATION=1 then 1
										when atd.CD_ALLEGATION=6 then 5
									end) as MCF_CAN							--1 'Neglects/Abandonment' 2 'Physical Abuse/Death'  3 'Sexual Abuse/Exploitation'
									--,(case
									--	when 8 <= atd.CD_ALLEGATION and atd.CD_ALLEGATION <=12 then 1
									--	when atd.CD_ALLEGATION=1 then 1
									--	when atd.CD_ALLEGATION=2 then 1
									--	when atd.CD_ALLEGATION=3 then 2
									--	when atd.CD_ALLEGATION=7 then 2
									--	when atd.CD_ALLEGATION=5 then 3
									--	when atd.CD_ALLEGATION=6 then 3
									--end) as MCF_CANc
									,(case
										when atd.CD_ALLEGATION in (1,2,8,9,10,11,12) then 1
										when atd.CD_ALLEGATION in (3,7) then 2
										when atd.CD_ALLEGATION in (5,6) then 3
									end) as MCF_CANc							
									
									--sorted by priority founded, then priority SA>PA>PN
									--,row_number() over (partition by (currow.ID_INTAKE_FACT + alf.ID_PRSN_VICTIM)
									--					order by 
									--					(case		 
									--						when fnd.CD_FINDING=5 then 1
									--						when fnd.CD_FINDING is null then 0
									--						else 0
									--					end) DESC
									--					,(case
									--						when 8 <= atd.CD_ALLEGATION and atd.CD_ALLEGATION <=12 then 1
									--						when atd.CD_ALLEGATION=1 then 1
									--						when atd.CD_ALLEGATION=2 then 1
									--						when atd.CD_ALLEGATION=3 then 2
									--						when atd.CD_ALLEGATION=7 then 2
									--						when atd.CD_ALLEGATION=5 then 3
									--						when atd.CD_ALLEGATION=6 then 3
									--					end) DESC
									--) as intorder
									,row_number() over (partition by (currow.ID_INTAKE_FACT + alf.ID_PRSN_VICTIM)
														order by 
														(case		 
															when fnd.CD_FINDING=5 then 1
															else 0
														end) DESC
														,(case
																when atd.CD_ALLEGATION in (1,2,8,9,10,11,12) then 1
																when atd.CD_ALLEGATION in (3,7) then 2
																when atd.CD_ALLEGATION in (5,6) then 3
															end) DESC
									) as intorder
									,iaf.ID_CASE_DIM
									,iaf.ID_INVESTIGATION_TYPE_DIM
									,iaf.ID_PROVIDER_DIM
									,dsd.CD_INVS_DISP
									,dsd.TX_INVS_DISP
									,itd.CD_INVS_TYPE
									,itd.TX_INVS_TYPE
							into #vicalleg_list_prep
							from  CA.ALLEGATION_FACT alf
							--left join  #pbcs1s2_work1 currow
							--		on (alf.ID_INTAKE_FACT = currow.ID_INTAKE_FACT
							--			AND alf.ID_PRSN_VICTIM = currow.ID_PRSN_CHILD)
								join  #pbcs1s2_work1 currow
									on (alf.ID_INTAKE_FACT = currow.ID_INTAKE_FACT
										AND alf.ID_PRSN_VICTIM = currow.ID_PRSN_CHILD)						
								left join CA.INVESTIGATION_ASSESSMENT_FACT iaf
									on alf.ID_INVESTIGATION_ASSESSMENT_FACT = iaf.ID_INVESTIGATION_ASSESSMENT_FACT 
								left join CA.INVESTIGATION_TYPE_DIM itd
									on iaf.ID_INVESTIGATION_TYPE_DIM = itd.ID_INVESTIGATION_TYPE_DIM 
								left join CA.DISPOSITION_DIM dsd
									on iaf.ID_DISPOSITION_DIM = dsd.ID_DISPOSITION_DIM 
								left join CA.ABUSE_TYPE_DIM atd
									on alf.ID_ABUSE_TYPE_DIM = atd.ID_ABUSE_TYPE_DIM
								left join CA.FINDINGS_DIM fnd
									on alf.ID_FINDINGS_DIM = fnd.ID_FINDINGS_DIM
							--drop uninvestigated victim/allegations	
							where alf.ID_INVESTIGATION_ASSESSMENT_FACT is not null
								--and currow.ID_INTAKE_FACT is not null




							if object_id('tempdb..#vicalleg_list') is not null 
								drop table #vicalleg_list
							
							--unduplicate (restructure) by intake-victim; saving all abuse types
							select prp.ID_INTAKE_FACT
								,prp.ID_PRSN_VICTIM
								,prp.ID_INVESTIGATION_ASSESSMENT_FACT
								,max(case intorder when 1 then MCF_CAN else null end) MCF_CAN_1
								,max(case intorder when 2 then MCF_CAN else null end) MCF_CAN_2
								,max(case intorder when 3 then MCF_CAN else null end) MCF_CAN_3
								,max(case intorder when 1 then MCF_CANc else null end) MCF_CANc_1
								,max(case intorder when 2 then MCF_CANc else null end) MCF_CANc_2
								,max(case intorder when 3 then MCF_CANc else null end) MCF_CANc_3
								,max(case intorder when 1 then finding else null end) finding_1
								,max(case intorder when 2 then finding else null end) finding_2
								,max(case intorder when 3 then finding else null end) finding_3
								,max(case intorder when 1 then MCFfind else null end) MCFfind_1
								,max(case intorder when 2 then MCFfind else null end) MCFfind_2
								,max(case intorder when 3 then MCFfind else null end) MCFfind_3
								,prp.ID_CASE_DIM
								,prp.ID_INVESTIGATION_TYPE_DIM
								,prp.ID_PROVIDER_DIM
								,prp.CD_INVS_DISP
								,prp.TX_INVS_DISP
								,prp.CD_INVS_TYPE
								,prp.TX_INVS_TYPE

							into #vicalleg_list
							from #vicalleg_list_prep prp
							group by prp.ID_INTAKE_FACT
								,prp.ID_PRSN_VICTIM
								,prp.ID_INVESTIGATION_ASSESSMENT_FACT
								,prp.ID_CASE_DIM
								,prp.ID_INVESTIGATION_TYPE_DIM
								,prp.ID_PROVIDER_DIM
								,prp.CD_INVS_DISP
								,prp.TX_INVS_DISP
								,prp.CD_INVS_TYPE
								,prp.TX_INVS_TYPE



							create nonclustered index idx_temp_intake_fact_prsn on #vicalleg_list(id_intake_fact,id_prsn_victim);

							--add allegation variables to working file
							if object_id('tempdb..#pbcs1s2_work_2') is not null 
								drop table #pbcs1s2_work_2
								
							--compute finding variables (priority always founded)
							select currow.ID_INTAKE_VICTIM_FACT
									,currow.ID_ACCESS_REPORT 
									,currow.ID_INTAKE_FACT
									,currow.ID_PRSN_CHILD
									,currow.ACTUAL_RESPONSE_TIME
									,currow.ATTEMPTED_RESPONSE_TIME
									,currow.DT_IFF_COMPLETED
									,currow.DT_IFF_ATTEMPTED
									,currow.CD_ACTIVITY_LOCATION_IFF
									,currow.ID_CALENDAR_DIM_VICTIM_ADDED
									,currow.DT_VICTIM_ADDED
									,currow.ID_INVS
									,currow.ID_WORKER_DIM_INTAKE
									,currow.ID_LOCATION_DIM_INTAKE_WORKER
									,currow.ID_PRVD_ORG_INTAKE
									,currow.ID_CASE
									,currow.ID_INTAKE_ATTRIBUTE_DIM
									,lst.ID_INVESTIGATION_ASSESSMENT_FACT
									,lst.CD_INVS_TYPE
									,currow.intlic_flag
									,currow.rfrd_date
									,currow.incd_date
									,currow.spvrdscn_date
									--compute finding variables (priority always founded)
									--0 'No finding/pending/missing' 1 'Unfounded/Inconclusive'  2 'Founded' 
									,coalesce(lst.MCFfind_1, lst.MCFfind_2, lst.MCFfind_3, 1) as MCFfind 
									--  0 'Not founded' 1 'Founded' 
									,(case 
										when lst.finding_1 is null
										then 0
										else lst.finding_1 
									end) as finding
									-- compute combined type of abuse variable
									--'Neglects/Abandonment only' 2 'Physical Abuse/Death only'
									-- 3 'Sexual Abuse/exploitation only' 4 'SA plus other type(s)'  5 'PA plus neglects'
									-- 6 'other multiples' 0 'all abuse types missing'
									,(case 				
										when (MCF_CANc_2 is null and MCF_CANc_1 = 1)
											or MCF_CANc_3 is null and (MCF_CANc_2 = 1 and MCF_CANc_1 = 1)
											or (MCF_CANc_3 = 1 and MCF_CANc_2 = 1 and MCF_CANc_1 = 1)
										then 1
										when (MCF_CANc_2 is null and MCF_CANc_1 = 2)
											or MCF_CANc_3 is null and (MCF_CANc_2 = 2 and MCF_CANc_1 = 2)
											or (MCF_CANc_3 = 2 and MCF_CANc_2 = 2 and MCF_CANc_1 = 2)
										then 2
										when (MCF_CANc_2 is null and MCF_CANc_1 = 3)
											or (MCF_CANc_3 is null and MCF_CANc_2 = 3 and MCF_CANc_1 = 3)
										then 3
										when (MCF_CANc_2 < 3 or  MCF_CANc_3 < 3) and MCF_CANc_1  = 3
										then 4
										when (MCF_CANc_2 = 1 or  MCF_CANc_3 = 1) and MCF_CANc_1  = 2
										then 5
										when MCF_CANc_2 is null
										then 0
										else 6
									end) as multcan
									--Collapsed major abuse type
									--0 'unknown' 1 'Neglect' 2 'Physical Abuse' 3 'Sexual Abuse' 
									,(case
										when (MCF_CANc_2 is null and MCF_CANc_1 = 1)
											or MCF_CANc_3 is null and (MCF_CANc_2 = 1 and MCF_CANc_1 = 1)
											or (MCF_CANc_3 = 1 and MCF_CANc_2 = 1 and MCF_CANc_1 = 1)
										then 1
										when (MCF_CANc_2 is null and MCF_CANc_1 = 2)
											or MCF_CANc_3 is null and (MCF_CANc_2 = 2 and MCF_CANc_1 = 2)
											or (MCF_CANc_3 = 2 and MCF_CANc_2 = 2 and MCF_CANc_1 = 2)
										then 2
										when (MCF_CANc_2 is null and MCF_CANc_1 = 3)
											or (MCF_CANc_3 is null and MCF_CANc_2 = 3 and MCF_CANc_1 = 3)
										then 3
										when (MCF_CANc_2 < 3 or  MCF_CANc_3 < 3) and MCF_CANc_1  = 3
										then 3
										when (MCF_CANc_2 = 1 or  MCF_CANc_3 = 1) and MCF_CANc_1  = 2
										then 2
										when MCF_CANc_2 is null
										then 0
										else 1
									end) as majcan

		--JCM AND rfrd_date <= chend
									,(case 
										when rfrd_date >= @chstart
										then row_number() over (partition by ID_PRSN_CHILD order by rfrd_date)
										else null
									end) as refcount ---1 should be equal to initref in dm code
		--JCM left off AND rfrd_date <= chend 
									,(case 
										when rfrd_date >= @chstart and lst.finding_1 = 1
										then row_number() over (partition by ID_PRSN_CHILD order by lst.finding_1 desc, rfrd_date)
										else null
									end) as fndrefcount ----1 should be equal to initfndref in dm code

									--mark victim recurrences (subsequent foundeds after initial founded)
									,(case
										when rfrd_date >= @chstart and lst.finding_1 = 1 --and rfrd_date <= @studpdat 
											and row_number() over (
													partition by ID_PRSN_CHILD 
													order by lst.finding_1 desc, rfrd_date) > 1
										then 1
										else 0
									end) as vicrecur --victim recurrence? 0 'No' 1 'Yes' 
									--mark repeat referrals (subsequent referral, any finding, after initial referral)
									,(case
										when rfrd_date >= @chstart --and rfrd_date <= @studpdat
											and row_number() over (partition by ID_PRSN_CHILD order by rfrd_date) > 1
										then 1
										else 0
									end) as vicrptref  --Victim repeat referral (any finding)? 0 'No' 1 'Yes' 
									
							into #pbcs1s2_work_2 
							from #pbcs1s2_work1 currow
								left join #vicalleg_list lst
									on (currow.ID_PRSN_CHILD = lst.ID_PRSN_VICTIM
										and currow.ID_INTAKE_FACT = lst.ID_INTAKE_FACT)
							where --drop investigations without findings
								lst.ID_INVESTIGATION_ASSESSMENT_FACT is not null
							order by ID_PRSN_CHILD, rfrd_date


							create nonclustered index idx_refcount_prsn on #pbcs1s2_work_2(refcount,id_prsn_child);

							if object_id('tempdb..#pbcs1s2_work_3') is not null drop table #pbcs1s2_work_3

							-- mark initial and initial founded referrals for each victim
							select currow.ID_INTAKE_VICTIM_FACT
									,currow.ID_ACCESS_REPORT 
									,currow.ID_INTAKE_FACT
									,currow.ID_PRSN_CHILD
									,currow.ACTUAL_RESPONSE_TIME
									,currow.ATTEMPTED_RESPONSE_TIME
									,currow.DT_IFF_COMPLETED
									,currow.DT_IFF_ATTEMPTED
									,currow.CD_ACTIVITY_LOCATION_IFF
									,currow.ID_CALENDAR_DIM_VICTIM_ADDED
									,currow.DT_VICTIM_ADDED
									,currow.ID_INVS
									,currow.ID_WORKER_DIM_INTAKE
									,currow.ID_LOCATION_DIM_INTAKE_WORKER
									,currow.ID_PRVD_ORG_INTAKE
									,currow.ID_CASE
									,currow.ID_INTAKE_ATTRIBUTE_DIM
									,currow.ID_INVESTIGATION_ASSESSMENT_FACT
									,currow.CD_INVS_TYPE
									,currow.intlic_flag
									,currow.rfrd_date
									,currow.incd_date
									,currow.spvrdscn_date
									,currow.MCFfind 
									,currow.finding
									,currow.multcan
									,currow.majcan
									,(case 
										when currow.refcount = 1
										then 1
										else 0
									end) as initref
									,(case 
										when currow.fndrefcount = 1
										then 1
										else 0
									end) as initfndref
									,(case 
										when currow.fndrefcount > 1
										then 1
										else 0
									end) as vicrecur --victim recurrences (subsequent foundeds after initial founded)
									,(case
										when currow.fndrefcount > 1
										then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
										else NULL
									end) as daysfrfr  --'Days between founded referrals'
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 92
										then 1
										else 0
									end) as persro3 
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 183
										then 1
										else 0
									end) as persro6 
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 274
										then 1
										else 0
									end) as persro9 					
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 366
										then 1
										else 0
									end) as persro12
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 457
										then 1
										else 0
									end) as persro15
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 548
										then 1
										else 0
									end) as persro18
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 639
										then 1
										else 0
									end) as persro21
									
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 731
										then 1
										else 0
									end) as persro24
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 822
										then 1
										else 0
									end) as persro27
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 913
										then 1
										else 0
									end) as persro30
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1004
										then 1
										else 0
									end) as persro33
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1097
										then 1
										else 0
									end) as persro36
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1187
										then 1
										else 0
									end) as persro39
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1278
										then 1
										else 0
									end) as persro42
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1370
										then 1
										else 0
									end) as persro45
									,(case
										when (case
												when currow.fndrefcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1461
										then 1
										else 0
									end) as persro48
									,(case 
										when currow.refcount > 1
										then 1
										else 0
									end) as vicrptref  --'Victim repeat referral (any finding)?' 0-no 1-yes
									,(case 
										when datediff(dd, prevrow.rfrd_date, currow.rfrd_date)  is not null
										then datediff(dd, prevrow.rfrd_date, currow.rfrd_date)  
										else NULL
									end) as daysrcrc --'Days between referrals'
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 92
										then 1
										else 0
									end) as persrr3 
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 183
										then 1
										else 0
									end) as persrr6 
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 274
										then 1
										else 0
									end) as persrr9 					
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 366
										then 1
										else 0
									end) as persrr12
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 457
										then 1
										else 0
									end) as persrr15
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 548
										then 1
										else 0
									end) as persrr18
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 639
										then 1
										else 0
									end) as persrr21
									
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 731
										then 1
										else 0
									end) as persrr24
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 822
										then 1
										else 0
									end) as persrr27
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 913
										then 1
										else 0
									end) as persrr30
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1004
										then 1
										else 0
									end) as persrr33
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1097
										then 1
										else 0
									end) as persrr36
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1187
										then 1
										else 0
									end) as persrr39
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1278
										then 1
										else 0
									end) as persrr42
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1370
										then 1
										else 0
									end) as persrr45
									,(case
										when (case
												when currow.refcount > 1
												then datediff(dd, prevrow.rfrd_date, currow.rfrd_date) 
												else null
											end) <= 1461
										then 1
										else 0
									end) as persrr48
							into #pbcs1s2_work_3

							from #pbcs1s2_work_2 currow
								left join #pbcs1s2_work_2 nextrow
									on currow.refcount = nextrow.refcount - 1
									and currow.ID_PRSN_CHILD = nextrow.ID_PRSN_CHILD
								left join #pbcs1s2_work_2 prevrow
									on currow.refcount = prevrow.refcount + 1
									and currow.ID_PRSN_CHILD = prevrow.ID_PRSN_CHILD
									
									
							create nonclustered index idx_id_prsn_child on #pbcs1s2_work_3(id_prsn_child);

							if object_id('tempdb..#pbcs1s2_work_4') is not null 
								drop table #pbcs1s2_work_4

							select ID_INTAKE_VICTIM_FACT
									,ID_ACCESS_REPORT 
									,ID_INTAKE_FACT
									,ID_PRSN_CHILD
									,ACTUAL_RESPONSE_TIME
									,ATTEMPTED_RESPONSE_TIME
									,DT_IFF_COMPLETED
									,DT_IFF_ATTEMPTED
									,CD_ACTIVITY_LOCATION_IFF
									,ID_CALENDAR_DIM_VICTIM_ADDED
									,DT_VICTIM_ADDED
									,ID_INVS
									,ID_WORKER_DIM_INTAKE
									,ID_LOCATION_DIM_INTAKE_WORKER
									,ID_PRVD_ORG_INTAKE
									,ID_CASE
									,ID_INTAKE_ATTRIBUTE_DIM
									,ID_INVESTIGATION_ASSESSMENT_FACT
									,CD_INVS_TYPE
									,intlic_flag
									,rfrd_date
									,incd_date
									,spvrdscn_date
									,MCFfind 
									,finding
									,multcan
									,majcan
									,initref
									,initfndref 
									,max(vicrecur) over(partition by ID_PRSN_CHILD) as vicrecur_
									,max(daysfrfr) over(partition by ID_PRSN_CHILD) as daysfrfr_
									,max(persro3) over(partition by ID_PRSN_CHILD) as persro3_
									,max(persro6) over(partition by ID_PRSN_CHILD) as persro6_
									,max(persro9) over(partition by ID_PRSN_CHILD) as persro9_
									,max(persro12) over(partition by ID_PRSN_CHILD) as persro12_
									,max(persro15) over(partition by ID_PRSN_CHILD) as persro15_
									,max(persro18) over(partition by ID_PRSN_CHILD) as persro18_
									,max(persro21) over(partition by ID_PRSN_CHILD) as persro21_
									,max(persro24) over(partition by ID_PRSN_CHILD) as persro24_
									,max(persro27) over(partition by ID_PRSN_CHILD) as persro27_
									,max(persro30) over(partition by ID_PRSN_CHILD) as persro30_
									,max(persro33) over(partition by ID_PRSN_CHILD) as persro33_
									,max(persro36) over(partition by ID_PRSN_CHILD) as persro36_
									,max(persro39) over(partition by ID_PRSN_CHILD) as persro39_
									,max(persro42) over(partition by ID_PRSN_CHILD) as persro42_
									,max(persro45) over(partition by ID_PRSN_CHILD) as persro45_
									,max(persro48) over(partition by ID_PRSN_CHILD) as persro48_
									,max(vicrptref) over(partition by ID_PRSN_CHILD) as vicrptref_
									,max(daysrcrc) over(partition by ID_PRSN_CHILD) as daysrcrc_
									,max(persrr3) over(partition by ID_PRSN_CHILD) as persrr3_
									,max(persrr6) over(partition by ID_PRSN_CHILD) as persrr6_
									,max(persrr9) over(partition by ID_PRSN_CHILD) as persrr9_
									,max(persrr12) over(partition by ID_PRSN_CHILD) as persrr12_
									,max(persrr15) over(partition by ID_PRSN_CHILD) as persrr15_
									,max(persrr18) over(partition by ID_PRSN_CHILD) as persrr18_
									,max(persrr21) over(partition by ID_PRSN_CHILD) as persrr21_
									,max(persrr24) over(partition by ID_PRSN_CHILD) as persrr24_
									,max(persrr27) over(partition by ID_PRSN_CHILD) as persrr27_
									,max(persrr30) over(partition by ID_PRSN_CHILD) as persrr30_
									,max(persrr33) over(partition by ID_PRSN_CHILD) as persrr33_
									,max(persrr36) over(partition by ID_PRSN_CHILD) as persrr36_
									,max(persrr39) over(partition by ID_PRSN_CHILD) as persrr39_
									,max(persrr42) over(partition by ID_PRSN_CHILD) as persrr42_
									,max(persrr45) over(partition by ID_PRSN_CHILD) as persrr45_
									,max(persrr48) over(partition by ID_PRSN_CHILD) as persrr48_

							into #pbcs1s2_work_4
							from #pbcs1s2_work_3
							order by ID_PRSN_CHILD


							create nonclustered index idx_dates_flags on #pbcs1s2_work_4(rfrd_date,initref,initfndref);


							if object_id('tempdb..#pbcs1s2_work_5') is not null drop table #pbcs1s2_work_5

							select * 
							into #pbcs1s2_work_5
							from #pbcs1s2_work_4
							where (initref = 1 OR initfndref = 1)
								and (rfrd_date >= @chstart and rfrd_date < @chend)
							order by ID_PRSN_CHILD
							
							create nonclustered index idx_prsn_rfrd_date on #pbcs1s2_work_5(id_prsn_child,rfrd_date);
							create nonclustered index idx_case_rfrd_date on #pbcs1s2_work_5(id_case,rfrd_date);
							
							if object_id('tempdb..#pbcs1s2_work_6') is not null 
								drop table #pbcs1s2_work_6

							select work_5.ID_INTAKE_VICTIM_FACT 
									,work_5.ID_ACCESS_REPORT 
									,work_5.ID_INTAKE_FACT
									,work_5.ID_PRSN_CHILD
									,work_5.ACTUAL_RESPONSE_TIME
									,work_5.ATTEMPTED_RESPONSE_TIME
									,work_5.DT_IFF_COMPLETED
									,work_5.DT_IFF_ATTEMPTED
									,work_5.CD_ACTIVITY_LOCATION_IFF
									,work_5.ID_CALENDAR_DIM_VICTIM_ADDED
									,work_5.DT_VICTIM_ADDED
									,work_5.ID_INVS
									,work_5.ID_WORKER_DIM_INTAKE
									,work_5.ID_LOCATION_DIM_INTAKE_WORKER 
									,work_5.ID_PRVD_ORG_INTAKE
									,work_5.ID_CASE 
									,work_5.ID_INTAKE_ATTRIBUTE_DIM
									,work_5.ID_INVESTIGATION_ASSESSMENT_FACT
									,work_5.CD_INVS_TYPE
									,work_5.intlic_flag
									,work_5.rfrd_date
									,work_5.incd_date
									,work_5.spvrdscn_date
									,work_5.MCFfind
									,work_5.finding
									,work_5.multcan
									,work_5.majcan
									,work_5.initref
									,work_5.initfndref
									,work_5.vicrecur_
									,work_5.daysfrfr_
									,work_5.persro3_
									,work_5.persro6_
									,work_5.persro9_
									,work_5.persro12_
									,work_5.persro15_
									,work_5.persro18_
									,work_5.persro21_
									,work_5.persro24_
									,work_5.persro27_
									,work_5.persro30_
									,work_5.persro33_
									,work_5.persro36_
									,work_5.persro39_
									,work_5.persro42_
									,work_5.persro45_
									,work_5.persro48_
									,work_5.vicrptref_
									,work_5.daysrcrc_
									,work_5.persrr3_
									,work_5.persrr6_
									,work_5.persrr9_
									,work_5.persrr12_
									,work_5.persrr15_
									,work_5.persrr18_
									,work_5.persrr21_
									,work_5.persrr24_
									,work_5.persrr27_
									,work_5.persrr30_
									,work_5.persrr33_
									,work_5.persrr36_
									,work_5.persrr39_
									,work_5.persrr42_
									,work_5.persrr45_
									,work_5.persrr48_
									,ped.ID_PEOPLE_DIM
									,ped.DT_BIRTH
									,ped.FL_DT_BIRTH_ESTIMATED
									,ped.FL_DECEASED
									,ped.DT_DEATH
									,ped.CD_GNDR
									,ped.TX_GNDR
									,ped.CD_CMBN_ETHN
									,ped.TX_CMBN_ETHN
									,ped.CD_RACE
									,ped.TX_RACE
									,ped.CD_RACE_TWO
									,ped.CD_RACE_THREE
									,ped.CD_RACE_FOUR
									,ped.CD_RACE_FIVE
									,ped.CD_HSPNC
									,ped.TX_HSPNC
									,ped.CD_INDN
									,ped.TX_INDN
									,ped.TX_BRAAM_RACE
									,ped.TX_MULTIRACE
									,ped.MULTI_RACE_MASK
									,ped.CD_MRTL_STAT
									,ped.TX_MRTL_STAT
									,ped.CD_PRNTL_RLTNSHP
									,ped.TX_PRNTL_RLTNSHP
									,ped.FL_DANGER_TO_WORKER
									,ped.FL_PHYS_DISABLED
									,ped.FL_PRSN_MALTREATER
									,ped.FL_SEX_AGGRESIVE_YOUTH
									,ped.FL_TEEN_PARENT
									,ped.FL_VIS_HEARING_IMPR
									--,(case
									--	when ped.TX_BRAAM_RACE = 'Native American'
									--	then 1 
									--	when ped.TX_BRAAM_RACE = 'Asian/PI'
									--	then 2 
									--	when ped.TX_BRAAM_RACE = 'African American'
									--	then 3 
									--	when ped.TX_BRAAM_RACE = 'Hispanic'
									--	then 4
									--	when ped.TX_BRAAM_RACE = 'White'
									--	then 5 
									--	when ped.TX_BRAAM_RACE = 'Unknown'
									--	then 9
									--end) as RACE_OF_CHILD
									--,eth.cd_race  as RACE_OF_CHILD
									,ped.cd_race_Census as RACE_OF_CHILD
									,ped.census_hispanic_latino_origin_cd
									,dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) as ageatref 
									,(case 
										when dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) in (0,1)
										then 1
										when dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) <= -1
										then 0
										when dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) in (2,3,4,5)
										then 2
										when dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) in (6,7,8,9,10,11)
										then 3
										when dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) in (12,13,14,15,16,17)
										then 4
										else 5
									end) as ageatrefc
							into #pbcs1s2_work_6
							from #pbcs1s2_work_5 work_5
								left join CA.PEOPLE_DIM ped
									on work_5.ID_PRSN_CHILD = ped.ID_PRSN
								--left join ref_lookup_ethnicity eth on eth.tx_race=ped.TX_BRAAM_RACE
							where ped.IS_CURRENT = 1
								and dbo.fnc_datediff_yrs(ped.DT_BIRTH, work_5.rfrd_date) <= 17 --this calculation will cause counts to be off slightly from dam
							order by work_5.ID_CASE, work_5.rfrd_date

							create nonclustered index idx_case_prsn_date on #pbcs1s2_work_6(ID_CASE,ID_PRSN_CHILD,rfrd_date);
							create nonclustered index idx_case on #pbcs1s2_work_6(id_case);
							if object_id('tempdb..#pbcs1s2_list1') is not null drop table #pbcs1s2_list1;

							select 
								ID_CASE
								,min(ID_PRSN_CHILD) as ID_PRSN_CHILD_
								,min(rfrd_date) as rfrd_date_
							into #pbcs1s2_list1
							from #pbcs1s2_work_6
							group by 
								ID_CASE
							order by
								ID_CASE
								,min(rfrd_date)
								
							create nonclustered index idx_case_referral_date  on #pbcs1s2_list1(ID_CASE,rfrd_date_);
							
							--this table eliminates the need for the creation of DW_authwork
							if object_id('tempdb..#pbcs1s2_pymnt_list') is not null 
								drop table #pbcs1s2_pymnt_list

							select atf.ID_CASE as ID_CASE_
									,std.CD_SRVC 
									,dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN) as auth_begin 
									,datediff(dd, lst.rfrd_date_, dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN)) as daysrfsv --not yet tested
									--,cast(dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN) - lst.rfrd_date_ as int) as daysrfsv 
									,(case 
										when std.CD_SRVC = 74 then 1
										when std.CD_SRVC = 76 then 1
										when std.CD_SRVC = 85 then 1
										when std.CD_SRVC = 461 then 2
										when std.CD_SRVC = 462 then 2
										when std.CD_SRVC = 17800 then 2
										when std.CD_SRVC = 410 then 5
										when std.CD_SRVC = 616 then 5
										when std.CD_SRVC = 411 then 7
										when std.CD_SRVC = 1355 then 6
										when std.CD_SRVC = 1356 then 6
										when std.CD_SRVC = 444 then 7
										when std.CD_SRVC = 566 then 7
										when std.CD_SRVC is null then 0
										when 306 <= std.CD_SRVC and std.CD_SRVC <=320 then 1
										when 567 <= std.CD_SRVC and std.CD_SRVC <=578 then 1
										when 171 <= std.CD_SRVC and std.CD_SRVC <=173 then 2
				--changed joe's code						
				--						when 175 <= std.CD_SRVC and std.CD_SRVC <=177 then 1
										when 175 <= std.CD_SRVC and std.CD_SRVC <=177 then 2
										when 249 <= std.CD_SRVC and std.CD_SRVC <=252 then 2
										when 446 <= std.CD_SRVC and std.CD_SRVC <=457 then 2
										when 579 <= std.CD_SRVC and std.CD_SRVC <=581 then 2
										when 598 <= std.CD_SRVC and std.CD_SRVC <=605 then 2
										when 1352 <= std.CD_SRVC and std.CD_SRVC <=1354 then 2
										when 177009 <= std.CD_SRVC and std.CD_SRVC <=177012 then 2
										when 179000 <= std.CD_SRVC and std.CD_SRVC <=179009 then 2
										when 204 <= std.CD_SRVC and std.CD_SRVC <=206 then 3
										when 243 <= std.CD_SRVC and std.CD_SRVC <=245 then 3
										when 612 <= std.CD_SRVC and std.CD_SRVC <=615 then 3
										when 109000 <= std.CD_SRVC and std.CD_SRVC <=109002 then 3
										when 215 <= std.CD_SRVC and std.CD_SRVC <=597 then 4
										when 582 <= std.CD_SRVC and std.CD_SRVC <=218 then 4
										when 430 <= std.CD_SRVC and std.CD_SRVC <=435 then 6
										when 606 <= std.CD_SRVC and std.CD_SRVC <=611 then 6
										when 185001 <= std.CD_SRVC and std.CD_SRVC <=185006 then 6
										else 0
									end) as FFSserv			
									,(case 
										when std.CD_SRVC IN (74,204,243,249,250,308,315,316,319,320,430,431,432,461,462,
											109000,185001,185002,185003) then 1
										else 0
									end) as IHFFSsrvc
									,(case 
										when std.CD_SRVC IN (3,6,9,12,13,35,40,81,88,93,96,99,104,108,115,120,122,125,128,131,264,
											367,369,371,376,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,
											705,172000,173000,173002,173004,173005,173007,173010,173014,173016,173023,173028,173033,
											173039) then 1
										else 0
									end) as IHmiscsrvc
									,(case 
										when std.CD_SRVC IN (42,45,48,51,52,56,58,59,61,63,64,81,268,271,273,1095,1097,1099,
										   1110,1127,1130,1132,1133,1136,1138,1140,1142,1144,1146,1148,1150,1152,1154,1156,1158,
										   1160,1162,1164,1166,1168,1170,1172,1174,1176,1178,1199,1202,1204,1213,1214,1215,1218,
										   1220,1596,1603,1620,1623,1625,1627,1629,1631,1633,1635,1637,1639,1641,1643,1645,1647,
										   1649,1651,1653,1655,1657,1659,1661,1663,1665,1667,1669,1672,1674,1676,1680,1681,1682,
										   1685,1687,176001,176004,176006,176008,176010,176012,176014,176018,176020,176022,
										   177000,177002,177004,177007) then 1
										when std.CD_SRVC IN (43,46,47,49,50,53,54,55,57,60,62,65,82,247,248,272,274,276,285,
										   286,399,407,470,1083,1085,1086,1087,1088,1089,1090,1091,1092,1094,1096,1098,1100,1101,1102,
										   1103,1104,1109,1118,1119,1120,1121,1122,1123,1124,1125,1126,1129,
										   1131,1134,1135,1137,1139,1141,1143,1145,1147,1149,1151,1153,1155,1157,1159,1161,1163,
										   1165,1167,1169,1171,1173,1175,1177,1179,1180,1181,1182,1190,1191,1192,1193,1194,1195,1196,
										   1198,1201,1203,1217,1219,
										   1595,1602,1614,1615,1616,1617,1618,1619,1622,1624,1626,1628,1630,1632,1634,1636,1638,1640,
										   1642,1644,1648,1650,1652,1654,1656,1658,1660,1662,1664,1666,1668,1671,1673,1675,1677,1678,
										   1679,1684,1686,119001,176002,176003,176005,176007,176009,176011,176013,176015,176016,
										   176017,176019,176021,176023,177001,177003,177006,179007,179008) then 2
										when std.CD_SRVC IN (41,1183,1184,1185,1186,1187,1188,1189,1197,1200,1210,1211,1212,
											1611,1612,1613,1670) then 3
										else 0
									end) as BRStype
									,(case 
										when std.CD_SRVC IN (74,204,243,249,250,308,315,316,319,320,430,431,432,461,462,
											109000,185001,185002,185003) then 1
										when std.CD_SRVC IN (3,6,9,12,13,35,40,81,88,93,96,99,104,108,115,120,122,125,128,131,264,
											367,369,371,376,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,
											705,172000,173000,173002,173004,173005,173007,173010,173014,173016,173023,173028,173033,
											173039) then 1
										when std.CD_SRVC IN (42,45,48,51,52,56,58,59,61,63,64,81,268,271,273,1095,1097,1099,
										   1110,1127,1130,1132,1133,1136,1138,1140,1142,1144,1146,1148,1150,1152,1154,1156,1158,
										   1160,1162,1164,1166,1168,1170,1172,1174,1176,1178,1199,1202,1204,1213,1214,1215,1218,
										   1220,1596,1603,1620,1623,1625,1627,1629,1631,1633,1635,1637,1639,1641,1643,1645,1647,
										   1649,1651,1653,1655,1657,1659,1661,1663,1665,1667,1669,1672,1674,1676,1680,1681,1682,
										   1685,1687,176001,176004,176006,176008,176010,176012,176014,176018,176020,176022,
										   177000,177002,177004,177007) then 1
										else 0
									end) as IHsrvcs
									,row_number() over (partition by lst.ID_CASE order by 
															atf.ID_CASE 
															,(case 
																when std.CD_SRVC IN (74,204,243,249,250,308,315,316,319,320,430,431,432,461,462,
																	109000,185001,185002,185003) then 1
																when std.CD_SRVC IN (3,6,9,12,13,35,40,81,88,93,96,99,104,108,115,120,122,125,128,131,264,
																	367,369,371,376,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,
																	705,172000,173000,173002,173004,173005,173007,173010,173014,173016,173023,173028,173033,
																	173039) then 1
																when std.CD_SRVC IN (42,45,48,51,52,56,58,59,61,63,64,81,268,271,273,1095,1097,1099,
																   1110,1127,1130,1132,1133,1136,1138,1140,1142,1144,1146,1148,1150,1152,1154,1156,1158,
																   1160,1162,1164,1166,1168,1170,1172,1174,1176,1178,1199,1202,1204,1213,1214,1215,1218,
																   1220,1596,1603,1620,1623,1625,1627,1629,1631,1633,1635,1637,1639,1641,1643,1645,1647,
																   1649,1651,1653,1655,1657,1659,1661,1663,1665,1667,1669,1672,1674,1676,1680,1681,1682,
																   1685,1687,176001,176004,176006,176008,176010,176012,176014,176018,176020,176022,
																   177000,177002,177004,177007) then 1
																else 0
															end) desc
															,cast(dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN) - lst.rfrd_date_ as int)) as casecount
							into #pbcs1s2_pymnt_list
							from CA.AUTHORIZATION_FACT atf
								left join CA.SERVICE_TYPE_DIM std 
									on atf.ID_SERVICE_TYPE_DIM = std.ID_SERVICE_TYPE_DIM
								 join #pbcs1s2_list1 lst
									on atf.ID_CASE = lst.ID_CASE
							where ((dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN) - lst.rfrd_date_) >= 0 
								and (dbo.IntDate_to_CalDate(atf.ID_CALENDAR_DIM_AUTH_BEGIN) - lst.rfrd_date_) <= 120)

							
							create nonclustered index idx_id_case on #pbcs1s2_pymnt_list(ID_CASE_);

							if object_id('tempdb..#pbcs1s2_work_7') is not null drop table #pbcs1s2_work_7;
							select * 
								,row_number() over (partition by ID_CASE order by ID_CASE, rfrd_date) as casecount2
							into #pbcs1s2_work_7
							from #pbcs1s2_work_6 work_6
								left join (select * from #pbcs1s2_pymnt_list where casecount = 1) sub  
									on work_6.ID_CASE = sub.ID_CASE_
							order by work_6.id_case

							if object_id('tempdb..#pbcs1s2_list2') is not null drop table #pbcs1s2_list2
							select ID_CASE
									,rfrd_date
							into #pbcs1s2_list2
							from #pbcs1s2_work_7
							where casecount2 = 1
							
							create nonclustered index idx_id_case on #pbcs1s2_list2(id_case,rfrd_date);

							if object_id('tempdb..#pbcs1s2_asgn_list') is not null 
								drop table #pbcs1s2_asgn_list

							select list.ID_CASE
									,asf.ID_ASGN
									,asf.ID_WORKER_DIM
									,asf.ID_LOCATION_DIM
									,dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN) as asgn_begin
									,dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_END) as asgn_end
									,asd.CD_ASGN_CTGRY
									,asd.TX_ASGN_CTGRY
									,asd.CD_ASGN_TYPE
									,asd.TX_ASGN_TYPE
									,asd.CD_ASGN_ROLE
									,asd.TX_ASGN_ROLE
									,asd.CD_ASGN_RSPNS
									,asd.TX_ASGN_RSPNS
									--'Days, referral to worker assignment'
									,datediff(dd, list.rfrd_date, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN)) as daysrefasgn
									--add assignment codes and mark in-home only, excluding courtesy supervision
									--IHSasgn 0 'No' 1 'Yes' .
									,(case 
										when asd.CD_ASGN_CTGRY = 1
											and asd.CD_ASGN_RSPNS = 7
											and asd.CD_ASGN_TYPE IN (4,5,8,9)
											and asd.CD_ASGN_ROLE NOT IN (3,4)
										then 1
										else 0
									end) as IHSasgn
									,row_number() over (partition by list.ID_CASE 
														order by list.ID_CASE
																	,(case 
																		when asd.CD_ASGN_CTGRY = 1
																			and asd.CD_ASGN_RSPNS = 7
																			and asd.CD_ASGN_TYPE IN (4,5,8,9)
																			and asd.CD_ASGN_ROLE NOT IN (3,4)
																		then 1
																		else 0
																	end) desc
																	,datediff(dd, list.rfrd_date, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN))) as casecount3

							into #pbcs1s2_asgn_list
							from #pbcs1s2_list2 list
								left join CA.ASSIGNMENT_FACT asf
									on list.ID_CASE = asf.ID_CASE
								left join CA.ASSIGNMENT_ATTRIBUTE_DIM asd
									on asf.ID_ASSIGNMENT_ATTRIBUTE_DIM = asd.ID_ASSIGNMENT_ATTRIBUTE_DIM 
							--select assignments beginning 5 days before to 183 days after referral
							where (datediff(dd, list.rfrd_date, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN)) >= -5 
									and datediff(dd, list.rfrd_date, dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN))  <= 183)
							order by list.id_case

							create nonclustered index idx_id_case_tmp on #pbcs1s2_asgn_list(id_case);
							
						-- unduplicate, selecting in-home assignment closest to referral
							if object_id('tempdb..#pbcs1s2_work_8') is not null 
								drop table #pbcs1s2_work_8
							select work_7.ID_INTAKE_VICTIM_FACT
									,work_7.ID_ACCESS_REPORT
									,work_7.ID_INTAKE_FACT
									,work_7.ID_PRSN_CHILD
									,work_7.ACTUAL_RESPONSE_TIME
									,work_7.ATTEMPTED_RESPONSE_TIME
									,work_7.DT_IFF_COMPLETED
									,work_7.DT_IFF_ATTEMPTED
									,work_7.CD_ACTIVITY_LOCATION_IFF
									,work_7.ID_CALENDAR_DIM_VICTIM_ADDED
									,work_7.DT_VICTIM_ADDED
									,work_7.ID_INVS
									,work_7.ID_WORKER_DIM_INTAKE
									,work_7.ID_LOCATION_DIM_INTAKE_WORKER
									,work_7.ID_PRVD_ORG_INTAKE
									,work_7.ID_INTAKE_ATTRIBUTE_DIM
									,work_7.ID_INVESTIGATION_ASSESSMENT_FACT
									,work_7.CD_INVS_TYPE
									,work_7.intlic_flag
									,work_7.rfrd_date
									,work_7.incd_date
									,work_7.spvrdscn_date
									,work_7.MCFfind
									,work_7.finding
									,work_7.multcan
									,work_7.majcan
									,work_7.initref
									,work_7.initfndref
									,work_7.vicrecur_
									,work_7.daysfrfr_
									,work_7.persro3_
									,work_7.persro6_
									,work_7.persro9_
									,work_7.persro12_
									,work_7.persro15_
									,work_7.persro18_
									,work_7.persro21_
									,work_7.persro24_
									,work_7.persro27_
									,work_7.persro30_
									,work_7.persro33_
									,work_7.persro36_
									,work_7.persro39_
									,work_7.persro42_
									,work_7.persro45_
									,work_7.persro48_
									,work_7.vicrptref_
									,work_7.daysrcrc_
									,work_7.persrr3_
									,work_7.persrr6_
									,work_7.persrr9_
									,work_7.persrr12_
									,work_7.persrr15_
									,work_7.persrr18_
									,work_7.persrr21_
									,work_7.persrr24_
									,work_7.persrr27_
									,work_7.persrr30_
									,work_7.persrr33_
									,work_7.persrr36_
									,work_7.persrr39_
									,work_7.persrr42_
									,work_7.persrr45_
									,work_7.persrr48_
									,work_7.ID_PEOPLE_DIM
									,work_7.DT_BIRTH
									,work_7.FL_DT_BIRTH_ESTIMATED
									,work_7.FL_DECEASED
									,work_7.DT_DEATH
									,work_7.CD_GNDR
									,work_7.TX_GNDR
									,work_7.CD_CMBN_ETHN
									,work_7.TX_CMBN_ETHN
									,work_7.CD_RACE
									,work_7.TX_RACE
									,work_7.CD_RACE_TWO
									,work_7.CD_RACE_THREE
									,work_7.CD_RACE_FOUR
									,work_7.CD_RACE_FIVE
									,work_7.CD_HSPNC
									,work_7.TX_HSPNC
									,work_7.CD_INDN
									,work_7.TX_INDN
									,work_7.TX_BRAAM_RACE
									,work_7.TX_MULTIRACE
									,work_7.MULTI_RACE_MASK
									,work_7.CD_MRTL_STAT
									,work_7.TX_MRTL_STAT
									,work_7.CD_PRNTL_RLTNSHP
									,work_7.TX_PRNTL_RLTNSHP
									,work_7.FL_DANGER_TO_WORKER
									,work_7.FL_PHYS_DISABLED
									,work_7.FL_PRSN_MALTREATER
									,work_7.FL_SEX_AGGRESIVE_YOUTH
									,work_7.FL_TEEN_PARENT
									,work_7.FL_VIS_HEARING_IMPR
									,work_7.RACE_OF_CHILD
									,work_7.census_hispanic_latino_origin_cd
									,work_7.ageatref 
									,work_7.ageatrefc
									,work_7.CD_SRVC 
									,work_7.auth_begin 
									,work_7.daysrfsv
									,work_7.FFSserv			
									,work_7.IHFFSsrvc
									,work_7.IHmiscsrvc
									,work_7.BRStype
									,work_7.IHsrvcs
									,list.ID_CASE
									,list.ID_ASGN
									,list.ID_WORKER_DIM
									,list.ID_LOCATION_DIM
									,list.asgn_begin
									,list.asgn_end
									,list.CD_ASGN_CTGRY
									,list.TX_ASGN_CTGRY
									,list.CD_ASGN_TYPE
									,list.TX_ASGN_TYPE
									,list.CD_ASGN_ROLE
									,list.TX_ASGN_ROLE
									,list.CD_ASGN_RSPNS
									,list.TX_ASGN_RSPNS
									,list.daysrefasgn
									,list.IHSasgn
							into #pbcs1s2_work_8
							from #pbcs1s2_work_7 work_7
								left join #pbcs1s2_asgn_list list
									on work_7.ID_CASE = list.ID_CASE
							where casecount3 = 1
							order by work_7.id_case, list.IHSasgn desc, list.daysrefasgn

							if object_id('tempdb..#pbcs1s2_list3') is not null 
								drop table #pbcs1s2_list3
							select ID_PRSN_CHILD as ID_PRSN_CHILD_
									,rfrd_date
									,row_number() over (partition by ID_PRSN_CHILD order by ID_PRSN_CHILD, rfrd_date) childcount1
							into #pbcs1s2_list3
							from #pbcs1s2_work_8

							if object_id('tempdb..#pbcs1s2_list4') is not null 
								drop table #pbcs1s2_list4
							select ID_PRSN_CHILD_
									,rfrd_date
							into #pbcs1s2_list4
							from #pbcs1s2_list3
							where childcount1 = 1
							
							create nonclustered index idx_list4_prsn_date on #pbcs1s2_list4(ID_PRSN_CHILD_,rfrd_date);

						--add marker/information for children placed following referral
							if object_id('tempdb..#pbcs1s2_list5') is not null 
								drop table #pbcs1s2_list5
							select ref.ID_PRSN_CHILD
								,ref.ID_REMOVAL_EPISODE_FACT
								,ref.ID_EPSD
								,ref.ID_CALENDAR_DIM_AFCARS_END
								,ref.ID_CALENDAR_DIM_BEGIN
								,ref.ID_CALENDAR_DIM_END
								,ref.ID_CALENDAR_DIM_FIRST_HEALTH_SAFETY_VISIT
								,ref.ID_CASE_DIM
								,ref.ID_DISCHARGE_REASON_DIM
								,ref.ID_FAMILY_STRUCTURE_DIM
								,ref.ID_LOCATION_DIM_REMOVAL
								,ref.ID_LOCATION_DIM_WORKER
								,ref.ID_PEOPLE_DIM_CHILD
								,ref.ID_PEOPLE_DIM_PARENT_PRIMARY
								,ref.ID_PEOPLE_DIM_PARENT_SECONDARY
								,ref.ID_PLACEMENT_CARE_AUTH_DIM
								,ref.ID_REMOVAL_DIM
								,ref.ID_WORKER_DIM_CURRENT
								,ref.ID_WORKER_DIM_ORIGINAL
								,ref.FL_AAFC
								,ref.FL_ABANDONMENT
								,ref.FL_ABUSE
								,ref.FL_CARETAKER_INABILITY_COPE
								,ref.FL_CHILD_ABUSE_ALCOHOL
								,ref.FL_CHILD_ABUSES_DRUG
								,ref.FL_CHILD_BEHAVIOR_PROBLEMS
								,ref.FL_CHILD_CLINICALLY_DIAGNOSED
								,ref.FL_IN_ERROR
								,ref.FL_INADEQUATE_HOUSNG
								,ref.FL_NEGLECT
								,ref.FL_PARENT_ABUSE_ALCOHOL
								,ref.FL_PARENT_DEATH
								,ref.FL_PARENT_DRUG_ABUSE
								,ref.FL_PARENT_INCARCERATION
								,ref.FL_PHYSICAL_ABUSE
								,ref.FL_REENTRY
								,ref.FL_RELINQUISHMENT
								,ref.FL_SEX_ABUSE
								,ref.CHILD_AGE_REMOVAL_BEGIN
								,ref.CHILD_AGE_REMOVAL_END
								,ref.LENGTH_OF_STAY
								,ref.FL_TRIAL_RETURN_HOME
								,ref.ID_PRSN_PARENT_PRIMARY
								,ref.ID_PRSN_PARENT_SECONDARY
								,red.CD_RMVL_MNR
								,red.TX_RMVL_MNR
								,drd.CD_DSCH_RSN
								,drd.TX_DSCH_RSN
								,drd.CD_PLCM_DSCH_RSN
								,drd.TX_PLCM_DSCH_RSN
								,dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_BEGIN) as ep_begin
								--,dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_AFCARS_BEGIN) as afcars_ep_begin (we don't have this field)
								,dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_END) as ep_end
								,dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_AFCARS_END) as afcars_ep_end
								--Days, referral to placement
								,datediff(dd, list4.rfrd_date, dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_BEGIN)) as daysrfpl 
								,row_number() over (partition by list4.ID_PRSN_CHILD_ 
													order by list4.ID_PRSN_CHILD_
																,datediff(dd, list4.rfrd_date, dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_BEGIN))) as childcount2
							into #pbcs1s2_list5
							from #pbcs1s2_list4 list4
								left join CA.REMOVAL_EPISODE_FACT ref
									on ref.ID_PRSN_CHILD = list4.ID_PRSN_CHILD_
								left join CA.REMOVAL_DIM red
									on ref.ID_REMOVAL_DIM = red.ID_REMOVAL_DIM 
								left join CA.DISCHARGE_REASON_DIM drd
									on ref.ID_DISCHARGE_REASON_DIM = drd.ID_DISCHARGE_REASON_DIM 
							where (datediff(dd, list4.rfrd_date, dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_BEGIN)) >= -5 
									and datediff(dd, list4.rfrd_date, dbo.IntDate_to_CalDate(ref.ID_CALENDAR_DIM_BEGIN))  <= 183)
							
							
							--unduplicate, selecting episode closest to referral
							if object_id('tempdb..#pbcs1s2_plcd_list') is not null 
								drop table #pbcs1s2_plcd_list
							select * 
							into #pbcs1s2_plcd_list
							from #pbcs1s2_list5 list5
							where list5.childcount2 = 1


							if object_id('tempdb..#pbcs1s2_work_9') is not null 
								drop table #pbcs1s2_work_9
							select work_8.ID_INTAKE_VICTIM_FACT
									,work_8.ID_ACCESS_REPORT
									,work_8.ID_INTAKE_FACT
									,work_8.ID_PRSN_CHILD
									,work_8.ACTUAL_RESPONSE_TIME
									,work_8.ATTEMPTED_RESPONSE_TIME
									,work_8.DT_IFF_COMPLETED
									,work_8.DT_IFF_ATTEMPTED
									,work_8.CD_ACTIVITY_LOCATION_IFF
									,work_8.ID_CALENDAR_DIM_VICTIM_ADDED
									,work_8.DT_VICTIM_ADDED
									,work_8.ID_INVS
									,work_8.ID_WORKER_DIM_INTAKE
									,work_8.ID_LOCATION_DIM_INTAKE_WORKER
									,work_8.ID_PRVD_ORG_INTAKE
									,work_8.ID_CASE
									,work_8.ID_INTAKE_ATTRIBUTE_DIM
									,work_8.ID_INVESTIGATION_ASSESSMENT_FACT
									,work_8.CD_INVS_TYPE
									,work_8.CD_GNDR
									,work_8.TX_GNDR
									,work_8.CD_HSPNC
									,work_8.TX_HSPNC
									,work_8.CD_INDN
									,work_8.TX_INDN
									,work_8.TX_MULTIRACE
									,work_8.RACE_OF_CHILD
									,work_8.census_hispanic_latino_origin_cd
									,work_8.DT_BIRTH
									,work_8.DT_DEATH
									,work_8.FL_SEX_AGGRESIVE_YOUTH
									,work_8.FL_TEEN_PARENT
									,work_8.intlic_flag
									,work_8.rfrd_date
									,work_8.incd_date
									,work_8.spvrdscn_date
									,work_8.MCFfind
									,work_8.finding
									,work_8.multcan
									,work_8.majcan
									,work_8.initref
									,work_8.initfndref
									,work_8.vicrecur_
									,work_8.daysfrfr_
									,work_8.persro3_
									,work_8.persro6_
									,work_8.persro9_
									,work_8.persro12_
									,work_8.persro15_
									,work_8.persro18_
									,work_8.persro21_
									,work_8.persro24_
									,work_8.persro27_
									,work_8.persro30_
									,work_8.persro33_
									,work_8.persro36_
									,work_8.persro39_
									,work_8.persro42_
									,work_8.persro45_
									,work_8.persro48_
									,work_8.vicrptref_
									,work_8.daysrcrc_
									,work_8.persrr3_
									,work_8.persrr6_
									,work_8.persrr9_
									,work_8.persrr12_
									,work_8.persrr15_
									,work_8.persrr18_
									,work_8.persrr21_
									,work_8.persrr24_
									,work_8.persrr27_
									,work_8.persrr30_
									,work_8.persrr33_
									,work_8.persrr36_
									,work_8.persrr39_
									,work_8.persrr42_
									,work_8.persrr45_
									,work_8.persrr48_
									,work_8.ageatref
									,work_8.ageatrefc
									,work_8.CD_SRVC
									,work_8.auth_begin
									,work_8.daysrfsv
									,work_8.FFSserv
									,work_8.IHFFSsrvc
									,work_8.IHmiscsrvc
									,work_8.BRStype
									,work_8.IHsrvcs
									,work_8.ID_ASGN
									,work_8.ID_WORKER_DIM
									,work_8.ID_LOCATION_DIM as ID_LOCATION_DIM_
									,work_8.asgn_begin
									,work_8.asgn_end
									,work_8.CD_ASGN_CTGRY
									,work_8.TX_ASGN_CTGRY
									,work_8.CD_ASGN_TYPE
									,work_8.TX_ASGN_TYPE
									,work_8.CD_ASGN_ROLE
									,work_8.TX_ASGN_ROLE
									,work_8.CD_ASGN_RSPNS
									,work_8.TX_ASGN_RSPNS
									,work_8.daysrefasgn
									,work_8.IHSasgn
									,list.ID_REMOVAL_EPISODE_FACT
									,list.ID_EPSD
									,list.ID_CALENDAR_DIM_AFCARS_END
									,list.ID_CALENDAR_DIM_BEGIN
									,list.ID_CALENDAR_DIM_END
									,list.ID_CALENDAR_DIM_FIRST_HEALTH_SAFETY_VISIT
									,list.ID_CASE_DIM
									,list.ID_DISCHARGE_REASON_DIM
									,list.ID_FAMILY_STRUCTURE_DIM
									,list.ID_LOCATION_DIM_REMOVAL
									,list.ID_LOCATION_DIM_WORKER
									,list.ID_PEOPLE_DIM_CHILD
									,list.ID_PEOPLE_DIM_PARENT_PRIMARY
									,list.ID_PEOPLE_DIM_PARENT_SECONDARY
									,list.ID_PLACEMENT_CARE_AUTH_DIM
									,list.ID_REMOVAL_DIM
									,list.ID_WORKER_DIM_CURRENT
									,list.ID_WORKER_DIM_ORIGINAL
									,list.FL_AAFC
									,list.FL_ABANDONMENT
									,list.FL_ABUSE
									,list.FL_CARETAKER_INABILITY_COPE
									,list.FL_CHILD_ABUSE_ALCOHOL
									,list.FL_CHILD_ABUSES_DRUG
									,list.FL_CHILD_BEHAVIOR_PROBLEMS
									,list.FL_CHILD_CLINICALLY_DIAGNOSED
									,list.FL_IN_ERROR
									,list.FL_INADEQUATE_HOUSNG
									,list.FL_NEGLECT
									,list.FL_PARENT_ABUSE_ALCOHOL
									,list.FL_PARENT_DEATH
									,list.FL_PARENT_DRUG_ABUSE
									,list.FL_PARENT_INCARCERATION
									,list.FL_PHYSICAL_ABUSE
									,list.FL_REENTRY
									,list.FL_RELINQUISHMENT
									,list.FL_SEX_ABUSE
									,list.CHILD_AGE_REMOVAL_BEGIN
									,list.CHILD_AGE_REMOVAL_END
									,list.LENGTH_OF_STAY
									,list.FL_TRIAL_RETURN_HOME
									,list.ID_PRSN_PARENT_PRIMARY
									,list.ID_PRSN_PARENT_SECONDARY
									,list.CD_RMVL_MNR
									,list.TX_RMVL_MNR
									,list.CD_DSCH_RSN
									,list.TX_DSCH_RSN
									,list.CD_PLCM_DSCH_RSN
									,list.TX_PLCM_DSCH_RSN
									,list.ep_begin
									,list.ep_end
									,list.afcars_ep_end
									,list.daysrfpl
									--compute placement status variable
									-- 0 'Not placed' 1 'Placed after referral' 
									-- 2 'Placed before referral'
									-- 3 'Placed within 30 days of referral, no repeat referral' 
									-- 4 'Placed > 30 days after referral, no repeat referral'							
									,(case
										when list.daysrfpl is null
										then 0
										when work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_
										then 1
										when work_8.vicrptref_ = 1 and list.daysrfpl <= work_8.daysrcrc_
										then 2
										when work_8.vicrptref_ = 0 and list.daysrfpl <= 30
										then 3
										when work_8.vicrptref_ = 0 and list.daysrfpl > 30
										then 4
									end) as plcstat 
									-- Placed (before or without repeat referral)? 0 'No' 1 'Yes' 
									,(case 
										when list.daysrfpl is null 
											or 
											(work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_)
										then 0
										else 1
									end) as plcstatc 
									-- plclos 'LOS, post-referral placement'
									,datediff(dd, list.ep_begin, list.ep_end) as plclos
									--compute days between referrals, adjusted for days in placement
									,(case 
										when vicrptref_ = 1 
											and 
											(case 
												when list.daysrfpl is null 
													or 
													(work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_)
												then 0
												else 1 
											end) = 1
										then (work_8.daysrcrc_ - datediff(dd, list.ep_begin, list.ep_end))
										when (datediff(dd, list.ep_begin, list.ep_end) is null
											and not ((case 
															when list.daysrfpl is null 
																or 
																(work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_)
															then 0
															else 1 
														end) = 1))
										then work_8.daysrcrc_
									end) as daysrcrc_plcadj
									--'Days between founded referrals, LOS subtracted'
									,(case 
										when vicrptref_ = 1 
											and 
											(case 
												when list.daysrfpl is null 
													or 
													(work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_)
												then 0
												else 1
											end) = 1
										then (work_8.daysfrfr_ - datediff(dd, list.ep_begin, list.ep_end))
										when (datediff(dd, list.ep_begin, list.ep_end) is null 
											and not (vicrptref_ = 1 
														and 
														(case 
															when list.daysrfpl is null 
																or 
																(work_8.vicrptref_ = 1 and list.daysrfpl > work_8.daysrcrc_)
															then 0
															else 1
														end) = 1))
										then work_8.daysfrfr_
									end) as daysfrfr_plcadj 
							into #pbcs1s2_work_9
							from #pbcs1s2_work_8 work_8
								left join #pbcs1s2_plcd_list list on 
									 work_8.ID_PRSN_CHILD = list.ID_PRSN_CHILD
							order by work_8.id_prsn_child

							-- add region, office from look-up table, using location of assigned worker
							-- if worker assignment is missing, use location of intake worker
							alter table #pbcs1s2_work_9 
							add ID_LOCATION_DIM2  
							as  cast(case
										when ID_LOCATION_DIM_ is null
										then ID_LOCATION_DIM_INTAKE_WORKER 
										else ID_LOCATION_DIM_
									end as int)



							if object_id('tempdb..#PBC_S1_S2_RepeatReferral') is not null 
								drop table #PBC_S1_S2_RepeatReferral
														
							select * 
								,(case
									when IHSasgn = 0 and plcstatc = 0
									then 1
									else 0
								end) as S1mark
								,(case
									when IHSasgn = 1 or plcstatc = 1
									then 1
									else 0
								end) as S2mark
							into #PBC_S1_S2_RepeatReferral
							from #pbcs1s2_work_9 work_9
								left join CA.LOCATION_DIM lod
									on lod.ID_LOCATION_DIM = work_9.ID_LOCATION_DIM2
							order by ID_PRSN_CHILD, rfrd_date

				--   select * from  #PBC_S1_S2_RepeatReferral where not (CD_INVS_TYPE in (1,2) AND initref = 1 ) AND S1mark = 1
				--   select * from #PBC_S1_S2_RepeatReferral where NOT(CD_INVS_TYPE in (1,2) AND initref = 1) and s2mark=1


					--	insert into PRTL_PBCS1S2 
						select @chstart as Inv_Open_Cohort_Begin_Date
							--,@chend as Inv_Open_Cohort_End_Date
							,@date_type
							,age.age_grouping_cd
							,coalesce(gdr.PK_GNDR,3) as pk_gndr
							,RR.RACE_OF_CHILD as cd_race
							,RR.census_hispanic_latino_origin_cd
							,coalesce(xwlk_wrk.cd_office_collapse,-99) as cd_office_collapse
							,coalesce(xwlk_wrk.CD_REGION_COLL,-99)  as cd_region_collapse
							,RR.S1mark as S1mark
							,RR.S2mark as S2mark
							,RR.CD_INVS_TYPE
							,RR.initref
							,RR.initfndref
							,case when 3 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then  sum(RR.persrr3_) else null end as M3
							,case when 6 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr6_) else null end as M6
							,case when 9 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr9_) else null end as M9
							,case when 12 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr12_) else null end as M12
							,case when 15 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr15_) else null end as M15
							,case when 18 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr18_) else null end as M18
							,case when 21 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr21_) else null end as M21										
							,case when 24 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr24_) else null end as M24
							,case when 27 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr27_) else null end as M27			
							,case when 30 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr30_) else null end as M30
							,case when 33 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr33_) else null end as M33
							,case when 36 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr36_) else null end as M36
							,case when 39 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr39_) else null end as M39
							,case when 42 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr42_) else null end as M42
							,case when 45 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr45_) else null end as M45
							,case when 48 <= datediff(mm,eomonth(dateadd(mm,2,@chstart)),@cutoff_date)  then sum(RR.persrr48_) else null end as M48
							,count(*) as cnt
						--into  PRTL_PBCS1S2 
						from #PBC_S1_S2_RepeatReferral RR
						left join  (
								select distinct xwlk.cd_office,xwlk.cd_office_collapse,cd_region as CD_REGION_COLL
								from dbo.ref_xwalk_CD_OFFICE_DCFS xwlk
								where CD_OFFICE is not null 
								--order by cd_office_collapse
								) xwlk_wrk on xwlk_wrk.cd_office= RR.CD_OFFICE
						 left join ref_lookup_gender gdr on gdr.CD_GNDR=rr.CD_GNDR and pk_gndr>0
						left join ref_age_groupings  age on rr.ageatref >=age.Age_Begin and rr.ageatref < Age_LessThan_End
							and age.age_grouping_cd between @age_grouping_start and @age_grouping_stop
						where age.age_grouping_cd is not null
						and (S1mark=1 or S2mark=1)
						and RR.CD_INVS_TYPE in (1,2)
						  group by age.age_grouping_cd
							,coalesce(gdr.PK_GNDR,3)
							,RR.RACE_OF_CHILD
							,RR.census_hispanic_latino_origin_cd
							,coalesce(xwlk_wrk.cd_office_collapse,-99) 
							,coalesce(xwlk_wrk.CD_REGION_COLL,-99)
							,RR.S1mark 
							,RR.S2mark 
							,RR.CD_INVS_TYPE
							,RR.initref
							,RR.initfndref
						if @date_type=1 
							begin		  
								set @chstart=dateadd(mm,3,@chstart)
								set @chend=dateadd(mm,3,@chstart)
							end
						else
							begin
								set @chstart=dateadd(yy,1,@chstart)
								set @chend=dateadd(yy,1,@chstart)
							end
				  end
				  set @date_type=@date_type + 1
				  set @chstart=  '2004-01-01 00:00:00.000'
				  set @chend=dateadd(yy,1,@chstart)
				  set @stopDate= (select max([Year]) from CA.calendar_dim where [Year] < @cutoff_date);
		end
--end		  
--else
--begin
--	select 'Need permission key to execute BUILDS COHORTS!' as [Warning]
--end
		  
		  


