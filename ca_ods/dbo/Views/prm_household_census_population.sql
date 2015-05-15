


CREATE view [dbo].[prm_household_census_population]
as
select measurement_year,cd_sib_age_grp,cd_race,county_cd,pop_cnt
from public_data.census_population_household
union all
select measurement_year,0 [cd_sib_age_grp],cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
group by measurement_year,cd_race,county_cd
union all
select measurement_year,cd_sib_age_grp,0 [cd_race],county_cd,sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
where cd_race <=8
group by measurement_year,cd_sib_age_grp,county_cd
union all
select measurement_year,cd_sib_age_grp, cd_race,0 [county_cd],sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
group by measurement_year,cd_sib_age_grp,cd_race
union all
select measurement_year,0 [cd_sib_age_grp],0 [cd_race],county_cd,sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
where cd_race <=8
group by measurement_year, county_cd
union all
select measurement_year,0 [cd_sib_age_grp],cd_race,0 [county_cd],sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
group by measurement_year, cd_race
union all
select measurement_year,cd_sib_age_grp ,0 [cd_race],0 [county_cd],sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
where cd_race <=8
group by measurement_year, cd_sib_age_grp
union all
select measurement_year,0 [cd_sib_age_grp] ,0 [cd_race],0 [county_cd],sum(pop_cnt) [pop_cnt]
from public_data.census_population_household
where cd_race <=8
group by measurement_year




