

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_sibling_placement`()
BEGIN
SELECT
	CONVERT(CONCAT(state_fiscal_yyyy, '-07-01'), DATETIME) AS 'Cohort Fical Year'
	,ROUND(prp_some_tgh * 100, 2) AS 'Sibling Placements'
FROM test_annie.sibling_placement;
END$$
DELIMITER ;
