



CREATE view [dbo].[vw_intakes_screened_in]
as
select  inf.id_intake_fact
      ,inf.id_case
      ,inf.id_investigation_assessment_fact
      ,inf.id_safety_assessment_fact
      ,inf.rfrd_date
      ,inf.inv_ass_start
      ,inf.inv_ass_stop
	  ,datediff(dd,inf.inv_ass_start,inf.inv_ass_stop) dur_days
	 ,inf.ia_cmplt_dt
      ,inf.screen_in_spvr_dcsn_dt
      ,inf.cd_access_type
      ,inf.tx_access_type
      ,inf.cd_invs_type
      ,inf.tx_invs_type
	  ,inf.cd_invs_disp
	  ,inf.tx_invs_disp
      ,inf.close_id_assgn_fact
      ,inf.close_assgn_begin_dt
      ,inf.close_assgn_end_dt
      ,inf.cd_spvr_rsn
      ,inf.tx_spvr_rsn
      ,inf.cd_final_decision
      ,inf.tx_final_decision
      ,inf.cd_asgn_type
      ,inf.tx_asgn_type
      ,inf.cd_asgn_rspns
      ,inf.tx_asgn_rspns
      ,inf.cd_reporter
      ,inf.tx_reporter
      ,inf.id_people_dim_hh
      ,inf.id_prsn_hh
      ,inf.pk_gndr
      ,inf.dt_birth
      ,inf.is_current
      ,inf.cd_race_census
      ,inf.census_hispanic_latino_origin_cd 
      ,inf.cd_sib_age_grp
      ,inf.cd_office_first_worker [cd_office]
      ,inf.tx_office_first_worker [tx_office]
	  ,inf.intake_county_cd
	  ,inf.intake_zip
      ,inf.cd_region
      ,inf.fl_ihs_90_day
      ,inf.fl_hh_is_mother
      ,inf.fl_cps_invs
      ,inf.fl_cfws
      ,inf.fl_risk_only
      ,inf.fl_alternate_intervention
      ,inf.fl_frs
      ,inf.fl_reopen_case
      ,inf.fl_dlr
	  ,inf.fl_far
      ,inf.cnt_children_at_intake
      ,inf.first_intake_date
      ,inf.latest_intake_date
	  ,inf.case_nxt_intake_dt
      ,inf.nbr_intakes
      ,inf.nbr_cps_intakes
      ,inf.intake_rank
      ,inf.fl_ooh_prior_this_referral
      ,inf.fl_ooh_after_this_referral
	  ,inf.fl_phys_abuse
      ,inf.fl_sexual_abuse
      ,inf.fl_neglect
      ,inf.fl_other_maltreatment
      ,inf.fl_allegation_any
      ,inf.fl_founded_phys_abuse
      ,inf.fl_founded_sexual_abuse
      ,inf.fl_founded_neglect
      ,inf.fl_founded_other_maltreatment
      ,inf.fl_founded_any_legal
      ,inf.fl_prior_phys_abuse
      ,inf.fl_prior_sexual_abuse
      ,inf.fl_prior_neglect
      ,inf.fl_prior_other_maltreatment
      ,inf.fl_prior_allegation_any
      ,inf.fl_founded_prior_phys_abuse
      ,inf.fl_founded_prior_sexual_abuse
      ,inf.fl_founded_prior_neglect
      ,inf.fl_founded_prior_other_maltreatment
      ,inf.fl_founded_prior_any_legal  
		,power(10,7.0) + (power(10,6.0) * fl_dlr) + (power(10,5.0) * fl_far)+  (power(10,4) * fl_cps_invs)    + (power(10,3) * fl_alternate_intervention) + (power(10,2) * fl_frs) + (power(10,1) * fl_risk_only) + (power(10,0) * fl_cfws) as filter_access_type
		, power(10,4) + (power(10,3) * (case when fl_neglect=1 or fl_sexual_abuse=1 or fl_phys_abuse=1 then 1 else 0 end )) + (power(10,2) *fl_neglect ) + (power(10,1) * fl_sexual_abuse) + (fl_phys_abuse) as filter_allegation
		, power(10,4) + (power(10,3) * fl_founded_any_legal ) + (power(10,2) *fl_founded_neglect ) + (power(10,1) * fl_founded_sexual_abuse) + (fl_founded_phys_abuse) as filter_finding
		,grp.intk_grp_seq_nbr
		,alg.*
from base.tbl_intake_grouper grp
join (
select grp.intake_grouper
	, max(iif(grp.intk_grp_seq_nbr=1,fl_cps_invs,0)) intk_grp_fl_cps_invs
	, max(iif(grp.intk_grp_seq_nbr=1,fl_risk_only,0)) intk_grp_fl_risk_only
	, max(iif(grp.intk_grp_seq_nbr=1,fl_far,0)) intk_grp_fl_far
	, max(iif(grp.intk_grp_seq_nbr=1,fl_dlr,0)) intk_grp_fl_dlr
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
 from base.tbl_intake_grouper grp
join base.tbl_intakes intk on grp.id_intake_fact=intk.id_intake_fact and intk.cd_final_decision=1
group by grp.intake_grouper ) alg on alg.intake_grouper=grp.intake_grouper
join base.tbl_intakes inf on inf.id_intake_fact=grp.id_intake_fact














