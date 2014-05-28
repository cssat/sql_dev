
use test_annie;
truncate table ref_match_srvc_type_category;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_srvc_type_category.txt'
into table ref_match_srvc_type_category
fields terminated by '|'
(filter_srvc_type,fl_family_focused_services,fl_child_care,fl_therapeutic_services,fl_mh_services ,fl_receiving_care,fl_family_home_placements ,fl_behavioral_rehabiliation_services
,fl_other_therapeutic_living_situations,fl_specialty_adolescent_services,fl_respite,fl_transportation,fl_clothing_incidentals ,fl_sexually_aggressive_youth
,fl_adoption_support,fl_various,fl_medical,cd_subctgry_poc_fr);
analyze table ref_match_srvc_type_category;

  
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_srvc_type_category)
  where tbl_name='ref_match_srvc_type_category';

truncate table ref_match_srvc_type_budget;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_srvc_type_budget.txt'
into table ref_match_srvc_type_budget
fields terminated by '|'
(filter_service_budget,fl_budget_C12,fl_budget_C14,fl_budget_C15,fl_budget_C16,fl_budget_C18,fl_budget_C19,fl_uncat_svc,cd_budget_poc_frc);
analyze table ref_match_srvc_type_budget;


  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_srvc_type_budget)
  where tbl_name='ref_match_srvc_type_budget';

truncate table ref_match_allegation;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_allegation.txt'
into table ref_match_allegation
fields terminated by '|'
(cd_allegation,filter_allegation,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal);
analyze table ref_match_allegation;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_allegation)
  where tbl_name='ref_match_allegation';

truncate table ref_match_finding;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_finding.txt'
into table ref_match_finding
fields terminated by '|'
(filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_any_finding_legal,cd_finding);
analyze table ref_match_finding;

  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_match_finding)
  where tbl_name='ref_match_finding';