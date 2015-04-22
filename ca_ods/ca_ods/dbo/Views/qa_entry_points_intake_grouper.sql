create view qa_entry_points_intake_grouper
as select grp.intake_grouper,max(intk_grp_seq_nbr) intk_grp_seq_nbr
	,sum(fl_cps_invs) fl_cps_invs
	,sum(fl_risk_only) fl_risk_only
	,sum(fl_far) fl_far
	,sum(fl_dlr) fl_dlr
	,sum(fl_alternate_intervention) fl_alternate_intervention
	,sum(fl_cfws) fl_cfws
	,sum(fl_frs) fl_frs
  from base.tbl_intakes  intk
join  base.tbl_intake_grouper grp on  grp.id_intake_fact=intk.id_intake_fact
and intk.cd_final_decision=1  and intk.id_case > 0
group by grp.intake_grouper
having max(intk_grp_seq_nbr) > 1 and  NOT (max(intk_grp_seq_nbr) = sum(fl_cps_invs) 
		or max(intk_grp_seq_nbr) = sum(fl_risk_only)
		or max(intk_grp_seq_nbr) = sum(fl_far)
		or max(intk_grp_seq_nbr) = sum(fl_dlr)
		or max(intk_grp_seq_nbr) = sum(fl_alternate_intervention)
		or max(intk_grp_seq_nbr) = sum(fl_cfws)
		or max(intk_grp_seq_nbr) = sum(fl_frs))



