


 select  cd.fiscal_yr
	,cd.years_in_care
	,sum(cd.care_days) care_days
	,sum(isnull(mc.placement_moves,0)) placement_moves
	,sum(isnull(mc.kin_cnt,0)) kin_moves
	,sum(isnull(mc.foster_cnt,0)) foster_moves
	,sum(isnull(mc.group_cnt,0)) group_moves
	,sum(isnull(mc.placement_moves,0)) *1000.0/sum(cd.care_days)  placement_mobility
	,sum(isnull(mc.foster_cnt,0))*1000.0/sum(cd.care_days)  placement_mobility_to_foster
	,sum(isnull(mc.kin_cnt,0))*1000.0/sum(cd.care_days) placement_mobility_to_kin
	,sum(isnull(mc.group_cnt,0))*1000.0/sum(cd.care_days)   placement_mobility_to_group
from 
	base.care_day_count cd
 join base.placement_mobility_counts mc
		on cd.fiscal_yr = mc.fiscal_yr
			and cd.years_in_care = mc.years_in_care 
			and cd.age_removal=mc.age_removal
			and cd.age_removal=mc.age_removal
			and cd.age_exit=mc.age_exit
			and cd.cd_race=mc.cd_race
			and cd.county_cd=mc.cd_cnty
			and cd.exclude_7day=mc.excludes_7day
			and cd.exclude_trh=mc.excludes_trh
where cd.exclude_7day=1 
			and cd.exclude_trh=1	
			and mc.age_exit=-99 
			and mc.age_removal=-99
			and mc.cd_cnty=0 and mc.cd_race=0
			and care_days <>0
group by 
cd.fiscal_yr
,cd.years_in_care
order by 
	fiscal_yr
	,years_in_care