DROP PROCEDURE `test_annie`.`sp_mp_adoption`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_adoption`()
BEGIN
SELECT
	CONVERT(CONCAT(state_fiscal_yyyy, '-07-01'), DATETIME)  AS 'Fiscal Year/Year Child Became Legally Free'
	,old_region_cd AS 'Region'
	,ROUND(perc_adopt * 100, 2) AS 'Percent'
FROM test_annie.permanency_incidence_adoption;
END$$
DELIMITER ;