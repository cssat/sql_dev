/*
DECLARE @age_grouping_cd VARCHAR(30)
	,@race_cd VARCHAR(30)
	,@cd_county VARCHAR(1000)
	,@cd_reporter_type VARCHAR(100)
	,@cd_access_type VARCHAR(30)
	,@cd_allegation VARCHAR(30)
	,@cd_finding VARCHAR(30)

SELECT TOP 1 @age_grouping_cd = age_grouping_cd
	,@race_cd = cd_race_census
	,@cd_county = cd_county
	,@cd_reporter_type = cd_reporter_type
	,@cd_access_type = filter_access_type
	,@cd_allegation = filter_allegation
	,@cd_finding = filter_finding
FROM ca_ods.prtl.cache_poc2ab_params c
WHERE NOT EXISTS (
		SELECT *
		FROM prtl.ia_trends_params p
		WHERE p.age_grouping_cd = c.age_grouping_cd
			AND p.cd_race_census = c.cd_race_census
			AND p.cd_county = c.cd_county
			AND p.cd_reporter_type = c.cd_reporter_type
			AND p.cd_access_type = c.filter_access_type
			AND p.cd_allegation = c.filter_allegation
			AND p.cd_finding = c.filter_finding
		)

SELECT @age_grouping_cd [age_grouping_cd]
	,@race_cd [cd_race_census]
	,@cd_county [cd_county]
	,@cd_reporter_type [cd_reporter_type]
	,@cd_access_type [cd_access_type]
	,@cd_allegation [cd_allegation]
	,@cd_finding [cd_finding]

IF @age_grouping_cd IS NOT NULL
BEGIN
	--EXEC ca_ods.prtl.sp_ia_trends_counts @age_grouping_cd, @race_cd, @cd_county, @cd_reporter_type, @cd_access_type, @cd_allegation, @cd_finding
	EXEC prtl.sp_ia_trends_counts @age_grouping_cd, @race_cd, @cd_county, @cd_reporter_type, @cd_access_type, @cd_allegation, @cd_finding
	EXEC prtl.sp_ia_trends_rates '', @age_grouping_cd, @race_cd, @cd_county, @cd_reporter_type, @cd_access_type, @cd_allegation, @cd_finding
END
--*/
--TRUNCATE TABLE prtl.ia_trends_params
--EXEC prtl.build_ia_trends_cache

CREATE PROCEDURE [ref].[import_match_census_population]
AS
TRUNCATE TABLE ref.match_census_population

INSERT ref.match_census_population (
	measurement_year
	,age_grouping_cd
	,pk_gender
	,cd_race_census
	,cd_county
	,population_count
	,perCapita_threshold
	)
SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race
	,county_cd
	,pop_cnt
	,pop_cnt * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,pk_gndr
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr
	,cd_race

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,cd_race
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_race
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,pk_gndr
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,pk_gndr
	,cd_race

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,county_cd

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
GROUP BY measurement_year
	,age_grouping_cd
	,cd_race

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,pk_gndr
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd
	,pk_gndr

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,0 [cd_race]
	,county_cd
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,county_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,cd_race
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,cd_race

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,pk_gndr
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,pk_gndr

UNION ALL

SELECT measurement_year
	,age_grouping_cd
	,0 [pk_gndr]
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
	,age_grouping_cd

UNION ALL

SELECT measurement_year
	,0 [age_grouping_cd]
	,0 [pk_gndr]
	,0 [cd_race]
	,0 [county_cd]
	,SUM(pop_cnt) [pop_cnt]
	,SUM(pop_cnt) * .35 [perCapita_threshold]
FROM ca_ods.public_data.census_population
WHERE cd_race <= 8
GROUP BY measurement_year
GO
