
DROP PROCEDURE `test_annie`.`sp_mp_permanency_incidence_av`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_permanency_incidence_av`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(year, '-07-01'), DATETIME)  AS 'Fiscal Year/Removal Year'
	,old_region_cd AS 'Region'
	,ROUND(perm * 100, 2) AS 'Percent'
FROM test_annie.mp_permanency_incidence;

END$$
DELIMITER ;
