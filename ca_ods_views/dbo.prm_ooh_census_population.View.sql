USE [CA_ODS]
GO

/****** Object:  View [dbo].[prm_ooh_census_population]    Script Date: 6/25/2014 8:09:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



	 ALTER view  [dbo].[prm_ooh_census_population]
				 as
				 
				 select measurement_year [measurement_year],0 age_grouping_cd,cd_race,pk_gndr,county_cd as county_cd,(pop_cnt)
				 from  CA_ODS.dbo.ref_lookup_census_population  
				union
				--	 age
				select measurement_year [start_year],0 age_grouping_cd,cd_race,pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,pk_gndr,county_cd
				union
				-- race
				select measurement_year [start_year],age_grouping_cd,0 cd_race,pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr,county_cd
				union
				-- gender
				select measurement_year [start_year],age_grouping_cd,cd_race,0 pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,cd_race,county_cd
				union
				-- county
				select measurement_year [start_year],age_grouping_cd,cd_race,pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr,cd_race
				-- age  race  race age
				union 
				select measurement_year [start_year],0 age_grouping_cd,0 cd_race,pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,pk_gndr,county_cd
				union 
				--age ,gender
				select measurement_year [start_year],0 age_grouping_cd,cd_race,0 pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,county_cd
				union 
				--age,county
				select measurement_year [start_year],0 age_grouping_cd,cd_race,pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,cd_race,pk_gndr
				union 
				-- race,gender
				select measurement_year [start_year], age_grouping_cd,0 cd_race,0 pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,county_cd
				union 
				--race,county
				select measurement_year [start_year], age_grouping_cd,0 cd_race,pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,pk_gndr
				-- gender, county
				union
				select measurement_year [start_year],age_grouping_cd,cd_race,0 pk_gndr,0  as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd,cd_race
				union
				--age, race,gender
				select measurement_year [start_year],0 age_grouping_cd,0 cd_race,0 pk_gndr,county_cd as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,county_cd
				union 
				--age,gender,county
				select measurement_year [start_year],0 age_grouping_cd,cd_race,0 pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,cd_race
				union 
				--race,gender,county
				select measurement_year [start_year], age_grouping_cd,0 cd_race,0 pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,age_grouping_cd
				union 
				--	age,race,county
				select measurement_year [start_year],0 age_grouping_cd,0 cd_race,pk_gndr,0 as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year,pk_gndr
				union
				--age,race,gender,county
				select measurement_year [start_year],0 age_grouping_cd,0 cd_race,0 pk_gndr,0  as county_cd,sum(pop_cnt)
				from  CA_ODS.dbo.ref_lookup_census_population  
				group by measurement_year


GO


