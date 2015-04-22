create view dbo.prm_age_single_yr as 
select distinct ad.age_yr, ad.age_yr [match_code]
from age_dim ad
where age_yr < 18
union
select distinct ad.age_yr, 0
from age_dim ad
where age_yr < 18