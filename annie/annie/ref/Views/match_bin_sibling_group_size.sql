CREATE VIEW [ref].[match_bin_sibling_group_size]
AS 
SELECT bin_sibling_group_size
	,bin_sibling_group_size [sibling_group_size_match_code]
FROM ref.lookup_sibling_groups
WHERE bin_sibling_group_size != 0

UNION ALL

SELECT 0 [bin_sibling_group_size]
	,bin_sibling_group_size [sibling_group_size_match_code]
FROM ref.lookup_sibling_groups
WHERE bin_sibling_group_size != 0
