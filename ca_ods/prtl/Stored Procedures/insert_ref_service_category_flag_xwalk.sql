create procedure prtl.insert_ref_service_category_flag_xwalk
as
truncate table dbo.ref_service_category_flag_xwalk
insert into ref_service_category_flag_xwalk
select distinct constant.constant  +
		(fl_family_focused_services.fl_family_focused_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services') ) +
		(fl_child_care.fl_child_care * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_child_care')) +
		(fl_therapeutic_services.fl_therapeutic_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services')) +
		(fl_mh_services.fl_mh_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_mh_services')) +
		(fl_receiving_care.fl_receiving_care * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_receiving_care')) +
		(fl_family_home_placements.fl_family_home_placements * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_home_placements')) +
		(fl_behavioral_rehabiliation_services.fl_behavioral_rehabiliation_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services')) +
		(fl_other_therapeutic_living_situations.fl_other_therapeutic_living_situations * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations')) +
		(fl_specialty_adolescent_services.fl_specialty_adolescent_services * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services')) +
		(fl_respite.fl_respite * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_respite')) +
		(fl_transportation.fl_transportation * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_transportation')) +
		(fl_clothing_incidentals.fl_clothing_incidentals * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_clothing_incidentals')) +
		(fl_sexually_aggressive_youth.fl_sexually_aggressive_youth * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_sexually_aggressive_youth')) +
		(fl_adoption_support.fl_adoption_support * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_adoption_support')) +
		(fl_various.fl_various * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_various')) +
		(fl_medical.fl_medical * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_medical')) +
		(fl_ihs_reun.fl_ihs_reun * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun')) +
		(fl_concrete_goods.fl_concrete_goods * (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods'))  filter_service_category
		,fl_family_focused_services
		,fl_child_care
		,fl_therapeutic_services
		,fl_mh_services
		,fl_receiving_care
		,fl_family_home_placements
		,fl_behavioral_rehabiliation_services
		,fl_other_therapeutic_living_situations
		,fl_specialty_adolescent_services
		,fl_respite
		,fl_transportation
		,fl_clothing_incidentals
		,fl_sexually_aggressive_youth
		,fl_adoption_support
		,fl_various
		,fl_medical
		,fl_ihs_reun
		,fl_concrete_goods
		,(fl_family_focused_services.fl_family_focused_services *
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services')) +
		fl_child_care *
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_child_care')) +
		fl_therapeutic_services*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services')) +
		fl_mh_services*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_mh_services')) +
		fl_receiving_care*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_receiving_care')) +
		fl_family_home_placements*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_family_home_placements')) +
		fl_behavioral_rehabiliation_services*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services')) +
		fl_other_therapeutic_living_situations*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations')) +
		fl_specialty_adolescent_services*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services')) +
		fl_respite*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_respite')) +
		fl_transportation*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_transportation')) +
		fl_clothing_incidentals*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_clothing_incidentals')) +
		fl_sexually_aggressive_youth*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_sexually_aggressive_youth')) +
		fl_adoption_support*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_adoption_support')) +
		fl_various*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_various')) +
		fl_medical*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_medical')) +
		fl_ihs_reun*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun')) +
		fl_concrete_goods*
			power(2,(select power_10 from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods')))  + 1 id_service
from  (select multiplier constant from ref_service_cd_subctgry_poc where cd_subctgry_poc_frc=0) constant
cross join  (select number fl_family_focused_services from numbers  where number between 0 and 1)  fl_family_focused_services
cross join (select number fl_child_care from numbers where number between 0 and 1)   fl_child_care
cross join (select number fl_therapeutic_services from numbers where number between 0 and 1)  fl_therapeutic_services
cross join (select number fl_mh_services from numbers where number between 0 and 1)  fl_mh_services
cross join (select number fl_receiving_care from numbers where number between 0 and 1)  fl_receiving_care
cross join (select number fl_family_home_placements from numbers where number between 0 and 1)  fl_family_home_placements
cross join (select number fl_behavioral_rehabiliation_services from numbers where number between 0 and 1)  fl_behavioral_rehabiliation_services
cross join (select number fl_other_therapeutic_living_situations from numbers where number between 0 and 1)  fl_other_therapeutic_living_situations
cross join (select number fl_specialty_adolescent_services from numbers where number between 0 and 1)  fl_specialty_adolescent_services
cross join (select number fl_respite from numbers where number between 0 and 1)  fl_respite
cross join (select number fl_transportation from numbers where number between 0 and 1)  fl_transportation
cross join (select number fl_clothing_incidentals  from numbers where number between 0 and 1)  fl_clothing_incidentals
cross join (select number fl_sexually_aggressive_youth from numbers where number between 0 and 1)  fl_sexually_aggressive_youth
cross join (select number fl_adoption_support from numbers where number between 0 and 1)  fl_adoption_support
cross join (select number fl_various from numbers where number between 0 and 1)  fl_various
cross join (select number fl_medical from numbers where number between 0 and 1)  fl_medical
cross join (select number fl_ihs_reun from numbers where number between 0 and 1)  fl_ihs_reun
cross join (select number fl_concrete_goods from numbers where number between 0 and 1)  fl_concrete_goods








		
