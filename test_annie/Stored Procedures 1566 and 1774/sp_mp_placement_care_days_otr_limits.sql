
DROP PROCEDURE `test_annie`.`sp_mp_placement_care_days_otr_limits`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_placement_care_days_otr_limits`(p_date varchar(3000))
BEGIN
SELECT	
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year/Year in Out-of-Home Care'
	,old_region_cd AS 'Region'
	,cd_otr_age AS 'Age'
	,ROUND(otr_rate * 100, 2) AS 'Rate'
FROM test_annie.placement_care_days_otr_limits;

END$$
DELIMITER ;
