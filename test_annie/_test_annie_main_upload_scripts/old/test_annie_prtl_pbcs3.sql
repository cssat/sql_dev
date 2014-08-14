use test_annie;
truncate table prtl_pbcs3;
LOAD DATA LOCAL INFILE '/data/pocweb/prtl_pbcs3.txt'
into table prtl_pbcs3
fields terminated by '|'
(cohort_begin_date,date_type,qry_type,cd_race_census,census_hispanic_latino_origin_cd,
cd_office_collapse,cd_sib_age_grp,int_match_param_key,cd_reporter_type,bin_ihs_svc_cd,
filter_access_type,fl_cps_invs,fl_alternate_intervention,fl_frs,fl_risk_only,fl_cfws,
filter_allegation,fl_any_legal,fl_phys_abuse,fl_sexual_abuse,fl_neglect,filter_finding,
fl_founded_any_legal,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_family_focused_services,
fl_child_care,fl_therapeutic_services,fl_family_home_placements,fl_behavioral_rehabiliation_services,fl_other_therapeutic_living_situations,
fl_specialty_adolescent_services,fl_respite,fl_transportation,fl_adoption_support,filter_service_type,
fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,
filter_budget_type,min_placed_within_month,cnt_case);
						 


select min(cohort_begin_date) as Min_Date,max(cohort_begin_date) as max_Date
,min_placed_within_month,sum(cnt_case) as cnt_case from prtl_pbcs3
group by min_placed_within_month;
