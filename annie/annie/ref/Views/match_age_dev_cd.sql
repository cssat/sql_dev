CREATE VIEW [ref].[match_age_dev_cd]
AS
SELECT age_dev_cd
	,age_dev_cd [age_dev_match_code]
FROM ref.lookup_age_dev
WHERE age_dev_cd != 0

UNION ALL

SELECT 0
	,age_dev_cd
FROM ref.lookup_age_dev
WHERE age_dev_cd != 0
