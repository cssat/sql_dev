CREATE VIEW dbo.prm_age_cdc_census_mix AS 
select ref_lookup_age_cdc_census_mix.age_grouping_cd AS age_grouping_cd,ref_lookup_age_cdc_census_mix.age_grouping_cd AS match_code 
from (select distinct  cdc_census_mix_age_cd [age_grouping_cd], cdc_census_mix_age_tx [age_grouping]from age_dim where age_mo < 18 * 12) ref_lookup_age_cdc_census_mix where (ref_lookup_age_cdc_census_mix.age_grouping_cd <> 0) 
union select 0 ,ref_lookup_age_cdc_census_mix.age_grouping_cd AS match_code from (select distinct  cdc_census_mix_age_cd [age_grouping_cd], cdc_census_mix_age_tx [age_grouping]from age_dim where age_mo < 18 * 12)  ref_lookup_age_cdc_census_mix  where (ref_lookup_age_cdc_census_mix.age_grouping_cd <> 0)



