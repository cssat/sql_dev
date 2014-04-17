create view  dbo.ref_age_developmental
as 
select ad.age_mo,ad.age_yr,case when ad.age_yr< 18 then  ad.developmental_age_cd else q.developmental_age_cd end [developmental_age_cd]
,case when ad.age_yr< 18 then ad.developmental_age_tx else q.developmental_age_tx end [developmental_age_tx]
from age_dim ad
left join  (select distinct developmental_age_cd,replace(developmental_age_tx,'17','18')  [developmental_age_tx] from age_dim where age_yr=17) q on ad.age_yr=18
where ad.age_yr <=18