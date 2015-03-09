

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_permanency_incidence_av`()
BEGIN
SELECT
	CONVERT(CONCAT(P.state_fiscal_yyyy, '-07-01'), DATETIME)  AS 'Fiscal Year/Removal Year'
	,P.old_region_cd AS 'Region'
	,ROUND(P.perc_perm * 100, 2) AS 'Percent'
FROM test_annie.permanency_incidence_av AS P;

END$$
DELIMITER ;
