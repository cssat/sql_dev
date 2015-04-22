








create view [dbo].[cube_prtl_poc1ab_dim]
as

select  
	pk_key
	,qry_type
	,iif(qry_type=2,'All','First') qry_type_desc
	,date_type
	,iif(date_type=2,'Year','Quarter') date_type_desc
	,start_date
	,poc1ab.bin_dep_cd
	,dep.bin_dep_desc
	,poc1ab.bin_los_cd
	,losd.bin_los_desc
	,poc1ab.bin_placement_cd
	,plc.bin_placement_desc
	,poc1ab.bin_ihs_svc_cd
	,ihs.bin_ihs_svc_tx
	,poc1ab.cd_reporter_type
	,rpt.tx_reporter_type
	,poc1ab.age_grouping_cd
	,age.age_grouping
	,cd_race
	,tx_race_census
	,poc1ab.census_hispanic_latino_origin_cd
	,census_hispanic_latino_origin
	,poc1ab.pk_gndr
	,gdr.tx_gndr
	,fpl.init_cd_plcm_setng
	,fpl.[Initial Placement Setting]
	,poc1ab.long_cd_plcm_setng
	,tx_plcm_setng as long_tx_plcm_setng
,poc1ab.county_cd
	,county_desc
	,poc1ab.filter_access_type
	,acc.fl_alternate_intervention
	,acc.fl_cfws
	,acc.fl_cps_invs
	,acc.fl_frs
	,acc.fl_risk_only
	,acc.fl_far
	,acc.fl_dlr
   ,poc1ab.filter_allegation
  ,isnull([fl_phys_abuse],0)  [fl_phys_abuse]
      ,isnull([fl_sexual_abuse],0) [fl_sexual_abuse]
      ,isnull([fl_neglect],0) [fl_neglect]
      ,isnull([fl_any_legal],0)[fl_any_legal]
   ,poc1ab.filter_finding
,isnull([fl_founded_phys_abuse],0)[fl_founded_phys_abuse]
      ,isnull([fl_founded_sexual_abuse],0)[fl_founded_sexual_abuse]
      ,isnull([fl_founded_neglect],0)[fl_founded_neglect]
      ,isnull([fl_any_finding_legal],0)[fl_any_finding_legal]
   ,poc1ab.filter_service_category
   ,srv.fl_adoption_support
	,srv.fl_behavioral_rehabiliation_services
	,srv.fl_child_care
	,srv.fl_clothing_incidentals
	,srv.fl_family_focused_services
	,srv.fl_family_home_placements
	,srv.fl_medical
	,srv.fl_mh_services
	,srv.fl_other_therapeutic_living_situations
	,srv.fl_receiving_care
	,srv.fl_respite
	,srv.fl_sexually_aggressive_youth
	,srv.fl_specialty_adolescent_services
	,srv.fl_therapeutic_services
	,srv.fl_transportation
	,srv.fl_various
   ,poc1ab.filter_service_budget
	,fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19
    ,fl_uncat_svc
   ,poc1ab.int_match_param_key
from dbo.cube_prtl_poc1ab_fact poc1ab
 left join (SELECT distinct  [filter_allegation]
      ,[fl_phys_abuse]
      ,[fl_sexual_abuse]
      ,[fl_neglect]
      ,[fl_any_legal]
		FROM [dbo].[ref_match_allegation]) alg on alg.filter_allegation=poc1ab.filter_allegation
left join (SELECT distinct  filter_access_type 
				,iif(cd_access_type=1,1,0) [fl_cps_invs] 
				,iif(cd_access_type=2,1,0)[fl_alternate_intervention]
				,iif(cd_access_type=3,1,0)[fl_frs]
				,iif(cd_access_type=4,1,0)[fl_risk_only]
				,iif(cd_access_type=5,1,0)[fl_cfws]
				,iif(cd_access_type=6,1,0)[fl_far]
				,iif(cd_access_type=7,1,0)[fl_dlr]
		FROM ref_filter_access_type ref) acc on acc.filter_access_type=poc1ab.filter_access_type
left join (
select distinct [filter_finding]
      ,[fl_founded_phys_abuse]
      ,[fl_founded_sexual_abuse]
      ,[fl_founded_neglect]
      ,[fl_any_finding_legal] from [ref_match_finding]) fnd on fnd.filter_finding=poc1ab.filter_finding
	left join (select distinct
	 cast(srv.filter_srvc_type as decimal(18,0)) [filter_service_category]
	,srv.fl_adoption_support
	,srv.fl_behavioral_rehabiliation_services
	,srv.fl_child_care
	,srv.fl_clothing_incidentals
	,srv.fl_family_focused_services
	,srv.fl_family_home_placements
	,srv.fl_medical
	,srv.fl_mh_services
	,srv.fl_other_therapeutic_living_situations
	,srv.fl_receiving_care
	,srv.fl_respite
	,srv.fl_sexually_aggressive_youth
	,srv.fl_specialty_adolescent_services
	,srv.fl_therapeutic_services
	,srv.fl_transportation
	,srv.fl_various
from [ref_match_srvc_type_category] srv) srv on srv.filter_service_category=poc1ab.filter_service_category
left join (SELECT DISTINCT 
                         CAST(filter_service_budget AS decimal(18, 0)) AS filter_service_budget, fl_budget_C12, fl_budget_C14, fl_budget_C15, fl_budget_C16, fl_budget_C18, fl_budget_C19, 
                         fl_uncat_svc
FROM            dbo.ref_match_srvc_type_budget) bud on bud.filter_service_budget=poc1ab.filter_service_budget
left join (select cd_plcm_setng [init_cd_plcm_setng],tx_plcm_setng [Initial Placement Setting] from ref_lookup_plcmnt) fpl on fpl.init_cd_plcm_setng=poc1ab.init_cd_plcm_setng
left join ref_filter_nbr_placement plc on plc.bin_placement_cd=poc1ab.bin_placement_cd
left join ref_filter_dependency dep on dep.bin_dep_cd=poc1ab.bin_dep_cd
left join ref_filter_ihs_services ihs on ihs.bin_ihs_svc_cd=poc1ab.bin_ihs_svc_cd
left join ref_filter_reporter_type rpt on rpt.cd_reporter_type=poc1ab.cd_reporter_type
left join ref_filter_los losD on losD.bin_los_cd=poc1ab.bin_los_cd
left join ref_age_census_child_group age on age.age_grouping_cd=poc1ab.age_grouping_cd
left join ref_lookup_ethnicity_census rc on rc.cd_race_census=poc1ab.cd_race
left join ref_lookup_hispanic_latino_census eth on eth.census_hispanic_latino_origin_cd=poc1ab.census_hispanic_latino_origin_cd
left join ref_lookup_gender gdr on gdr.pk_gndr=poc1ab.pk_gndr
left join ref_lookup_plcmnt lpl on lpl.cd_plcm_setng=poc1ab.long_cd_plcm_setng
left join ref_lookup_county cnty on cnty.county_cd=poc1ab.county_cd












