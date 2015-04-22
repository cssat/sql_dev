CREATE  VIEW dbo.prm_eth_census AS 
select distinct ref_lookup_ethnicity.cd_race_census AS cd_race,xwlk.census_hispanic_latino_origin_cd [cd_origin],ref_lookup_ethnicity.cd_race_census [match_code]
from (ref_lookup_ethnicity_census ref_lookup_ethnicity
 join ref_xwalk_race_origin xwlk on((xwlk.cd_race_census = ref_lookup_ethnicity.cd_race_census))) 
 where (ref_lookup_ethnicity.cd_race_census between 1 and 8) 
 union select distinct xwlk.cd_race_census [cd_race]
		,xwlk.census_hispanic_latino_origin_cd [cd_origin]
		,ref_lookup_ethnicity.cd_race_census [match_code]
			from (ref_xwalk_race_origin  ref_lookup_ethnicity 
					 join ref_lookup_hispanic_latino_census  xwlk on((xwlk.census_hispanic_latino_origin_cd = ref_lookup_ethnicity.census_hispanic_latino_origin_cd))) 
					where (ref_lookup_ethnicity.cd_race_census between 1 and 8) 
union select distinct 0 AS cd_race,xwlk.census_hispanic_latino_origin_cd [cd_origin],xwlk.cd_race_census [match_code]
from  ref_xwalk_race_origin xwlk 
 where (xwlk.cd_race_census between 1 and 8) 


