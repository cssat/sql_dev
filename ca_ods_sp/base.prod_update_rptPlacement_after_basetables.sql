ALTER procedure [base].[prod_update_rptPlacement_after_basetables]
as

  update rpt
set  filter_service_budget = null,filter_service_category=null
from base.rptPlacement rpt 
			
update rpt
set  filter_service_category =  coalesce(q.filter_service_category,power(10.0,16))
from base.rptPlacement rpt 
left join (
		select rpt.id_removal_episode_fact, power(10.0,16) + cast((
			  (max(coalesce(fl_family_focused_services,0)) * power(10.0,15))
			+  (max(coalesce(fl_child_care,0)) * power(10.0,14))
			+  (max(coalesce(fl_therapeutic_services,0)) * power(10.0,13))
			+  (max(coalesce(fl_mh_services,0)) * power(10.0,12))
			+  (max(coalesce(fl_receiving_care,0)) * power(10.0,11))
			+  (max(coalesce(fl_family_home_placements,0)) * power(10.0,10))
			+  (max(coalesce(fl_behavioral_rehabiliation_services,0)) * power(10.0,9))
			+  (max(coalesce(fl_other_therapeutic_living_situations,0)) * power(10.0,8))
			+  (max(coalesce(fl_specialty_adolescent_services,0)) * power(10.0,7))
			+  (max(coalesce(fl_respite,0)) * power(10.0,6))
			+  (max(coalesce(fl_transportation,0)) * power(10.0,5))
			+  (max(coalesce(fl_clothing_incidentals,0)) * power(10.0,4))
			+  (max(coalesce(fl_sexually_aggressive_youth,0)) * power(10.0,3))
			+  (max(coalesce(fl_adoption_support,0)) * power(10.0,2)
			+  (max(coalesce(fl_various,0)) * power(10.0,1))
			+  (max(coalesce(fl_medical,0))))) as decimal(18,0)) as filter_service_category
from base.rptPlacement rpt
 join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
 group by rpt.id_removal_episode_fact ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact



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
			+  (max(coalesce(fl_uncat_svc,0)) ))) as decimal(7,0)) as filter_service_budget
		from base.rptPlacement rpt
		  join base.episode_payment_services eps_svc on eps_svc.id_removal_episode_fact=rpt.id_removal_episode_fact
		 group by rpt.id_removal_episode_fact 
 ) q on q.id_removal_episode_fact=rpt.id_removal_episode_fact

