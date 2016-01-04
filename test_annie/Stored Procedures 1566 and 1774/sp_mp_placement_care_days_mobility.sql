
DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_mp_placement_care_days_mobility`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,old_region_cd AS 'Region'
	,years_in_care AS 'Years in Care'
	,0 AS cd_movement
	,ROUND(movement_rate, 2) AS 'Rate'
FROM placement_care_days_mobility_limits_ds
UNION ALL 
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,old_region_cd AS 'Region'
	,years_in_care AS 'Years in Care'
	,cd_movement + 1 AS cd_movement
	,ROUND(movement_rate, 2) AS 'Rate'
FROM placement_care_days_mobility_limits_tds AS MAL;
END$$
DELIMITER ;


