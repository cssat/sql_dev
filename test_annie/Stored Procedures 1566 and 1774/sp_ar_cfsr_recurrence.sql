DROP procedure if exists `sp_ar_cfsr_recurrence`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`%` PROCEDURE `sp_ar_cfsr_recurrence`(p_date varchar(3000))
BEGIN

SELECT 
	CONVERT(CONCAT(dat_year, '-10-01'), DATETIME) AS 'Fiscal Year'
	,recurrence_of_maltreatment AS 'Percent'
FROM test_annie.annual_report_cfsr_safety;

END$$
DELIMITER ;
