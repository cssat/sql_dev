DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_college_enrollment_pvt`()
BEGIN
SELECT 
	IF(cd_grade != 0, ce.year, ce.year) AS 'Cohort Period'
	,ce.fl_disability
	,MAX(IF(cd_student_type = 1, ROUND(enrollment_percent, 2), NULL)) AS 'Not in Out-of-Home Care'
	,MAX(IF(cd_student_type = 2, ROUND(enrollment_percent, 2), NULL)) AS 'Not in Care: Receiving Free or Reduced-Price Lunch'
	,MAX(IF(cd_student_type = 3, ROUND(enrollment_percent, 2), NULL)) AS 'In Out-of-Home Care'
FROM test_annie.prtl_college_enrollment AS ce
WHERE cd_grade = 1
GROUP By
	ce.year
	,ce.fl_disability
	,cd_grade
ORDER BY 
	ce.year ASC 
	,ce.cd_student_type ASC
	,ce.fl_disability DESC;
END$$
DELIMITER ;
