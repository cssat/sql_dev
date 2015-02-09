

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_placement_care_days_otr_limits`()
BEGIN
SELECT	
	CONVERT(CONCAT(fiscal_yr, '-07-01'), DATETIME)  AS 'Fiscal year'
	,old_region_cd AS 'Region'
	,cd_otr_age AS 'Age'
	,ROUND(otr_rate * 100, 2) AS 'Days OTR'
FROM test_annie.placement_care_days_otr_limits;

END$$
DELIMITER ;
