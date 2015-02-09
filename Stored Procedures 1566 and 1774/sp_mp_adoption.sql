DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_permanency_incidence_adoption_limits`()
BEGIN
SELECT 
	CONVERT(CONCAT(year, '-07-01'), DATETIME)  AS 'Fiscal year'
	,ROUND(adt * 100, 2) AS 'Permanency Incidence'
	,ROUND(lcl * 100, 2) AS  'lcl'
	,ROUND(ucl * 100, 2) AS 'ucl'
FROM test_annie.permanency_incidence_adoption_limits;
END$$
DELIMITER ;
