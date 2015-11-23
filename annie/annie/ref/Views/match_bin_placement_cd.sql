CREATE VIEW [ref].[match_bin_placement_cd]
AS
SELECT bin_placement_cd
	,bin_placement_cd [bin_placement_match_code]
FROM ref.filter_nbr_placement flt
WHERE bin_placement_cd != 0

UNION ALL

SELECT 0 [bin_placement_cd]
	,bin_placement_cd [bin_placement_match_code]
FROM ref.filter_nbr_placement
WHERE bin_placement_cd != 0
