CREATE VIEW dbo.prm_age_developmental AS 
select distinct age_dim.developmental_age_cd AS age_grouping_cd
,age_dim.developmental_age_cd AS match_code 
from age_dim where (age_dim.age_yr between 0 and 17) 
union select distinct 0 AS age_grouping_cd,age_dim.developmental_age_cd AS match_code from age_dim where (age_dim.age_yr between 0 and 17)
