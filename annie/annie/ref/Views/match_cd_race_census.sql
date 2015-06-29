CREATE VIEW [ref].[match_cd_race_census]
AS
SELECT DISTINCT cd_race_census
	,cd_race_census [race_census_match_code]
FROM ref.lookup_ethnicity_census
WHERE cd_race_census BETWEEN 1 AND 8

UNION

SELECT 0
	,cd_race_census
FROM ref.lookup_ethnicity_census
WHERE cd_race_census BETWEEN 1 AND 8
