USE [CA_ODS]
GO

/****** Object:  View [dbo].[prm_household_census_population]    Script Date: 6/25/2014 8:09:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[prm_household_census_population]
as
select  measurement_year,cd_sib_age_grp,cd_race,county_cd,pop_cnt
 from ref_lookup_census_population_poc2
 union
select measurement_year,0 cd_sib_age_grp,cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year,cd_race,county_cd
 union
select measurement_year,cd_sib_age_grp,0 cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year,cd_sib_age_grp,county_cd
 union
select measurement_year,cd_sib_age_grp, cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year,cd_sib_age_grp,cd_race
union
select measurement_year,0 cd_sib_age_grp,0 cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year, county_cd
union
select measurement_year,0 cd_sib_age_grp,cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year, cd_race
union
select measurement_year,cd_sib_age_grp ,0 cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year, cd_sib_age_grp
union
select measurement_year,0 cd_sib_age_grp ,0 cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from ref_lookup_census_population_poc2
group by measurement_year


GO


