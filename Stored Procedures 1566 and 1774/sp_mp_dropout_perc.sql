
DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_dropout_perc`()
BEGIN

SELECT 
	d.tx_grade AS 'Grade Level'
	,d.cd_student_type - 1 AS 'Student Type'
	,d.cohort_year AS 'Cohort Period'
	,d.fl_disability 
	,d.drop_out_percent AS 'Percent'
FROM test_annie.prtl_dropout AS d
	LEFT JOIN ref_lookup_student_type AS st
		ON st.cd_student_type = d.cd_student_type
ORDER BY 
	CASE d.tx_grade WHEN 'Freshman' THEN 1 WHEN 'Sophomore' THEN 2 WHEN 'Junior' THEN 3 WHEN 'Senior' THEN 4 ELSE 99 END
	,d.cohort_year
	,d.cd_student_type
	,fl_disability;
	
END$$
DELIMITER ;
