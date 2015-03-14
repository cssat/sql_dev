
DROP PROCEDURE `test_annie`.`sp_mp_post_secondary_completion_pvt`;

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_post_secondary_completion_pvt`()
BEGIN
SELECT 
	cc.year  AS 'Cohort Period'
	,MAX(IF(cc.cd_student_type = 1, ROUND(cc.percent_completed_degree, 2), NULL)) AS 'Not in Out-of-Home Care'
	,MAX(IF(cc.cd_student_type = 2, ROUND(cc.percent_completed_degree, 2), NULL)) AS 'Not in Care: Receiving Free or Reduced-Price Lunch'
	,MAX(IF(cc.cd_student_type = 3, ROUND(cc.percent_completed_degree, 2), NULL)) AS 'In Out-of-Home Care'
FROM test_annie.prtl_post_secondary_completion AS cc
	LEFT JOIN ref_lookup_student_type AS st
		ON st.cd_student_type = cc.cd_student_type
ORDER BY 
	cc.year ASC 
	,cc.cd_student_type ASC;
END$$
DELIMITER ;
