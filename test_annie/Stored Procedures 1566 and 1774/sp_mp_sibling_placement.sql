

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_mp_sibling_placement`(p_date varchar(3000))
BEGIN
SELECT
	CONVERT(CONCAT(state_fiscal_yyyy, '-07-01'), DATETIME) AS 'Fiscal Year/Year Children Placed'
	,ROUND(prp_some_tgh * 100, 2) AS 'Percent'
FROM test_annie.sibling_placement;
END$$
DELIMITER ;

