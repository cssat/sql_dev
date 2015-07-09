CREATE VIEW [ref].[match_cd_race_census]
AS
SELECT DISTINCT cd_race_census
	,cd_race_census [race_census_match_code]
FROM ref.lookup_ethnicity_census
WHERE cd_race_census BETWEEN 1 AND 8

UNION ALL

SELECT 0
	,cd_race_census
FROM ref.lookup_ethnicity_census
WHERE cd_race_census BETWEEN 1 AND 8

UNION ALL

SELECT 9
    ,cd_race_census
FROM ref.lookup_ethnicity_census
WHERE cd_race_census BETWEEN 1 AND 8

UNION ALL

SELECT 10
    ,cd_race_census
FROM ref.lookup_ethnicity_census
WHERE cd_race_census IN (1, 2, 4, 6, 7, 8) 

UNION ALL

SELECT 11
    ,5

UNION ALL

SELECT 12
    ,3
