
DROP procedure if exists `sp_ar_cfsr_permanency_exits`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ar_cfsr_permanency_exits`(p_date varchar(3000))
BEGIN

SELECT
	CONVERT(CONCAT(dat_year, '-10-01'), DATETIME) AS 'Fiscal Year'
	,region AS 'Region'
	,sex AS 'Sex'
	,race AS 'Race'
	,age_cat AS 'Age Category'
	,cd_discharge AS 'Discharge Type'
	,time_period
	,percent
FROM test_annie.annual_report_cfsr_permanency_exits
WHERE cd_discharge != 2;

END$$
DELIMITER ;

