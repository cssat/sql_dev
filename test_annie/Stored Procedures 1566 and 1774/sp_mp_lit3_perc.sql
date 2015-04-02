

DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_mp_lit3_perc`()
BEGIN

SELECT
	YEAR(lp.year) as 'Grade Year'
	,lp.fl_disability
	,MAX(IF(st.cd_student_type = 1, ROUND(lp.passed, 2), NULL)) AS 'Not in Out-of-Home Care'
	,MAX(IF(st.cd_student_type = 2, ROUND(lp.passed, 2), NULL)) AS 'Not in Care: Receiving Free or Reduced-Price Lunch'
	,MAX(IF(st.cd_student_type = 3, ROUND(lp.passed, 2), NULL)) AS 'In Out-of-Home Care'
FROM prtl_lit3_perc lp
	LEFT JOIN ref_lookup_student_type AS st 
		ON st.cd_student_type = lp.cd_student_type
GROUP BY
	lp.year asc
	,lp.fl_disability desc;
END$$
DELIMITER ;

