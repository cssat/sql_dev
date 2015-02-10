
DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_rate_care_day_maltreatment_limits`()
BEGIN
SELECT
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal Year'
	,old_region_cd AS 'Region'
	,ROUND(care_day_incident_rate, 2) AS 'Incident Rate'
FROM test_annie.rate_care_day_maltreatment_limits;
END$$
DELIMITER ;
