DROP PROCEDURE `test_annie`.`sp_mp_reentries_av`;

DELIMITER $$
CREATE DEFINER=`test_annie` PROCEDURE `sp_mp_reentries_av`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(state_fiscal_yyyy, '-07-01'), DATETIME) AS 'Fiscal Year/Year Exited Out-of-Home Care'
	,old_region_cd AS 'Region'
	,ROUND(per_reent * 100, 2) 'Percent'
FROM test_annie.episode_reentries_av
WHERE state_fiscal_yyyy < 2014;
END$$
DELIMITER ;
