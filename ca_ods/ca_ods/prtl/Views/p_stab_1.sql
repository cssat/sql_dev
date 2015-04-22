

create view [prtl].[p_stab_1]
as


 select  fiscal_yr
	,years_in_care
	,sum(care_days) care_days
	,sum(isnull(placement_moves,0)) placement_moves
	,sum(isnull(kin_cnt,0)) kin_moves
	,sum(isnull(foster_cnt,0)) foster_moves
	,sum(isnull(group_cnt,0)) group_moves
	,sum(isnull(placement_moves,0)) *1000.0/sum(care_days)  placement_mobility
	,sum(isnull(foster_cnt,0))*1000.0/sum(care_days)  placement_mobility_to_foster
	,sum(isnull(kin_cnt,0))*1000.0/sum(care_days) placement_mobility_to_kin
	,sum(isnull(group_cnt,0))*1000.0/sum(care_days)   placement_mobility_to_group
from 
	base.placement_care_days_mobility
 where exclude_7day=1 
			and exclude_trh=1	
			and age_yrs_exit=-99 
			and age_yrs_removal=-99
			and county_cd=0 and cd_race=0
			and care_days <>0
group by 
fiscal_yr
,years_in_care


