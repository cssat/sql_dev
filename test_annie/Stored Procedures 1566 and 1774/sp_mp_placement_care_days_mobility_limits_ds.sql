
DROP PROCEDURE `test_annie`.`sp_mp_placement_care_days_mobility_limits_ds`

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_placement_care_days_mobility_limits_ds`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,old_region_cd AS 'Region'
	,years_in_care AS 'Years in Care'
	,ROUND(movement_rate, 2) AS 'Rate'
FROM test_annie.placement_care_days_mobility_limits_ds;
END$$
DELIMITER ;

