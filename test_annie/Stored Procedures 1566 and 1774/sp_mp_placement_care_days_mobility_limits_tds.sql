
DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_placement_care_days_mobility_limits_tds`()
BEGIN
SELECT
	CONVERT(CONCAT(MAL.fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,MAL.old_region_cd AS 'Region'
	,MAL.years_in_care AS 'Years in Care'
	,cd_movement 
	,ROUND(MAL.movement_rate, 2) AS 'Rate'
FROM test_annie.placement_care_days_mobility_limits_tds AS MAL;
	-- JOIN ref_lookup_region AS LC
		-- ON MAL.old_region_cd = LC.old_region_cd
	-- JOIN ref_lookup_years_in_care AS C
		-- ON MAL.years_in_care = C.cd_years_in_care;
END$$
DELIMITER ;
