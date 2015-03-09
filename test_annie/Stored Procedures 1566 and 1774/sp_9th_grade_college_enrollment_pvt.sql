DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_9th_grade_college_enrollment_pvt`()
BEGIN
SELECT 
	ce.year AS 'Cohort Period'
	,ce.fl_disability
	,MAX(IF(ce.cd_student_type = 1, ROUND(enrollment_percent, 2), NULL)) AS 'Not in Out-of-Home Care'
	,MAX(IF(ce.cd_student_type = 2, ROUND(enrollment_percent, 2), NULL)) AS 'Not in Care: Receiving Free or Reduced-Price Lunch'
	,MAX(IF(ce.cd_student_type = 3, ROUND(enrollment_percent, 2), NULL)) AS 'In Out-of-Home Care'
	-- ,ROUND(enrollment_percent, 2) AS 'Post-Secondary Enrollment'
FROM prtl_9th_grade_college_enrollment AS ce
	LEFT JOIN ref_lookup_student_type AS st
		ON st.cd_student_type = ce.cd_student_type
-- WHERE find_in_set(ce.cd_student_type, p_cd_student_type) > 0
GROUP BY ce.year
	,ce.fl_disability
ORDER BY 
	ce.year ASC 
	,ce.cd_student_type ASC
	,ce.fl_disability DESC;
END$$
DELIMITER ;
