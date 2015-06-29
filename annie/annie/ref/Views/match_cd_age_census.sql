CREATE VIEW [ref].[match_age_census_cd]
AS
SELECT age_census_cd
	,age_census_cd [age_census_match_code]
FROM ref.lookup_age_census
WHERE age_census_cd != 0

UNION ALL

SELECT 0
	,age_census_cd
FROM ref.lookup_age_census
WHERE age_census_cd != 0
