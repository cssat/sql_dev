

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_adult_readiness`()
BEGIN
SELECT 
	CONVERT(CONCAT(cohort_fy, '-07-01'), DATETIME) AS 'Fiscal Year/Year Youth >17.5 Years Old'
	,cd_region AS 'Region'
	,ROUND(prp_kids_with_plans * 100, 2) AS 'Percent'
FROM test_annie.adult_readiness;
END$$
DELIMITER ;


