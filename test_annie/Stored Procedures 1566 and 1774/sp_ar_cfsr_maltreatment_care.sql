
DROP procedure if exists `sp_ar_cfsr_maltreatment_care`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ar_cfsr_maltreatment_care`(p_date varchar(3000))
BEGIN

SELECT 
	CONVERT(CONCAT(dat_year, '-10-01'), DATETIME) AS 'Fiscal Year'
	,maltreatment_in_care AS 'Rate'
FROM test_annie.annual_report_cfsr_safety;

END$$
DELIMITER ;

