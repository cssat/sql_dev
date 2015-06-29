CREATE VIEW [ref].[match_age_sib_group_cd]
AS
SELECT age_sib_group_cd
	,age_sib_group_cd [age_sib_group_match_code]
FROM ref.lookup_age_sib_group age
WHERE age_sib_group_cd != 0

UNION ALL

SELECT 0
	,age_sib_group_cd
FROM ref.lookup_age_sib_group age
WHERE age_sib_group_cd != 0
