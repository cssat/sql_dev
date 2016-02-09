
DROP procedure if exists `sp_ar_cfsr_permanency_re_entry`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ar_cfsr_permanency_re_entry`(p_date varchar(3000))
BEGIN

SELECT
	CONVERT(CONCAT(dat_year, '-10-01'), DATETIME) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,cd_discharge AS 'Discharge Type'
	,re_entry AS 'Percent'
FROM test_annie.annual_report_cfsr_permanency_re_entry
WHERE cd_discharge != 2
	AND cd_discharge IN (0, 1, 5);

END$$
DELIMITER ;

