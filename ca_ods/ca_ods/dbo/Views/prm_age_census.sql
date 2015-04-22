
CREATE VIEW [dbo].prm_age_census AS 
select ref_lookup_age_census.age_grouping_cd AS age_grouping_cd,ref_lookup_age_census.age_grouping_cd AS match_code 
from (select distinct  age_dim.census_child_group_cd [age_grouping_cd], age_dim.census_child_group_tx [age_grouping]from age_dim where age_mo < 18 * 12) ref_lookup_age_census where (ref_lookup_age_census.age_grouping_cd <> 0) 
union select 0 ,ref_lookup_age_census.age_grouping_cd AS match_code from (select distinct  census_child_group_cd [age_grouping_cd], census_child_group_tx [age_grouping]from age_dim where age_mo < 18 * 12)  ref_lookup_age_census  where (ref_lookup_age_census.age_grouping_cd <> 0)




