

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_reentries_av`()
BEGIN
SELECT
	CONVERT(CONCAT(state_fiscal_yyyy, '-07-01'), DATETIME) AS 'Fiscal Year'
	,old_region_cd AS 'Region'
	,ROUND(per_reent * 100, 2) 'Percent Reentered'
FROM test_annie.episode_reentries_av;
END$$
DELIMITER ;