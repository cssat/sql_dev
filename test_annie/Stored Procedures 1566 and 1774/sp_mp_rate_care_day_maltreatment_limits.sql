DROP PROCEDURE `test_annie`.`sp_mp_rate_care_day_maltreatment_limits`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_rate_care_day_maltreatment_limits`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year'
	,old_region_cd AS 'Region'
	,ROUND(care_day_incident_rate, 2) AS 'Rate'
FROM test_annie.rate_care_day_maltreatment_limits;
END$$
DELIMITER ;

