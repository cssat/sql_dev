
DROP procedure if exists `sp_ar_screened_in`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ar_screened_in`(p_date varchar(3000))
BEGIN

SELECT
	CONVERT(CONCAT(fiscal_year, '-10-01'), DATETIME) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,screened_in_rate AS 'Rate'
FROM test_annie.annual_report_non_cfsr_safety
ORDER BY fiscal_year;

END$$
DELIMITER ;