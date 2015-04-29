USE [CA_ODS]
GO

/****** Object:  View [dbo].[prm_household_census_population]    Script Date: 8/21/2014 2:07:39 PM ******/
DROP VIEW [dbo].[prm_household_census_population]
GO

/****** Object:  View [dbo].[prm_household_census_population]    Script Date: 8/21/2014 2:07:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[prm_household_census_population]
as
select  measurement_year,cd_sib_age_grp,cd_race,county_cd,pop_cnt
 from dbCoreAdministrativeTables.public_data.census_population_household
 union
select measurement_year,0 cd_sib_age_grp,cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
group by measurement_year,cd_race,county_cd
 union
select measurement_year,cd_sib_age_grp,0 cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
where cd_race <=8
group by measurement_year,cd_sib_age_grp,county_cd
 union
select measurement_year,cd_sib_age_grp, cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
group by measurement_year,cd_sib_age_grp,cd_race
union
select measurement_year,0 cd_sib_age_grp,0 cd_race,county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
where cd_race <=8
group by measurement_year, county_cd
union
select measurement_year,0 cd_sib_age_grp,cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
group by measurement_year, cd_race
union
select measurement_year,cd_sib_age_grp ,0 cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
where cd_race <=8
group by measurement_year, cd_sib_age_grp
union
select measurement_year,0 cd_sib_age_grp ,0 cd_race,0 county_cd,sum(pop_cnt) [pop_cnt]
from dbCoreAdministrativeTables.public_data.census_population_household
where cd_race <=8
group by measurement_year



GO


