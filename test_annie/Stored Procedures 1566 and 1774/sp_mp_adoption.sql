DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_adoption`()
BEGIN
SELECT
	CONVERT(CONCAT(P.state_fiscal_yyyy, '-07-01'), DATETIME)  AS 'Fiscal Year/Year Child Became Legally Free'
	,P.old_region_cd AS 'Region'
	,ROUND(P.perc_adopt * 100, 2) AS 'Percent'
FROM test_annie.permanency_incidence_adoption AS P
	JOIN ref_lookup_region AS LC
		ON P.old_region_cd = LC.old_region_cd;
END$$
DELIMITER ;