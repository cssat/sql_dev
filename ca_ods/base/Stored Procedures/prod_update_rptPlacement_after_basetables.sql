CREATE procedure [base].[prod_update_rptPlacement_after_basetables]
as
set nocount on;
  update rpt
set  filter_service_budget = null,int_filter_service_category = null
from base.rptPlacement rpt 
			
update rpt
set  int_filter_service_category = coalesce(xw.int_filter_service_category,1)
from base.rptPlacement rpt 
left join (
		select rpt.id_removal_episode_fact,  (select multiplier from ref_service_cd_subctgry_poc  where cd_subctgry_poc_frc=0) + cast((
			  (max(coalesce(fl_family_focused_services,0)) *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_focused_services'))
			+  (max(coalesce(fl_child_care,0)) *    (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_child_care'))
			+  (max(coalesce(fl_therapeutic_services,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_therapeutic_services'))
			+  (max(coalesce(fl_mh_services,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_mh_services'))
			+  (max(coalesce(fl_receiving_care,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_receiving_care'))
			+  (max(coalesce(fl_family_home_placements,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_family_home_placements'))
			+  (max(coalesce(fl_behavioral_rehabiliation_services,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_behavioral_rehabiliation_services'))
			+  (max(coalesce(fl_other_therapeutic_living_situations,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_other_therapeutic_living_situations'))
			+  (max(coalesce(fl_specialty_adolescent_services,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_specialty_adolescent_services'))
			+  (max(coalesce(fl_respite,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_respite'))
			+  (max(coalesce(fl_transportation,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_transportation'))
			+  (max(coalesce(fl_clothing_incidentals,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_clothing_incidentals'))
			+  (max(coalesce(fl_sexually_aggressive_youth,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_sexually_aggressive_youth'))
			+  (max(coalesce(fl_adoption_support,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_adoption_support'))
			+  (max(coalesce(fl_various,0))  *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_various'))
			+  (max(coalesce(fl_medical,0)) *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_medical'))
			+  (max(coalesce(fl_ihs_reun,0)) *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_ihs_reun'))
			+  (max(coalesce(fl_concrete_goods,0)) *  (select multiplier from ref_service_cd_subctgry_poc where fl_name='fl_concrete_goods'))
			) as decimal(21,0)) as filter_service_category
from base.rptPlacement rpt
 join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
 group by rpt.id_removal_episode_fact ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact
 left join ref_service_category_flag_xwalk xw on xw.filter_service_category=q.filter_service_category



 update rpt
set  filter_service_budget =  coalesce(q.filter_service_budget,power(10.0,7))
from base.rptPlacement rpt 
left join (
		select rpt.id_removal_episode_fact, power(10.0,7) + cast((
			+  (max(coalesce(fl_budget_C12,0))  * power(10.0,6))
			+  (max(coalesce(fl_budget_C14,0))  * power(10.0,5))
			+  (max(coalesce(fl_budget_C15,0))  * power(10.0,4))
			+  (max(coalesce(fl_budget_C16,0))  * power(10.0,3))
			+  (max(coalesce(fl_budget_C18,0))  * power(10.0,2)
			+  (max(coalesce(fl_budget_C19,0))  * power(10.0,1))
			+  (max(coalesce(fl_uncat_svc,0)) ))) as int) as filter_service_budget
		from base.rptPlacement rpt
		  join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
		 group by rpt.id_removal_episode_fact 
 ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact

 update base.procedure_flow
set last_run_date=getdate()
where procedure_nm='prod_update_rptPlacement_after_basetables';