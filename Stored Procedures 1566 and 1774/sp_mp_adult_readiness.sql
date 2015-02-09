

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_adult_readiness`()
BEGIN
SELECT 
	CONVERT(CONCAT(cohort_fy, '-07-01'), DATETIME) AS 'Cohort Fiscal Year'
	,cd_region AS 'Region'
	,ROUND(prp_kids_with_plans * 100, 2) AS 'Proportion of Youth with Plans'
FROM test_annie.adult_readiness;
END$$
DELIMITER ;

