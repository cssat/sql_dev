
DROP PROCEDURE `test_annie`.`sp_mp_placement_care_days_mobility_limits_tds`

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_placement_care_days_mobility_limits_tds`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(MAL.fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,MAL.old_region_cd AS 'Region'
	,MAL.years_in_care AS 'Years in Care'
	,cd_movement 
	,ROUND(MAL.movement_rate, 2) AS 'Rate'
FROM test_annie.placement_care_days_mobility_limits_tds AS MAL;
END$$
DELIMITER ;


