if object_id('tempdb..##placement_prep17_5') is not null
	drop table ##placement_prep17_5

select 
	child id_prsn
	,removal_dt
	,discharge_dt
	,birthdate dt_birth
	,dbo.fnc_datediff_yrs(birthdate, removal) age_removal
	,dateadd(yy, 17.5, birthdate) dt_17_5
	,dateadd(dd, 30, dateadd(yy, 17.5, birthdate)) dt_17_5_plus_30
	,epf.id_prsn_child as plan_cntr
	,epf.first_plan_act 
	,max(pcad.cd_placement_care_auth) single_pca --not informative...just to stop dups
	,state_fiscal_yyyy cohort_fy
into ##placement_prep17_5
from base.rptPlacement rp
	join placement_care_auth_fact pca
		on child = pca.id_prsn 
		and dateadd(yy, 17.5, birthdate) between 
			dbo.IntDate_to_CalDate(pca.id_calendar_dim_begin) and 
			isnull(dbo.IntDate_to_CalDate(pca.id_calendar_dim_end), dateadd(yy, 17.5 , birthdate))
	join placement_care_auth_dim pcad
		on pca.id_placement_care_auth_dim = pcad.id_placement_care_auth_dim
			and pcad.cd_placement_care_auth in (1,2,7,8,9)
	left join (select 
					min(id_calendar_dim_plan_date) first_plan_act
					,id_prsn_child 
				from 
					ca_ods.dbo.EDUCATION_PLAN_FACT epf
						join ca_ods.dbo.people_dim pd 
							on pd.id_prsn = epf.id_prsn_child 
							and id_calendar_dim_plan_date <= convert(int, convert(varchar, dateadd(yy, 18, dt_birth),112))
						group by 
							id_prsn_child) epf
		on rp.child = epf.id_prsn_child 
	join calendar_dim cd 
		on cd.CALENDAR_DATE = dateadd(yy, 17.5, birthdate)
where 
	--remove erroneous placements or fc to 21 placements
	dbo.fnc_datediff_yrs(birthdate, removal_dt) < 18
	--select a 17.5 year old cohort over our observation window
	and dateadd(yy, 17.5, birthdate) between  '2011-07-01' and  '2014-06-30'
	--where kids are still in care on their 17.5 bday 
	and discharge_dt > dateadd(yy, 17.5, birthdate)
	--where kids are in for 30 days on their 17.5 bday
	and datediff(dd, removal_dt, dateadd(yy, 17.5, birthdate)) >= 30 
group by 
	child 
	,removal_dt
	,discharge_dt
	,birthdate 
	,dbo.fnc_datediff_yrs(birthdate, removal) 
	,dateadd(yy, 17.5, birthdate) 
	,epf.id_prsn_child
	,epf.first_plan_act 
	,state_fiscal_yyyy 
order by id_prsn 

--for production 

select
	count(id_prsn) kids 
	,sum(iif(plan_cntr is null, 0, 1)) kids_with_plans
	,sum(iif(plan_cntr is null, 0, 1))*1.0/count(id_prsn) prp_kids_with_plans
	,cohort_fy
from ##placement_prep17_5
group by 
	cohort_fy
order by
	cohort_fy






	
