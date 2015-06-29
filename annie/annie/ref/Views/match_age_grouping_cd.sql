CREATE VIEW [ref].[match_age_grouping_cd]
AS
SELECT age_grouping_cd
	,age_grouping_cd [age_grouping_match_code]
FROM ref.lookup_age_grouping
WHERE age_grouping_cd != 0

UNION ALL

SELECT 0
	,age_grouping_cd
FROM ref.lookup_age_grouping
WHERE age_grouping_cd != 0
