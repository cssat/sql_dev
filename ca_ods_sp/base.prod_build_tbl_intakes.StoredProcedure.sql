USE [CA_ODS]
GO
/****** Object:  StoredProcedure [base].[prod_build_tbl_intakes]    Script Date: 4/1/2014 5:02:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [base].[prod_build_tbl_intakes](@permission_key datetime)
as 

if @permission_key=(select cutoff_date from ref_last_DW_transfer)
begin	
			declare @startDate datetime
			declare @endDate datetime

			declare @chstart datetime
			declare @chend datetime
			declare @cutoff_date datetime

			set @startDate= '01/01/1997'  
			set @cutoff_date=(select cutoff_date from ref_last_dw_transfer)
			set  @endDate=@cutoff_date
			set @chstart=@startDate;


		
			set @chstart = @startDate 

			set @chend = (select cutoff_date from ref_last_dw_transfer)

			set nocount on

			if object_id('tempdb..##referrals') is not null drop table  ##referrals;
		--	if object_id(N'U',N'##referrals') is not null drop table ##referrals;
			-- select distinct cases during the time frame and get closest investigative/assessment assignment id
			
			
			-- get the investigation ID's where they are populated in allegation_fact
			with cte_allg  ( id_intake_fact, id_case, id_investigation_assessment_fact,cd_invs_type,tx_invs_type, cd_invs_disp,tx_invs_disp,rfrd_date ,invs_level2_approved) --,row_num)
			as (select distinct 
			                  af.id_intake_fact
							, intk.id_case
							, af.id_investigation_assessment_fact 
							, cd_invs_type
							, tx_invs_type
							, dd.cd_invs_disp
							, dd.tx_invs_disp
							, dbo.IntDate_to_CalDate(intk.id_calendar_dim_access_rcvd) 
							, dbo.IntDate_to_CalDate(iaf.ID_CALENDAR_DIM_LEVEL2_APPROVED)
							--, row_number() over (partition by intk.id_intake_fact order by  dbo.IntDate_to_CalDate(intk.id_calendar_dim_access_rcvd)  asc ,dbo.IntDate_to_CalDate(iaf.ID_CALENDAR_DIM_LEVEL2_APPROVED) asc)
				from dbo.intake_fact intk 
				join dbo.allegation_fact  af on af.id_intake_fact=intk.id_intake_fact
				join dbo.investigation_assessment_fact iaf on iaf.id_investigation_assessment_fact=af.id_investigation_assessment_fact
				join dbo.investigation_type_dim itd on itd.id_investigation_type_dim=iaf.id_investigation_type_dim
				join dbo.disposition_dim dd on iaf.id_disposition_dim=dd.id_disposition_dim
				where af.id_intake_fact is not null and af.id_investigation_assessment_fact is not null) 
		
			
			select   
				 inf.id_intake_fact
				, inf.id_case
				, alg.id_investigation_assessment_fact as id_investigation_assessment_fact -- q.ID_INVESTIGATION_ASSESSMENT_FACT
				, saf.id_safety_assessment_fact as id_safety_assessment_fact
				, inf.dt_access_rcvd as rfrd_date
				, dbo.IntDate_to_CalDate(inf.id_calendar_dim_access_rcvd) as inv_ass_start
				, case when itd.cd_final_decision <> 1 then dbo.IntDate_to_CalDate(inf.id_calendar_dim_spvr_dscn) 
						when itd.cd_final_decision=1 and alg.invs_level2_approved >= dbo.IntDate_to_CalDate(inf.id_calendar_dim_access_rcvd) then alg.invs_level2_approved
					else null end as inv_ass_stop
				, dbo.IntDate_to_CalDate(inf.id_calendar_dim_spvr_dscn)  as screen_in_spvr_dcsn_dt
				, saf.invs_start_date as invs_start_date
				, saf.invs_end_date as invs_end_date
				, alg.invs_level2_approved as invs_level2_approved  --  q.ID_CALENDAR_DIM_LEVEL2_APPROVED
				, itd.cd_access_type
				, itd.tx_access_type
				, alg.cd_invs_type cd_invs_type -- q.CD_INVS_TYPE
				, cast(alg.tx_invs_type as char(200)) as tx_invs_type -- q.TX_INVS_TYPE
				, alg.cd_invs_disp
				, cast(alg.tx_invs_disp  as char(200)) as tx_invs_disp
				, cast(null as int) as close_id_assgn_fact --  q.ID_ASSIGNMENT_FACT
				, cast(null as datetime) as close_assgn_begin_dt -- q.close_assgn_begin_dt
				, cast(null as datetime) as close_assgn_end_dt -- q.close_assgn_begin_dt
				, cast(null as int) as close_assgn_cd_rmts_wrkr_type
				, cast(null as varchar(200)) as close_assgn_tx_rmts_wrkr_type
				, iad.cd_spvr_rsn
				, iad.tx_spvr_rsn
				, itd.cd_final_decision
				, itd.tx_final_decision
				, cast(null as int) as cd_asgn_type 
				, cast(null as varchar(200)) as tx_asgn_type
				, cast(null as int) as cd_asgn_rspns
				, cast(null as varchar(200)) as tx_asgn_rspns
				, iad.cd_rptr_dscr as cd_reporter
				, iad.tx_rptr_dscr as tx_reporter
				, cast(null as int) as id_people_dim_hh
				, cast(null as int) as id_prsn_hh
				, cast(null as int) as pk_gndr
				, cast(null as datetime) as dt_birth
				, cast(null as int) as is_current
				, cast(null as int) as cd_race_census
				, cast(null as int) as census_hispanic_latino_origin_cd
				, cast(null as int) as cd_sib_age_grp
				, isnull(isnull(ldcps.cd_office, ldwrk.cd_office),saf.cd_office) as cd_office
				, isnull(isnull(ldcps.tx_office, ldwrk.tx_office),saf.tx_office)  as tx_office
				, cast(null as int) as cd_region
				, cast(0 as int) as fl_ihs_90_day
				, cast(0 as int) as fl_phys_abuse
				, cast(0 as int) as fl_sexual_abuse
				, cast(0 as int) as fl_neglect
				, cast(0 as int) as fl_other_maltreatment
				, cast(0 as int) as fl_allegation_any
				, cast(0 as int) as fl_founded_phys_abuse
				, cast(0 as int) as fl_founded_sexual_abuse
				, cast(0 as int) as fl_founded_neglect
				, cast(0 as int) as fl_founded_other_maltreatment
				, cast(0 as int) as fl_founded_any_legal
				, cast(0 as int) as fl_prior_phys_abuse
				, cast(0 as int) as fl_prior_sexual_abuse
				, cast(0 as int) as fl_prior_neglect
				, cast(0 as int) as fl_prior_other_maltreatment
				, cast(0 as int) as fl_prior_allegation_any
				, cast(0 as int) as fl_founded_prior_phys_abuse
				, cast(0 as int) as fl_founded_prior_sexual_abuse
				, cast(0 as int) as fl_founded_prior_negelect
				, cast(0 as int) as fl_founded_prior_other_maltreatment
				, cast(0 as int) as fl_founded_prior_any_legal
				, cast(0 as int) as fl_hh_is_mother 
				, case when itd.cd_access_type in (1,4)  
							and (iad.tx_spvr_rsn is null 
									or iad.tx_spvr_rsn not in ('CPS-Risk Only','CPS-FAR','DLR/CPS-Investigation','DLR/CPS-Risk Only','*INVALID*','Child Family Welfare Services','Risk Only' , 'Alternate Intervention' ,'Family Reconciliation Services','Re-Open Closed Case'  )
								)
							and itd.cd_final_decision = 1  -- screened in (accepted) 
						then 1 else 0 end as fl_cps_invs
				, case when iad.tx_spvr_rsn='Child Family Welfare Services'  then 1 else 0 end as fl_cfws
				, case when iad.tx_spvr_rsn='Risk Only'  then 1 else 0 end as fl_risk_only
				, case when iad.tx_spvr_rsn='Alternate Intervention'  then 1 else 0 end as fl_alternate_intervention
				, case when iad.tx_spvr_rsn='Family Reconciliation Services'  then 1 else 0 end as fl_frs
				, case when iad.tx_spvr_rsn='Re-Open Closed Case' then 1 else 0 end as fl_reopen_case
				, case when alg.cd_invs_type=3 then 1 else 0 end as fl_dlr
				, cast(0 as int) as cnt_children_at_intake
				, cast(null as datetime) as first_intake_date
				, cast(null as datetime) as latest_intake_date
				, cast(0 as int) as  nbr_intakes
				, cast(0 as int) as nbr_cps_intakes
				, cast(0 as int) as intake_rank
				, cast(-99 as int) as fl_ooh_prior_this_referral
			--	, cast(null as datetime) as ooh_date_immediately_prior_this_referral
				, cast(-99 as int) as fl_ooh_after_this_referral
			--	, cast(null as datetime) as ooh_date_immediately_after_this_referral
		into  ##referrals
		from dbo.intake_fact inf
		left join dbo.intake_type_dim itd
					on itd.id_intake_type_dim = inf.id_intake_type_dim
		left join dbo.intake_attribute_dim iad on iad.id_intake_attribute_dim=inf.id_intake_attribute_dim
					--and iad.CD_SPVR_RSN in (1,2,3,6)
					--and  iad.TX_SPVR_RSN in ('Child Family Welfare Services' --CD_SPVR_RSN 1
					--								,'Risk Only' --CD_SPVR_RSN 1
					--								,'Alternate Intervention'--CD_SPVR_RSN 2
					--								,'Family Reconciliation Services'  --CD_SPVR_RSN 3
					--								) 
		left join dbo.worker_dim wdcps on wdcps.id_worker_dim=inf.id_worker_dim_cps_supervisor
		left join dbo.location_dim ldcps on ldcps.id_location_dim=wdcps.id_location_dim_worker
				and ldcps.cd_office not in (-99,700, 989) -- exclude CENTRAL INTAKE offices
		left join dbo.worker_dim wdwrk on wdwrk.id_worker_dim=inf.id_worker_dim_intake
		left join dbo.location_dim ldwrk on ldwrk.id_location_dim=wdwrk.id_location_dim_worker
				and ldwrk.cd_office not in (-99,700, 989) -- exclude CENTRAL INTAKE offices
		left join  ( -- safety assessment worker office
					select    saf.id_intake_fact
							, ld.cd_office,ld.tx_office
							, saf.id_safety_assessment_fact
							, dbo.IntDate_to_CalDate(saf.id_calendar_dim_investigation_begin) as invs_start_date
							, dbo.IntDate_to_CalDate(saf.id_calendar_dim_investigation_end) as invs_end_date
							, row_number() over (partition by saf.id_intake_fact order by saf.id_intake_fact,ld.cd_office asc) as row_num
					from dbo.intake_fact ink
					join dbo.safety_assessment_fact saf on ink.id_intake_fact=saf.id_intake_fact
					join dbo.worker_dim wd on wd.id_worker_dim=saf.id_worker_dim
					join dbo.location_dim ld on ld.id_location_dim=wd.id_location_dim_worker
						and ld.cd_office  not in (-99,700, 989) -- exclude CENTRAL INTAKE offices
					) saf on saf.id_intake_fact=inf.id_intake_fact and saf.row_num = 1
		left join cte_allg alg on alg.id_intake_fact=inf.id_intake_fact
						
		where dbo.IntDate_to_CalDate(inf.id_calendar_dim_access_rcvd)
				between @chstart AND @chend
				and inf.id_case > 0
			
		
			

			CREATE NONCLUSTERED INDEX idx_ID_INTAKE_FACT ON  ##referrals (id_intake_fact)
			CREATE NONCLUSTERED INDEX idx_intk_temp_office ON  ##referrals (cd_office) INCLUDE (id_intake_fact)
			CREATE NONCLUSTERED INDEX idx_tmp_intk_is_current ON   ##referrals ([IS_CURRENT]) INCLUDE ([ID_PRSN_HH],[pk_gndr],[DT_BIRTH],[cd_race_census],[census_hispanic_latino_origin_cd])
			CREATE NONCLUSTERED INDEX idx_intk_tmp_cd_office_close_assgn ON  ##referrals ([CD_OFFICE]) INCLUDE (close_id_assgn_fact)
			CREATE NONCLUSTERED INDEX  idx_tmp_intk_asgnType_access ON  ##referrals ([CD_ASGN_TYPE],[CD_ACCESS_TYPE])
			CREATE NONCLUSTERED INDEX idx_tmp_intakes ON  ##referrals ([CD_ACCESS_TYPE],close_id_assgn_fact)	INCLUDE ([ID_INTAKE_FACT],[rfrd_date],[ID_CASE],[ID_INVESTIGATION_ASSESSMENT_FACT],invs_level2_approved,[CD_INVS_TYPE],[TX_INVS_TYPE],[TX_ACCESS_TYPE],[close_assgn_begin_dt],[CD_SPVR_RSN],[TX_SPVR_RSN],[CD_ASGN_TYPE],[CD_ASGN_RSPNS],close_assgn_cd_rmts_wrkr_type,close_assgn_tx_rmts_wrkr_type  ,[ID_PRSN_HH],[PK_GNDR],[DT_BIRTH],[IS_CURRENT],[cd_race_census],[census_hispanic_latino_origin_cd],[cd_sib_age_grp])
			CREATE NONCLUSTERED INDEX  idx_tmp_intk_cd_invs_type ON  ##referrals ([CD_INVS_TYPE])
			CREATE NONCLUSTERED INDEX idx_tmp_intk_fl_cps_invs_inc_cd_asgn_rspns ON  ##referrals ([fl_cps_invs])INCLUDE ([cd_asgn_type],[cd_asgn_rspns])
			CREATE NONCLUSTERED INDEX idx_tmp_intk_id_prsn ON  ##referrals ([ID_PRSN_HH])
			

			update statistics  ##referrals
		
			-- get the first assignment worker closest to intake that is designated investigation or in-home services meeting criteria below
			-- left join  to allegation fact (only 56% have intakes) on id_intake and then join the investigation table
			
			
			--getting closest CPS assignment to the referral date
			begin tran tran3;

		-- in-home service assignments
		with cte_ihs_assgn (id_case,id_intake_fact,id_assignment_fact,asgn_begin,cd_asgn_ctgry,cd_asgn_type,cd_asgn_rspns,days_to_ihs_asgn,row_num)
		as (
		select asf.id_case,intk.id_intake_fact,asf.ID_ASSIGNMENT_FACT
						,dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN) as asgn_begin
						,aad.CD_ASGN_CTGRY
						,aad.CD_ASGN_TYPE
						,aad.CD_ASGN_RSPNS 
						,datediff(dd,convert(varchar(10),rfrd_date,121),dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN)) days_to_ihs_asgn
						,row_number() over (partition by intk.id_intake_fact order by datediff(dd,rfrd_date,dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN)) asc) as row_num
					from dbo.ASSIGNMENT_FACT asf  
					join base.tbl_intakes intk on intk.id_case=asf.id_case 
					join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad 
						on aad.ID_ASSIGNMENT_ATTRIBUTE_DIM = asf.ID_ASSIGNMENT_ATTRIBUTE_DIM
					where aad.CD_ASGN_CTGRY = 1 AND aad.CD_ASGN_RSPNS = 7 
						AND aad.CD_ASGN_TYPE in (4,5,8,9) 
						and cd_asgn_role not in (3,4) 
						and datediff(dd,convert(varchar(10),rfrd_date,121),dbo.IntDate_to_CalDate(asf.ID_CALENDAR_DIM_BEGIN))  between -5 and 183)

			update inf
			set  
				  close_id_assgn_fact= q.close_id_assgn
				, close_assgn_begin_dt =q.close_assgn_begin_dt
				, close_assgn_end_dt =q.close_assgn_end_dt
				, close_assgn_cd_rmts_wrkr_type=q.close_assgn_cd_rmts_wrkr_type
				, close_assgn_tx_rmts_wrkr_type=q.close_assgn_tx_rmts_wrkr_type
				, cd_asgn_type=q.CD_ASGN_TYPE
				, tx_asgn_type=q.tx_asgn_type
				, cd_asgn_rspns=q.cd_asgn_rspns
				, tx_asgn_rspns=q.tx_asgn_rspns
				, cd_office=case when inf.cd_office is null then q.cd_office else inf.cd_office end
				, tx_office=case when inf.tx_office is null then q.tx_office else inf.tx_office end
				, fl_ihs_90_day=case when cte_ihs_assgn.id_intake_fact is not null and days_to_ihs_asgn between 0 and 90 then 1 else 0 end 
				from  ##referrals inf
			join 
					(	select intk.ID_INTAKE_FACT
							, asf.id_assignment_fact as close_id_assgn
							, iaf.ID_INVESTIGATION_ASSESSMENT_FACT
							, intk.invs_level2_approved
							, aad.cd_asgn_ctgry
							, aad.tx_asgn_ctgry
							, aad.cd_asgn_type
							, aad.tx_asgn_type
							, aad.cd_asgn_role
							, aad.CD_ASGN_RSPNS
							, aad.tx_asgn_rspns
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  as close_assgn_begin_dt
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_end) as close_assgn_end_dt
							, wd.CD_JOB_CLS as asgn_CD_JOB_CLS
							, wd.tx_job_cls as asgn_tx_job_cls
							, wd2.CD_JOB_CLS as invs_CD_JOB_CLS
							, wd2.tx_job_cls as invs_tx_job_cls
							, ld.CD_OFFICE
							, ld.TX_OFFICE
							, wd.cd_rmts_wrkr_typ as   close_assgn_cd_rmts_wrkr_type
							, wd.tx_rmts_wrkr_typ as   close_assgn_tx_rmts_wrkr_type
							, ROW_NUMBER() over (partition by intk.id_intake_fact
													order by intk.id_intake_fact
														,dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  asc
														,isnull(dbo.IntDate_to_CalDate(asf.id_calendar_dim_end),'12/31/3999')  asc
														,isnull(intk.invs_level2_approved ,'12/31/3999') asc
												) as row_num
						from  ##referrals intk
						-- assignment date greater than equal to referral date
							join dbo.ASSIGNMENT_FACT asf on asf.ID_CASE=intk.ID_CASE
								and dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin) 
									>=	intk.inv_ass_start
							join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad 
									on aad.ID_ASSIGNMENT_ATTRIBUTE_DIM = asf.ID_ASSIGNMENT_ATTRIBUTE_DIM
							--left join dbo.ALLEGATION_FACT alf
							--		on alf.ID_INTAKE_FACT = intk.ID_INTAKE_FACT
							-- 56% null values on allegation_fact.ID_INVESTIGATION_ASSESSMENT_FACT from query below
							 -- select * from ca_ods.dbo.ca_null_analysis where tblname='allegation_fact' and colname='ID_INVESTIGATION_ASSESSMENT_FACT' and load_date >= (select cast(convert(varchar(10),max([date_received]),121) as datetime) from ca_ods.dbo.[CA_DATA_RECEIVED])
							left join dbo.INVESTIGATION_ASSESSMENT_FACT iaf  
									on iaf.ID_INVESTIGATION_ASSESSMENT_FACT = intk.id_investigation_assessment_fact
							--left join dbo.INVESTIGATION_TYPE_DIM ind
							--		on ind.ID_INVESTIGATION_TYPE_DIM = iaf.ID_INVESTIGATION_TYPE_DIM
							left join dbo.worker_dim wd 
								on wd.id_worker_dim=asf.id_worker_dim 
							left join dbo.worker_dim wd2
								on wd2.id_worker_dim=iaf.id_worker_dim 
							left join dbo.LOCATION_DIM ld on ld.ID_LOCATION_DIM=wd.ID_LOCATION_DIM_WORKER
									and ld.CD_OFFICE  not in (-99,700, 989)
							--left join dbo.LOCATION_DIM ld2 on ld.ID_LOCATION_DIM=wd2.ID_LOCATION_DIM_WORKER
							--		and ld2.CD_OFFICE  not in (-99,700, 989)
						where datediff(dd,inv_ass_start,dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin) ) <=365
							and	((intk.CD_ACCESS_TYPE in (1,4) -- CPS, CPS RISK ONLY
								and aad.CD_ASGN_TYPE in (4,8)	-- select CPS, non_CPS (FRS)
								and  aad.CD_ASGN_RSPNS in (9,7) -- Investigation,In Home Services
								)
								OR
								( intk.CD_ACCESS_TYPE=2 -- non-cps FRS,OTHER
							
								))
								
			) q on q.ID_INTAKE_FACT=inf.ID_INTAKE_FACT
				and q.row_num=1
			left join cte_ihs_assgn on cte_ihs_assgn.row_num=1
			and cte_ihs_assgn.id_intake_fact=inf.ID_INTAKE_FACT
			commit tran tran3;
			update statistics  ##referrals;



			-- We are not limiting to CPS this time (certain cd_access_type, cd_asgn_type or cd_asgn_rspsns here).  
			begin tran tran4;
			update inf
			set  
				  close_id_assgn_fact= q.close_id_assgn
				, close_assgn_begin_dt =q.close_assgn_begin_dt
				, close_assgn_end_dt =q.close_assgn_end_dt
				, close_assgn_cd_rmts_wrkr_type=q.close_assgn_cd_rmts_wrkr_type
				, close_assgn_tx_rmts_wrkr_type=q.close_assgn_tx_rmts_wrkr_type
				, cd_asgn_type=q.CD_ASGN_TYPE
				, tx_asgn_type=q.tx_asgn_type
				, cd_asgn_rspns=q.cd_asgn_rspns
				, tx_asgn_rspns=q.tx_asgn_rspns
				, cd_office=case when inf.cd_office is null then q.cd_office else inf.cd_office end
				, tx_office=case when inf.tx_office is null then q.tx_office else inf.tx_office end
				from  ##referrals inf
			join 
					(	select intk.ID_INTAKE_FACT
							, asf.id_assignment_fact as close_id_assgn
							, iaf.ID_CALENDAR_DIM_LEVEL2_APPROVED
							, aad.CD_ASGN_TYPE
							, aad.tx_asgn_type
							, aad.cd_asgn_ctgry
							, aad.cd_asgn_role
							, aad.CD_ASGN_RSPNS
							, aad.tx_asgn_rspns
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  as close_assgn_begin_dt
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_end) as close_assgn_end_dt
							, wd.CD_JOB_CLS as asgn_CD_JOB_CLS
							, wd.tx_job_cls as asgn_tx_job_cls
							, wd2.CD_JOB_CLS as invs_CD_JOB_CLS
							, wd2.tx_job_cls as invs_tx_job_cls
							, ld.CD_OFFICE
							, ld.TX_OFFICE
							, wd.cd_rmts_wrkr_typ as   close_assgn_cd_rmts_wrkr_type
							, wd.tx_rmts_wrkr_typ as   close_assgn_tx_rmts_wrkr_type
							, ROW_NUMBER() over (partition by intk.id_intake_fact
													order by intk.id_intake_fact
														,dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  asc
														,isnull(dbo.IntDate_to_CalDate(asf.id_calendar_dim_end),'12/31/3999')  asc
														,isnull(intk.invs_level2_approved ,'12/31/3999') asc
												) as row_num
						from  ##referrals intk
							join dbo.ASSIGNMENT_FACT asf on asf.ID_CASE=intk.ID_CASE
								and dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin) 
									>=	intk.inv_ass_start
							join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad 
									on aad.ID_ASSIGNMENT_ATTRIBUTE_DIM = asf.ID_ASSIGNMENT_ATTRIBUTE_DIM
							--left join dbo.ALLEGATION_FACT alf
							--		on alf.ID_INTAKE_FACT = intk.ID_INTAKE_FACT
							left join dbo.INVESTIGATION_ASSESSMENT_FACT iaf  --56% null values on allegation_fact.ID_INVESTIGATION_ASSESSMENT_FACT
									on iaf.ID_INVESTIGATION_ASSESSMENT_FACT = intk.ID_INVESTIGATION_ASSESSMENT_FACT
							left join dbo.INVESTIGATION_TYPE_DIM ind
									on ind.ID_INVESTIGATION_TYPE_DIM = iaf.ID_INVESTIGATION_TYPE_DIM
							left join dbo.worker_dim wd 
								on wd.id_worker_dim=asf.id_worker_dim 
							left join dbo.worker_dim wd2
								on wd2.id_worker_dim=iaf.id_worker_dim 
							left join dbo.LOCATION_DIM ld on ld.ID_LOCATION_DIM=wd.ID_LOCATION_DIM_WORKER
									and ld.CD_OFFICE  not in (-99,700, 989)
						where intk.close_id_assgn_fact is null 
			) q on q.ID_INTAKE_FACT=inf.ID_INTAKE_FACT
				and q.row_num=1
			where inf.close_id_assgn_fact is null
			commit tran tran4;

			-- this time we want the closest assignment where the office is NOT central location
			begin tran tran14;
			update inf
			set cd_office=q.cd_office 
				, tx_office=q.tx_office
			from  ##referrals inf
			join 
					(	select intk.ID_INTAKE_FACT
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  as close_assgn_begin_dt
							, dbo.IntDate_to_CalDate(asf.id_calendar_dim_end) as close_assgn_end_dt
							, intk.invs_level2_approved
							, ld.CD_OFFICE
							, ld.TX_OFFICE
							, ROW_NUMBER() over (partition by intk.id_intake_fact
													order by intk.id_intake_fact
														,dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin)  asc
														,isnull(dbo.IntDate_to_CalDate(asf.id_calendar_dim_end),'12/31/3999')  asc
														,isnull(intk.invs_level2_approved ,'12/31/3999') asc
												) as row_num
						from  ##referrals intk
							join dbo.ASSIGNMENT_FACT asf on asf.ID_CASE=intk.ID_CASE
								and dbo.IntDate_to_CalDate(asf.id_calendar_dim_begin) 
									>=	intk.inv_ass_start
							join dbo.ASSIGNMENT_ATTRIBUTE_DIM aad 
									on aad.ID_ASSIGNMENT_ATTRIBUTE_DIM = asf.ID_ASSIGNMENT_ATTRIBUTE_DIM
							join dbo.worker_dim wd 
								on wd.id_worker_dim=asf.id_worker_dim 
							join dbo.LOCATION_DIM ld on ld.ID_LOCATION_DIM=wd.ID_LOCATION_DIM_WORKER
									
						where (intk.cd_office is null or intk.cd_office = -99)
							and ld.CD_OFFICE  not in (-99,700, 989)
							and (
								(intk.CD_ACCESS_TYPE in (1,4) -- CPS, CPS RISK ONLY
								and aad.CD_ASGN_TYPE in (4,8)	-- select CPS, non_CPS (FRS)
								and  aad.CD_ASGN_RSPNS in (9,7) -- Investigation,In Home Services
								)
								OR
								( intk.CD_ACCESS_TYPE=2 -- non-cps FRS,OTHER
																	)
								)
			) q on q.ID_INTAKE_FACT=inf.ID_INTAKE_FACT
				and q.row_num=1
			where inf.cd_office=-99 or inf.cd_office is null
			commit tran tran14;



			
			
			
			
			
			update  ##referrals
			set cd_office=-99
			,tx_office='-'
			where cd_office is null



			update statistics  ##referrals;
			
				
			
		
				begin tran t6
				update intk
				set inv_ass_stop= case when close_assgn_end_dt is not null and datediff(dd,inv_ass_start,close_assgn_end_dt) <=90
									and close_assgn_end_dt >= inv_ass_start
									then close_assgn_end_dt
								   else
										null end
				from  ##referrals intk
				where cd_final_decision=1 and inv_ass_stop is null
				and (CD_ACCESS_TYPE= 2 or (CD_ACCESS_TYPE in (1,4) 
						and datediff(dd,inv_ass_start,@cutoff_date) >= 183))
				commit  tran t6


			
			-- if case closed prior to 90 days after start date then use date case closed otherwise add 90 days to investigation assessment start date
			begin tran t7			
			update intk
			set inv_ass_stop=case when coalesce(dt_case_cls,'12/31/3999') < dateadd(dd,90,inv_ass_start) then dt_case_cls else dateadd(dd,90,inv_ass_start) end
			from  ##referrals intk
			left join base.tbl_case_dim cd on cd.id_case=intk.id_case
				and inv_ass_start <= dt_case_opn
				and coalesce(dt_case_cls,'12/31/3999') > inv_ass_start
			where inv_ass_stop is   null 
			and (CD_ACCESS_TYPE= 2 or (CD_ACCESS_TYPE in (1,4) and datediff(dd,inv_ass_start,@cutoff_date) >= 183))
			and (invs_level2_approved  is    null or invs_level2_approved < inv_ass_start)
			and cd_final_decision=1
			and dateadd(dd,90,inv_ass_start) < @cutoff_date
			commit tran t7	



			update statistics  ##referrals;

			begin tran t8

			update  ##referrals
			set fl_cps_invs=0
			 where fl_cps_invs=1 and NOT (CD_ASGN_TYPE in (4,8)	-- select CPS, non_CPS (FRS)
								and  CD_ASGN_RSPNS in (9,7))


			update  ##referrals
			set fl_cps_invs=0
			where (cd_access_type in (1,4) and cd_asgn_type is null	) 

			update  ##referrals
			set fl_dlr=1 , fl_cps_invs=0, fl_risk_only=0,fl_cfws=0,fl_frs=0,fl_alternate_intervention=0
			where cd_invs_type=3 or cd_asgn_type=6

			


	
			update  ##referrals
			set tx_access_type=tx_access_type + case tx_spvr_rsn 
				when 'Child Family Welfare Services' 
					then ' CFWS' 
				when 'Family Reconciliation Services' 
					then ' FRS' else '' end
			where cd_access_type=2;

		commit tran t8	
		begin tran t9
        delete from ##referrals where tx_spvr_rsn='Referral created in Error'
		commit tran t9
--------------------------------------------------------------------------------------------------------------------------------------------PART 2 HEAD OF HOUSEHOLD
	-- FIRST FIND PARENT MOTHER FIRST FROM ALLEGATION_FACT/ RELATIONSHIP_DIM
		begin tran t10
			update intk
			set 	ID_PEOPLE_DIM_HH=pd.id_people_dim
				,ID_PRSN_HH=pd.ID_PRSN
				,pk_gndr=case when pd.CD_GNDR = 'F' then 1 when pd.CD_GNDR='M' then 2 else 3 end
				,DT_BIRTH=pd.DT_BIRTH
				,IS_CURRENT=pd.IS_CURRENT
				,cd_race_census=pd.cd_race_census
				,census_hispanic_latino_origin_cd=pd.census_hispanic_latino_origin_cd 
				,fl_hh_is_mother=1
			from  ##referrals intk
			join dbo.ALLEGATION_FACT alf on alf.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
			join dbo.RELATIONSHIP_DIM rd on rd.ID_RELATIONSHIP_DIM=alf.ID_RELATIONSHIP_DIM 
			and rd.CD_RLTNSHP_VCTM=13
			join dbo.PEOPLE_DIM pd on pd.ID_PRSN=alf.ID_PRSN_SUBJECT and pd.IS_CURRENT=1 and  (dbo.fnc_datediff_yrs(pd.dt_birth,intk.inv_ass_start)) >14
			where pd.CD_GNDR='F'
		commit tran t10
		-- NEXT LOOK AT INTAKE NAME AND PARENTAL ROLE OVER INTAKE ROLES
		begin tran t11
		update intk
		set 	ID_PEOPLE_DIM_HH=q.id_people_dim
				,ID_PRSN_HH=q.ID_PRSN
				,pk_gndr=case when q.CD_GNDR = 'F' then 1 when q.CD_GNDR='M' then 2 else 3 end
				,DT_BIRTH=q.DT_BIRTH
				,IS_CURRENT=q.IS_CURRENT
				,cd_race_census=q.cd_race_census
				,census_hispanic_latino_origin_cd=q.census_hispanic_latino_origin_cd 
				,fl_hh_is_mother=case when CD_GNDR='F' then 1 else 0 end
		from  ##referrals intk
		join (select ink.id_intake_fact,pedCur.id_people_dim,pedCur.ID_PRSN,pedCur.CD_GNDR,pedCur.DT_BIRTH,pedCur.IS_CURRENT,pedCur.cd_race_census
				,pedCur.census_hispanic_latino_origin_cd
					,ROW_NUMBER() over (partition by ink.id_intake_fact order by ink.ID_INTAKE_FACT,isnull(pedCur.CD_GNDR,'Z') asc) as gndr_sort
				from  ##referrals ink
				 join dbo.INTAKE_PARTICIPANT_FACT ipf
					on ipf.ID_INTAKE_FACT = ink.ID_INTAKE_FACT
				 join dbo.INTAKE_PARTICIPANT_ROLES_DIM ipd
					on ipd.ID_INTAKE_PARTICIPANT_ROLES_DIM = ipf.ID_INTAKE_PARTICIPANT_ROLES_DIM
				 join dbo.PEOPLE_DIM ped on ped.ID_PEOPLE_DIM = ipf.ID_PEOPLE_DIM_CHILD
				 join dbo.PEOPLE_DIM pedCur on pedCur.ID_PRSN=ped.ID_PRSN and pedCur.IS_CURRENT=1
				where ((isnull(CD_ROLE1,0) = 14 or  -- parent = 14
						isnull(CD_ROLE2,0) = 14 or 
						isnull(CD_ROLE3,0) = 14 or
						isnull(CD_ROLE4,0) = 14 or
						isnull(CD_ROLE5,0) = 14)
						AND (isnull(CD_ROLE1,0) = 5 or
							isnull(CD_ROLE2,0) = 5 or 
							isnull(CD_ROLE3,0) = 5 or
							isnull(CD_ROLE4,0) = 5 or
							isnull(CD_ROLE5,0) = 5
							))
						and (dbo.fnc_datediff_yrs(pedCur.dt_birth,ink.inv_ass_start)) >14 ) q on q.ID_INTAKE_FACT=intk.ID_INTAKE_FACT and q.gndr_sort=1
		where  intk.ID_PRSN_HH is null								
		commit  tran t11

		begin tran t12
		-- LOOK AT PARENENTAL ROLE ONLY		
		update intk
		set 	ID_PEOPLE_DIM_HH=q.id_people_dim
				,ID_PRSN_HH=q.ID_PRSN
				,pk_gndr=case when q.CD_GNDR = 'F' then 1 when q.CD_GNDR='M' then 2 else 3 end
				,DT_BIRTH=q.DT_BIRTH
				,IS_CURRENT=q.IS_CURRENT
				,cd_race_census=q.cd_race_census
				,census_hispanic_latino_origin_cd=q.census_hispanic_latino_origin_cd 
				,fl_hh_is_mother=case when CD_GNDR='F' then 1 else 0 end
		from  ##referrals intk
		join (select ink.id_intake_fact,pedCur.id_people_dim,pedCur.ID_PRSN,pedCur.CD_GNDR,pedCur.DT_BIRTH,pedCur.IS_CURRENT
		,pedCur.cd_race_census,pedCur.census_hispanic_latino_origin_cd
					,ROW_NUMBER() over (partition by ink.id_intake_fact order by ink.ID_INTAKE_FACT,isnull(pedCur.CD_GNDR,'Z') asc) as gndr_sort
				from  ##referrals ink
				 join dbo.INTAKE_PARTICIPANT_FACT ipf
					on ipf.ID_INTAKE_FACT = ink.ID_INTAKE_FACT
				 join dbo.INTAKE_PARTICIPANT_ROLES_DIM ipd
					on ipd.ID_INTAKE_PARTICIPANT_ROLES_DIM = ipf.ID_INTAKE_PARTICIPANT_ROLES_DIM
				 join dbo.PEOPLE_DIM ped on ped.ID_PEOPLE_DIM = ipf.ID_PEOPLE_DIM_CHILD
				 join dbo.PEOPLE_DIM pedCur on pedCur.ID_PRSN=ped.ID_PRSN and pedCur.IS_CURRENT=1
				where ((isnull(CD_ROLE1,0) = 14 or  -- parent = 14
						isnull(CD_ROLE2,0) = 14 or 
						isnull(CD_ROLE3,0) = 14 or
						isnull(CD_ROLE4,0) = 14 or
						isnull(CD_ROLE5,0) = 14))
						and (dbo.fnc_datediff_yrs(pedCur.dt_birth,ink.inv_ass_start)) >14 ) q on q.ID_INTAKE_FACT=intk.ID_INTAKE_FACT and q.gndr_sort=1
		where  intk.ID_PRSN_HH is null	
		
	  -- LOOK AT INTAKE NAME
		--For those we missed above update with intake name only
		update intk
		set 	ID_PEOPLE_DIM_HH=q.id_people_dim
				,ID_PRSN_HH=q.ID_PRSN
				,pk_gndr=case when q.CD_GNDR = 'F' then 1 when q.CD_GNDR='M' then 2 else 3 end
				,DT_BIRTH=q.DT_BIRTH
				,IS_CURRENT=q.IS_CURRENT
				,cd_race_census=q.cd_race_census
				,census_hispanic_latino_origin_cd=q.census_hispanic_latino_origin_cd 
				,fl_hh_is_mother=case when q.CD_GNDR='F' then 1 else 0 end
		from  ##referrals intk
		join (select ink.id_intake_fact,pedCur.id_people_dim,pedCur.ID_PRSN,pedCur.CD_GNDR,pedCur.DT_BIRTH,pedCur.IS_CURRENT
		,pedCur.cd_race_census,ped.census_hispanic_latino_origin_cd
					,ROW_NUMBER() over (partition by ink.id_intake_fact order by ink.ID_INTAKE_FACT,isnull(pedCur.CD_GNDR,'Z') asc) as gndr_sort
				from  ##referrals ink
				 join dbo.INTAKE_PARTICIPANT_FACT ipf
					on ipf.ID_INTAKE_FACT = ink.ID_INTAKE_FACT
				 join dbo.INTAKE_PARTICIPANT_ROLES_DIM ipd
					on ipd.ID_INTAKE_PARTICIPANT_ROLES_DIM = ipf.ID_INTAKE_PARTICIPANT_ROLES_DIM
				 join dbo.PEOPLE_DIM ped on ped.ID_PEOPLE_DIM = ipf.ID_PEOPLE_DIM_CHILD
				 join dbo.PEOPLE_DIM pedCur on pedCur.ID_PRSN=ped.ID_PRSN and pedCur.IS_CURRENT=1
					where  (isnull(CD_ROLE1,0) = 5 or
				isnull(CD_ROLE2,0) = 5 or 
				isnull(CD_ROLE3,0) = 5 or
				isnull(CD_ROLE4,0) = 5 or
				isnull(CD_ROLE5,0) = 5
				)	and (dbo.fnc_datediff_yrs(pedCur.dt_birth,ink.inv_ass_start)) >14 ) q on q.ID_INTAKE_FACT=intk.ID_INTAKE_FACT and q.gndr_sort=1
		where  intk.ID_PRSN_HH is null								
		
		
		
		update intk
		set intk.pk_gndr=3 ,intk.cd_race_census=7,census_hispanic_latino_origin_cd=5
		from ##referrals intk where id_prsn_hh is null

		
		commit tran t12
		---------------------------------------------------------------------------------------------- IDENTIFY CHILDREN
	
		if object_ID('tempDB..##household_children') is not null drop table ##household_children
		select distinct
			 intk.id_case
			,intk.id_intake_fact 
			,pdCur.ID_PRSN as ID_PRSN_CHILD
			,pdCur.dt_birth
			,dbo.fnc_datediff_yrs(pdCur.dt_birth,inv_ass_start) as age_at_referral_dt
		into ##household_children
		from  ##referrals intk
		join dbo.INTAKE_PARTICIPANT_FACT  
			on INTAKE_PARTICIPANT_FACT.ID_INTAKE_FACT=intk.id_intake_fact
		  join dbo.[INTAKE_PARTICIPANT_ROLES_DIM] prd 
			on prd.ID_INTAKE_PARTICIPANT_ROLES_DIM=INTAKE_PARTICIPANT_FACT.ID_INTAKE_PARTICIPANT_ROLES_DIM
		  join dbo.people_dim pd 
		  on INTAKE_PARTICIPANT_FACT.id_people_dim_child =pd.id_people_dim
		  join dbo.people_dim pdCur on pdCur.ID_PRSN=pd.ID_PRSN and pdCur.IS_CURRENT=1
			and pdCur.dt_birth < inv_ass_start
			where  coalesce(cd_role1,cd_role2,cd_role3,cd_role4,cd_role5,0) in (1,8,12,19);
		
		begin tran t20	 
		insert into ##household_children
		select distinct
			 intk.id_case
			,intk.id_intake_fact
			, pdCur.ID_PRSN as  ID_PRSN_CHILD
			,pdCur.dt_birth
			,dbo.fnc_datediff_yrs(pdCur.dt_birth,inv_ass_start) as age_at_referral_dt
		from  ##referrals intk
		join dbo.intake_victim_fact ivf  
			on ivf.ID_INTAKE_FACT=intk.id_intake_fact
		  join dbo.people_dim pd 
		  on ivf.id_people_dim_child =pd.id_people_dim
		join dbo.people_dim pdCur on pdCur.ID_PRSN=pd.ID_PRSN and pdCur.IS_CURRENT=1
			and pdCur.dt_birth < inv_ass_start
		except
		select * from  ##household_children;
		commit tran t20

		begin tran t21
		delete from ##household_children where age_at_referral_dt > 17;
		commit tran t21

		if object_ID(N'base.tbl_household_children',N'U') is not null drop table [base].tbl_household_children
		CREATE TABLE [base].tbl_household_children (
					[id_case] [int] NOT NULL,
					[id_intake_fact] [int] NOT NULL,
					[id_prsn_child] [int] NOT NULL,
					[dt_birth] [datetime] NULL,
					[age_at_referral_dt] [int] NULL,
				PRIMARY KEY CLUSTERED 
				(
					[id_case] ASC,
					[ID_PRSN_CHILD] ASC,
					[id_intake_fact] ASC
				)) ON [PRIMARY]		 
		
		insert into base.tbl_household_children ([id_case],[id_intake_fact],[ID_PRSN_CHILD],[dt_birth],[age_at_referral_dt])
		select [id_case],[id_intake_fact],[id_prsn_child],[dt_birth],[age_at_referral_dt]
		from ##household_children
		order by id_case,id_prsn_child, id_intake_fact		

		if object_ID('tempDB..##household_children_aggr') is not null drop table ##household_children_aggr
		select id_intake_fact
			,count(distinct id_prsn_child) as cnt_child
			,sum(case when age_at_referral_dt between 0 and 17 then 1 else 0 end) as cnt_under_18
			,sum(case when age_at_referral_dt between 0 and 5 then 1 else 0 end) as cnt_under_6
			,sum(case when age_at_referral_dt between 6 and 17 then 1 else 0 end) as cnt_between_6_17
		into ##household_children_aggr 	
		from ##household_children
		group by id_intake_fact;
			 

		begin tran t30
	
		update intk
		set cd_sib_age_grp= 1
		from  ##referrals intk
		join ##household_children_aggr aggr on aggr.id_intake_fact=intk.id_intake_fact
		where cnt_under_18>0 and cnt_under_6=cnt_under_18;

		update intk
		set cd_sib_age_grp=2
		from  ##referrals intk
		join ##household_children_aggr aggr on aggr.id_intake_fact=intk.id_intake_fact
		where cnt_under_18>0 and cnt_between_6_17=cnt_under_18;

		update intk
		set cd_sib_age_grp=3
		from  ##referrals intk
		join ##household_children_aggr aggr on aggr.id_intake_fact=intk.id_intake_fact
		where cnt_under_18>0 and cnt_between_6_17 > 0
		and cnt_under_6 > 0 and cd_sib_age_grp is null ;

		update intk
		set cd_sib_age_grp=4
		from  ##referrals intk
		where cd_sib_age_grp is null ;

		update intk
		set [cnt_children_at_intake]=cnt_child
		from ##referrals intk
		join ##household_children_aggr aggr on aggr.id_intake_fact=intk.id_intake_fact

	

		--update allegation flags  --CD_FINDING=5 is FOUNDED
		--------------------------------------------------------------------------------------------------------------------------------------ALLEGATION
		update intk
		set fl_phys_abuse=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (3)

		update intk
		set fl_sexual_abuse=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (5,6) 

		update intk
		set fl_neglect=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (1,2,10) 

		update intk
		set fl_other_maltreatment=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0) in (7,8,9,11,12) 

		update intk
		set fl_allegation_any=1
		from  ##referrals intk
		where fl_phys_abuse=1 or fl_sexual_abuse=1 or fl_neglect=1 or fl_other_maltreatment=1

		--ALLEGATION FOUNDED CURRENT
		update intk
		set fl_founded_phys_abuse=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (3) and isnull(fd.CD_FINDING,0)=5

		update intk
		set fl_founded_sexual_abuse=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (5,6) and isnull(fd.CD_FINDING,0)=5

		update intk
		set fl_founded_neglect=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0)  in (1,2,10)  and isnull(fd.CD_FINDING,0)=5

		update intk
		set fl_founded_other_maltreatment=1
		from  ##referrals intk
		 join dbo.ALLEGATION_FACT af on af.ID_INTAKE_FACT=intk.ID_INTAKE_FACT
		left join dbo.FINDINGS_DIM fd on af.ID_FINDINGS_DIM =fd.ID_FINDINGS_DIM
		left join dbo.ABUSE_TYPE_DIM atd on af.ID_ABUSE_TYPE_DIM=atd.ID_ABUSE_TYPE_DIM
		where isnull(CD_ALLEGATION,0) in (7,8,9,11,12)  and isnull(fd.CD_FINDING,0)=5

		-- exclude other maltreatment as it is not LEGAL to have a FOUNDED OTHER allegation (there is dirty day that has this)
		update intk
		set fl_founded_any_legal=1
		from  ##referrals intk
		where fl_founded_phys_abuse=1 or fl_founded_sexual_abuse=1 or fl_founded_neglect=1 

		-- ALLEGATION PRIOR

		update intk
		set fl_prior_phys_abuse=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where isnull(atd2.CD_ALLEGATION,0)  in (3)

		update intk
		set fl_prior_sexual_abuse=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where isnull(atd2.CD_ALLEGATION,0)  in (5,6) 

		update intk
		set fl_prior_neglect=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where isnull(atd2.CD_ALLEGATION,0)  in (1,2,10) 

		update intk
		set fl_prior_other_maltreatment=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where isnull(atd2.CD_ALLEGATION,0) in (7,8,9,11,12) 


		update intk
		set fl_prior_allegation_any=1
		from  ##referrals intk
		where fl_prior_phys_abuse=1 or fl_prior_sexual_abuse=1 or fl_prior_neglect=1 or fl_prior_other_maltreatment=1



		--match by id_case for any use case open / close dates
		-- ALLEGATION FOUNDED PRIOR
		update intk
		set fl_founded_prior_phys_abuse=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where (isnull(atd2.CD_ALLEGATION,0) in (3)and isnull(fd2.CD_FINDING,0)=5) 

		update intk
		set fl_founded_prior_sexual_abuse=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))	
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where (isnull(atd2.CD_ALLEGATION,0) in (5,6)  and isnull(fd2.CD_FINDING,0)=5) 
		
	
		update intk
		set fl_founded_prior_negelect=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))	
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where (isnull(atd2.CD_ALLEGATION,0) in (1,2,10)  and isnull(fd2.CD_FINDING,0)=5) 


		update intk
		set fl_founded_prior_other_maltreatment=1
		from  ##referrals intk
		 join  ##referrals priorInt on priorInt.id_case=intk.id_case
			and ((priorInt.rfrd_date < intk.rfrd_date)
				or (priorInt.rfrd_date = intk.rfrd_date and priorInt.id_intake_fact < intk.id_intake_fact))
		 join dbo.ALLEGATION_FACT af2 on af2.ID_INTAKE_FACT= priorInt.ID_INTAKE_FACT
		 join dbo.FINDINGS_DIM fd2 on af2.ID_FINDINGS_DIM =fd2.ID_FINDINGS_DIM 
		 join dbo.ABUSE_TYPE_DIM atd2 on af2.ID_ABUSE_TYPE_DIM=atd2.ID_ABUSE_TYPE_DIM 
		where (isnull(atd2.CD_ALLEGATION,0) in (7,8,9,11,12)  and isnull(fd2.CD_FINDING,0)=5) 



		update intk
		set fl_founded_prior_any_legal=1
		from  ##referrals intk
		where intk.fl_founded_prior_negelect=1 or intk.fl_founded_prior_phys_abuse=1 
		or intk.fl_founded_prior_sexual_abuse=1

		commit tran t30
		-----------------------------------------------------------------------------------------------------------------------------------  CLEAN UP
		begin tran t40
		delete dup
		from ##referrals  dup join (
		select R.id_intake_fact,r.id_investigation_assessment_fact ,ROW_NUMBER() over (partition by id_intake_fact order by rfrd_date,invs_level2_approved,id_investigation_assessment_fact asc) as row_num
		 From ##referrals R where id_intake_fact in (1691356,928051)
		 ) q on q.id_intake_fact=dup.id_intake_fact
		 and row_num > 1 and dup.id_investigation_assessment_fact=q.id_investigation_assessment_fact

		 commit tran t40
		---------------------------------------------------------------------------------------------------------  FIRST LATEST DATES -- nbr_intakes
		update ##referrals
		set first_intake_date=q.first_intake_date,latest_intake_date=q.latest_intake_date, nbr_intakes=q.nbr_intakes, nbr_cps_intakes=q.nbr_cps_intakes
		from (
				select id_case,min(rfrd_date) as first_intake_date,max(rfrd_date) as latest_intake_date ,count(distinct ID_INTAKE_FACT) 	 as  nbr_intakes
						, sum(case when cd_access_type in (1,4) then 1 else 0 end) as nbr_cps_intakes
				 from ##referrals
				group by id_case
			) q 
		where  q.id_case=##referrals.id_case

		--------------------------------------------------------------------------------------------------------- RANK
		update R
		set intake_rank = row_num
		from ##referrals R
		join (select r.*,rank() over (partition by id_case order by rfrd_date) as row_num 
				 from ##referrals R ) q on q.id_intake_fact=r.id_intake_fact and R.rfrd_date=q.rfrd_date

		--------------------------------------------------------------------------------------------------------- PRIOR OOH
		update ##referrals
		set fl_ooh_prior_this_referral=0
			, fl_ooh_after_this_referral=0

		if object_ID('tempDB..##afterEps') is not null drop table ##afterEps
		select   distinct
				  r.id_case
				, tce.id_prsn_child
				, r.id_intake_fact
				, r.intake_rank
				, r.rfrd_date
				, r.inv_ass_start
				, tce.state_custody_start_date
				, datediff(dd,tce.state_custody_start_date,r.inv_ass_start) as days_prior_ooh
				, cast(null as bigint) as row_num
		into ##afterEps
		from ##referrals R
		join base.tbl_child_episodes tce 
			on tce.id_case=r.id_case
			and r.inv_ass_start >= isnull(tce.federal_discharge_date,'12/31/3999')



		update P
		set row_num=q.row_num
		from ##afterEps P
		join (select pr.id_case
					,pr.id_intake_fact
					,pr.id_prsn_child
					,pr.rfrd_date
					,pr.state_custody_start_date
					,pr.inv_ass_start
					,pr.days_prior_ooh
					,pr.intake_rank
				, ROW_NUMBER() over (partition by pr.id_case,id_prsn_child,state_custody_start_date order by days_prior_ooh asc,rfrd_date asc) as row_num
				from ##afterEps pr) q 
				on q.id_case=p.id_case and q.id_intake_fact=p.id_intake_fact 


		update R
		set fl_ooh_prior_this_referral=1
		from ##referrals R
		join ##afterEps  p on p.id_intake_fact=r.id_intake_fact
		where p.row_num=1

		--select fl_ooh_immediately_prior_this_referral as fl_prior,* from ##referrals where id_case in (select id_case from ##referrals where fl_ooh_immediately_prior_this_referral=1)
		--order by id_case,intake_rank


		--select * from base.tbl_child_episodes where id_case in (select id_case from ##referrals where fl_ooh_immediately_prior_this_referral=1) order by id_case,state_custody_start_date

		


		--if object_ID('tempDB..##beforeEps') is not null drop table ##beforeEps
		--select   distinct
		--		    r.id_case
		--		, tce.id_prsn_child
		--		, r.id_intake_fact
		--		, r.intake_rank
		--		, r.rfrd_date
		--		, r.inv_ass_start
		--		, tce.state_custody_start_date
		--		, datediff(dd,r.inv_ass_start,tce.state_custody_start_date) as days_to_ooh
		--		, cast(null as bigint) as row_num
		--into ##beforeEps
		--from ##referrals R
		--join base.tbl_child_episodes tce 
		--	on tce.id_case=r.id_case
		--	and r.inv_ass_start  between dateadd(yy,-1, state_custody_start_date) and  dateadd(dd,10,state_custody_start_date)

		
		--update P
		--set row_num=q.row_num
		--from ##beforeEps P
		--join (select pr.id_case
		--			,pr.id_intake_fact
		--			,pr.id_prsn_child
		--			,pr.rfrd_date
		--			,pr.state_custody_start_date
		--			,pr.inv_ass_start
		--			,pr.days_to_ooh
		--			,pr.intake_rank
		--		, ROW_NUMBER() over (partition by pr.id_case,id_prsn_child,state_custody_start_date order by days_to_ooh asc,rfrd_date desc) as row_num
		--		from ##beforeEps pr) q 
		--		on q.id_case=p.id_case and q.id_intake_fact=p.id_intake_fact 



		

		--update R
		--set fl_ooh_immediately_after_this_referral=1
		--from ##referrals R
		--join ##beforeEps  p on p.id_intake_fact=r.id_intake_fact
		--where p.row_num=1

		update R
		set fl_ooh_after_this_referral=-99
--		select r.id_case,r.id_intake_fact,r.intake_rank,r.rfrd_date,q.*
		from ##referrals R
		join (select id_case,max(intake_rank) as intake_rank from ##referrals group by id_case) q on q.id_case=r.id_case
			and q.intake_rank= r.intake_rank
		where  fl_ooh_after_this_referral =0 and rfrd_date between dateadd(dd,-10,dateadd(yy,-1,(select cutoff_date from dbo.ref_last_dw_transfer))) and (select cutoff_date from dbo.ref_last_dw_transfer)
--			order by r.id_case,rfrd_date

		
		if OBJECT_ID(N'base.tbl_intakes',N'U') is not null truncate table base.tbl_intakes
		insert into base.tbl_intakes (
		id_intake_fact
      ,id_case
      ,id_investigation_assessment_fact
      ,id_safety_assessment_fact
      ,rfrd_date
      ,inv_ass_start
      ,inv_ass_stop
	  ,screen_in_spvr_dcsn_dt
      ,invs_level2_approved
      ,cd_access_type
      ,tx_access_type
      ,cd_invs_type
      ,tx_invs_type
		,cd_invs_disp
		,tx_invs_disp
      ,close_id_assgn_fact
      ,close_assgn_begin_dt
      ,close_assgn_end_dt
	  ,close_assgn_cd_rmts_wrkr_type
	  ,close_assgn_tx_rmts_wrkr_type
      ,cd_spvr_rsn
      ,tx_spvr_rsn
      ,cd_final_decision
      ,tx_final_decision
      ,cd_asgn_type
      ,tx_asgn_type
      ,cd_asgn_rspns
      ,tx_asgn_rspns
      ,cd_reporter
      ,tx_reporter
      ,id_people_dim_hh
      ,id_prsn_hh
      ,pk_gndr
      ,dt_birth
      ,is_current
      ,cd_race_census
      ,census_hispanic_latino_origin_cd
      ,cd_sib_age_grp
      ,cd_office
      ,tx_office
      ,cd_region
      ,fl_ihs_90_day
      ,fl_phys_abuse
      ,fl_sexual_abuse
      ,fl_neglect
      ,fl_other_maltreatment
	  ,fl_allegation_any
      ,fl_founded_phys_abuse
      ,fl_founded_sexual_abuse
      ,fl_founded_neglect
      ,fl_founded_other_maltreatment
	  ,fl_founded_any_legal
      ,fl_prior_phys_abuse
      ,fl_prior_sexual_abuse
      ,fl_prior_neglect
      ,fl_prior_other_maltreatment
	  ,fl_prior_allegation_any
      ,fl_founded_prior_phys_abuse
      ,fl_founded_prior_sexual_abuse
      ,fl_founded_prior_neglect
      ,fl_founded_prior_other_maltreatment
	  ,fl_founded_prior_any_legal
      ,fl_hh_is_mother
      ,fl_cps_invs
      ,fl_cfws
      ,fl_risk_only
      ,fl_alternate_intervention
      ,fl_frs
      ,fl_reopen_case
      ,fl_dlr
      ,cnt_children_at_intake
      ,first_intake_date
      ,latest_intake_date
      ,nbr_intakes
      ,nbr_cps_intakes
      ,intake_rank
      ,fl_ooh_prior_this_referral
      ,fl_ooh_after_this_referral
)

select  id_intake_fact
      ,id_case
      ,id_investigation_assessment_fact
      ,id_safety_assessment_fact
      ,rfrd_date
      ,inv_ass_start
      ,inv_ass_stop
	  ,screen_in_spvr_dcsn_dt
      ,invs_level2_approved
      ,cd_access_type
      ,tx_access_type
      ,cd_invs_type
      ,tx_invs_type
		,cd_invs_disp
		,tx_invs_disp
      ,close_id_assgn_fact
      ,close_assgn_begin_dt
      ,close_assgn_end_dt
	  ,close_assgn_cd_rmts_wrkr_type
	  ,close_assgn_tx_rmts_wrkr_type
      ,cd_spvr_rsn
      ,tx_spvr_rsn
      ,cd_final_decision
      ,tx_final_decision
      ,cd_asgn_type
      ,tx_asgn_type
      ,cd_asgn_rspns
      ,tx_asgn_rspns
      ,cd_reporter
      ,tx_reporter
      ,id_people_dim_hh
      ,id_prsn_hh
      ,pk_gndr
      ,dt_birth
      ,is_current
      ,cd_race_census
      ,census_hispanic_latino_origin_cd
      ,cd_sib_age_grp
      ,cd_office
      ,tx_office
      ,cd_region
      ,fl_ihs_90_day
      ,fl_phys_abuse
      ,fl_sexual_abuse
      ,fl_neglect
      ,fl_other_maltreatment
	  ,fl_allegation_any
      ,fl_founded_phys_abuse
      ,fl_founded_sexual_abuse
      ,fl_founded_neglect
      ,fl_founded_other_maltreatment
	  ,fl_founded_any_legal
      ,fl_prior_phys_abuse
      ,fl_prior_sexual_abuse
      ,fl_prior_neglect
      ,fl_prior_other_maltreatment
	  ,fl_prior_allegation_any
      ,fl_founded_prior_phys_abuse
      ,fl_founded_prior_sexual_abuse
      ,fl_founded_prior_negelect
      ,fl_founded_prior_other_maltreatment
	  ,fl_founded_prior_any_legal
      ,fl_hh_is_mother
      ,fl_cps_invs
      ,fl_cfws
      ,fl_risk_only
      ,fl_alternate_intervention
      ,fl_frs
      ,fl_reopen_case
      ,fl_dlr
      ,cnt_children_at_intake
      ,first_intake_date
      ,latest_intake_date
      ,nbr_intakes
      ,nbr_cps_intakes
      ,intake_rank
      ,fl_ooh_prior_this_referral
      ,fl_ooh_after_this_referral
from ##referrals

	update intk
	set case_nxt_intake_dt=nxt.rfrd_date
	from base.tbl_intakes intk
	join (select id_case,rfrd_date,inv_ass_stop ,id_intake_fact, row_number() over (partition by id_case order by id_case,rfrd_date,isnull(inv_ass_stop,'12/31/3999') ,id_intake_fact) as row_num
	from base.tbl_intakes ) curr on curr.id_intake_fact=intk.id_intake_fact
	join  (select id_case,rfrd_date,inv_ass_stop ,id_intake_fact, row_number() over (partition by id_case order by id_case,rfrd_date,isnull(inv_ass_stop,'12/31/3999') ,id_intake_fact) as row_num
	from base.tbl_intakes )  nxt on curr.id_case=nxt.id_case and  nxt.row_num=curr.row_num + 1





update statistics base.tbl_intakes 
end
else
begin
	select 'Are you  SURE you want to BUILD this table? Need permission key to execute this --' as [Warning]
end


