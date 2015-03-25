USE [CA_ODS]
GO

/****** Object:  View [dbo].[prm_ooh_census_population]    Script Date: 3/25/2015 3:37:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




	 ALTER view  [dbo].[prm_ooh_census_population]
				 as
				 
				select measurement_year,age_grouping_cd,cd_race,pk_gndr,county_cd,pop_cnt
				from dbo.ref_lookup_census_population
				union all
				-- age
				select measurement_year,0 [age_grouping_cd],cd_race,pk_gndr,county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,pk_gndr,county_cd
				union all
				-- race
				select measurement_year,age_grouping_cd,0 [cd_race],pk_gndr,county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr,county_cd
				union all
				-- gender
				select measurement_year,age_grouping_cd,cd_race,0 [pk_gndr],county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,cd_race,county_cd
				union all
				-- county
				select measurement_year,age_grouping_cd,cd_race,pk_gndr,0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr,cd_race
				-- age, race
				union all
				select measurement_year,0 [age_grouping_cd],0 [cd_race],pk_gndr,county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,pk_gndr,county_cd
				union all
				-- age, gender
				select measurement_year,0 [age_grouping_cd],cd_race,0 [pk_gndr],county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,county_cd
				union all
				-- age, county
				select measurement_year,0 [age_grouping_cd],cd_race,pk_gndr,0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,pk_gndr
				union all
				-- race, gender
				select measurement_year,age_grouping_cd,0 [cd_race],0 [pk_gndr],county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,county_cd
				union all
				-- race, county
				select measurement_year,age_grouping_cd,0 [cd_race],pk_gndr,0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr
				-- gender, county
				union all
				select measurement_year,age_grouping_cd,cd_race,0 [pk_gndr],0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,cd_race
				union all
				-- age, race, gender
				select measurement_year,0 [age_grouping_cd],0 [cd_race],0 [pk_gndr],county_cd,sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,county_cd
				union all
				-- age, race, county
				select measurement_year,0 [age_grouping_cd],0 [cd_race],pk_gndr,0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,pk_gndr
				union all
				-- age, gender, county
				select measurement_year,0 [age_grouping_cd],cd_race,0 [pk_gndr],0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,cd_race
				union all
				-- race, gender, county
				select measurement_year,age_grouping_cd,0 [cd_race],0 [pk_gndr],0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd
				union all
				-- age, race, gender, county
				select measurement_year,0 [age_grouping_cd],0 [cd_race],0 [pk_gndr],0 [county_cd],sum(pop_cnt) [pop_cnt]
				from  dbo.ref_lookup_census_population  
				group by measurement_year



GO


