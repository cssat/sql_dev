CREATE VIEW ref.match_bin_los_cd
AS
SELECT DISTINCT los.bin_los_cd
	,mtch.bin_los_cd [bin_los_match_code]
FROM ref.filter_los mtch
INNER JOIN ref.filter_los los ON mtch.bin_los_cd >= los.bin_los_cd
