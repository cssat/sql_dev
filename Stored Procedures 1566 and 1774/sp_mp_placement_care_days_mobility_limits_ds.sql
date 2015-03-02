
DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_placement_care_days_mobility_limits_ds`()
BEGIN
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year'
	,old_region_cd AS 'Region'
	,years_in_care AS 'Years in Care'
	,ROUND(movement_rate, 2) AS 'Rate'
FROM test_annie.placement_care_days_mobility_limits_ds;
END$$
DELIMITER ;

