USE [CA_ODS]
GO

/****** Object:  View [prtl].[vw_referrals_grp]    Script Date: 10/3/2014 5:49:53 AM ******/
DROP VIEW [prtl].[vw_referrals_grp]
GO

/****** Object:  View [prtl].[vw_referrals_grp]    Script Date: 10/3/2014 5:49:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- QA
-- select * from [prtl].[vw_referrals_grp] where intake_grouper=200431
-- select * from  [prtl].[vw_referrals_grp]   where id_case=438122
--  select intake_grouper,count(*)  from base.tbl_intake_grouper group by intake_grouper order by count(*) desc

CREATE  view [prtl].[vw_referrals_grp] as 


	select		distinct
				2as qry_type -- unique
				,date_type  as date_type --month
				,startDate  cohort_entry_date
				,endDate 
				,tce.id_case
				,grp_filters.grp_id_case
				,iif(tce.id_case<=0,tce.rfrd_date,tce.first_intake_date) first_intake_date
				,iif(tce.id_case<=0,tce.rfrd_date,tce.latest_intake_date) latest_intake_date
				, tce.id_intake_fact
				,grp.intake_grouper
				,grp.intk_grp_seq_nbr
				,grp_filters.intk_grp_id_intake_fact  "grp_id_intake_fact"
				,grp_filters.rfrd_date "grp_rfrd_date"
				,grp_filters.intk_grp_fl_cps_invs
				,grp_filters.intk_grp_fl_far
				,grp_filters.intk_grp_fl_risk_only
				,grp_filters.intk_grp_fl_dlr fl_dlr
				,iif(grp_filters.intake_grouper is null,tce.cd_access_type,grp_filters.intk_grp_cd_access_type) cd_access_type
				,IIF(iif(grp_filters.intake_grouper is null,tce.intake_county_cd,grp_filters.intk_grp_intake_county_cd)=0
						,-99
						,iif(grp_filters.intake_grouper is null,tce.intake_county_cd,grp_filters.intk_grp_intake_county_cd)
						) intake_county_cd
				,iif(grp_filters.intake_grouper is null,tce.inv_ass_start,grp_filters.intk_grp_inv_ass_start) inv_ass_start
				,iif(grp_filters.intake_grouper is null,tce.rfrd_date,grp_filters.rfrd_date) rfrd_date
				, iif(grp_filters.intake_grouper is null,tce.fl_phys_abuse,iif(cnt_intk_grp_phys_abuse>0,1,0)) fl_phys_abuse
				, iif(grp_filters.intake_grouper is null,tce.fl_sexual_abuse,iif(cnt_intk_grp_sexual_abuse>0,1,0)) fl_sexual_abuse
				, iif(grp_filters.intake_grouper is null,tce.fl_neglect,iif(cnt_intk_grp_neglect>0,1,0)) fl_neglect
				, IIF( ( iif(grp_filters.intake_grouper is null,tce.fl_phys_abuse,iif(cnt_intk_grp_phys_abuse>0,1,0)) )>0
						or (iif(grp_filters.intake_grouper is null,tce.fl_sexual_abuse,iif(cnt_intk_grp_sexual_abuse>0,1,0))) > 0
						or  (iif(grp_filters.intake_grouper is null,tce.fl_neglect,iif(cnt_intk_grp_neglect>0,1,0))) > 0 , 1 , 0) [fl_any_legal]
				, iif(grp_filters.intake_grouper is null,tce.fl_founded_phys_abuse,iif(cnt_intk_grp_founded_phys_abuse>0,1,0)) fl_founded_phys_abuse
				, iif(grp_filters.intake_grouper is null,tce.fl_founded_sexual_abuse,iif(cnt_intk_grp_founded_sexual_abuse>0,1,0)) fl_founded_sexual_abuse
				, iif(grp_filters.intake_grouper is null,tce.fl_founded_neglect,iif(cnt_intk_grp_founded_neglect>0,1,0)) fl_founded_neglect
				, iif(grp_filters.intake_grouper is null,tce.fl_founded_any_legal,iif(cnt_intk_grp_founded_any_legal>0,1,0)) fl_founded_any_legal
				, 0 as fl_initref_cohort_date
				,iif(grp_filters.intake_grouper is null,tce.cd_final_decision,grp_filters.grp_cd_final_decision) cd_final_decision
				,iif(grp_filters.intake_grouper is not null,fl_hh_under_18,0) hh_with_children_under_18
				,DENSE_RANK() over (partition by coalesce(grp_filters.grp_id_case,tce.id_intake_fact) 
																order by coalesce(grp_filters.rfrd_date,tce.rfrd_date)
																				,coalesce(grp.intake_grouper,tce.id_intake_fact )asc) case_nth_order
		from base.tbl_intakes  tce 
		left join base.tbl_intake_grouper grp on grp.id_intake_fact=tce.id_intake_fact
		left join (
					select grp.intake_grouper
								, max(iif(grp.intk_grp_seq_nbr=1,grp.id_case,null)) grp_id_case
								, max(iif(grp.intk_grp_seq_nbr=1,rfrd_date,null)) rfrd_date
								, max(iif(grp.intk_grp_seq_nbr=1,fl_cps_invs,0)) intk_grp_fl_cps_invs
								, max(iif(grp.intk_grp_seq_nbr=1,fl_risk_only,0)) intk_grp_fl_risk_only
								, max(iif(grp.intk_grp_seq_nbr=1,fl_far,0)) intk_grp_fl_far
								, max(iif(grp.intk_grp_seq_nbr=1,fl_dlr,0)) intk_grp_fl_dlr
								,  max(iif(grp.intk_grp_seq_nbr=1,intk.cd_access_type,0)) intk_grp_cd_access_type
								, max(iif(grp.intk_grp_seq_nbr=1,fl_alternate_intervention,0)) intk_grp_fl_alternate_intervention
								, max(iif(grp.intk_grp_seq_nbr=1,fl_cfws,0)) intk_grp_fl_cfws
								, max(iif(grp.intk_grp_seq_nbr=1,fl_frs,0)) intk_grp_fl_frs
								, max(iif(grp.intk_grp_seq_nbr=1,cd_reporter,0)) intk_grp_cd_reporter_type
								, max(iif(grp.intk_grp_seq_nbr=1,cd_race_census,0)) intk_grp_cd_race_census
								,max(iif(grp.intk_grp_seq_nbr=1,census_hispanic_latino_origin_cd,0)) intk_grp_census_hispanic_latino_origin_cd
								,max(iif(grp.intk_grp_seq_nbr=1,cd_sib_age_grp,0)) intk_grp_cd_sib_age_grp
								,max(iif(grp.intk_grp_seq_nbr=1,intake_county_cd,0)) intk_grp_intake_county_cd
								,max(iif(grp.intk_grp_seq_nbr=1,inv_ass_start,null)) intk_grp_inv_ass_start
								,max(iif(grp.intk_grp_seq_nbr=1,inv_ass_stop,null)) intk_grp_inv_ass_stop
								,max(iif(grp.intk_grp_seq_nbr=1,grp.id_intake_fact,null)) intk_grp_id_intake_fact
								, SUM(fl_phys_abuse) as cnt_intk_grp_phys_abuse
								, SUM(fl_sexual_abuse) as cnt_intk_grp_sexual_abuse
								, SUM(fl_neglect) as cnt_intk_grp_neglect
								, SUM(fl_other_maltreatment) as cnt_intk_grp_other_maltreatment
								, SUM(fl_allegation_any) as cnt_intk_grp_allegation_any
								, SUM(fl_founded_phys_abuse) as cnt_intk_grp_founded_phys_abuse
								, SUM(fl_founded_sexual_abuse) as cnt_intk_grp_founded_sexual_abuse
								, SUM(fl_founded_neglect) as cnt_intk_grp_founded_neglect
								, SUM(fl_founded_other_maltreatment) as cnt_intk_grp_founded_other_maltreatment
								, SUM(fl_founded_any_legal) as cnt_intk_grp_founded_any_legal
								, SUM(fl_prior_phys_abuse) as cnt_intk_grp_prior_phys_abuse
								, SUM(fl_prior_sexual_abuse) as cnt_intk_grp_prior_sexual_abuse
								, SUM(fl_prior_neglect)as cnt_intk_grp_prior_neglect
								, SUM(fl_prior_other_maltreatment)as cnt_intk_grp_prior_other_maltreatment
								, SUM(fl_prior_allegation_any)as cnt_intk_grp_prior_allegation_any
								, SUM(fl_founded_prior_phys_abuse)as cnt_intk_grp_founded_prior_phys_abuse
								, SUM(fl_founded_prior_sexual_abuse)as cnt_intk_grp_founded_prior_sexual_abuse
								, SUM(fl_founded_prior_neglect)as cnt_intk_grp_founded_prior_negelect
								, SUM(fl_founded_prior_other_maltreatment) as cnt_intk_grp_founded_prior_other_maltreatment
								, SUM(fl_founded_prior_any_legal) as cnt_intk_grp_founded_prior_any_legal
								, IIF(SUM(IIF(hh_under_18.id_intake_fact is not null,1,0))>0,1,0) fl_hh_under_18
								, IIF(SUM(iif(cd_final_decision=1,1,0)) > 0,1,0)  as grp_cd_final_decision
					 from base.tbl_intake_grouper grp
					join base.tbl_intakes intk on grp.id_intake_fact=intk.id_intake_fact 
					left join (select distinct id_intake_fact from base.tbl_household_children where age_at_referral_dt<18
										) hh_under_18 on hh_under_18.id_intake_fact=intk.id_intake_fact
					group by grp.intake_grouper
					) grp_filters on grp.intake_grouper=grp_filters.intake_grouper
		join (select distinct 0 date_type,[month]startDate,EOMONTH([month]) endDate
					from calendar_dim cd
					,ref_last_dw_transfer
					where cd.CALENDAR_DATE>='2000-01-01' and EOMONTH([month]) < cutoff_date
				) md on grp_filters.intk_grp_inv_ass_start between  md.startDate and md.endDate






GO


