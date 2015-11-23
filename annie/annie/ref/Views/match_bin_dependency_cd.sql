CREATE VIEW [ref].[match_bin_dependency_cd]
AS
SELECT bin_dependency_cd
	,bin_dependency_cd [bin_dependency_match_code]
FROM ref.filter_dependency
WHERE bin_dependency_cd != 0

UNION ALL

SELECT 0 [bin_dependency_cd]
	,bin_dependency_cd [bin_dependency_match_code]
FROM ref.filter_dependency
WHERE bin_dependency_cd != 0
