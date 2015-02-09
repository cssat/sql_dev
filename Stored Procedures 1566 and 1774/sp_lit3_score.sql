DELIMITER $$
CREATE DEFINER=`test_annie`@`localhost` PROCEDURE `sp_lit3_score`(p_date varchar(3000), p_cd_student_type varchar(200))
BEGIN
select
	ls.year as 'Cohort Period'
	,ls.cd_student_type
	,st.tx_student_type as 'Student Type'
	,ls.fl_disability
	,ls.i0
	,ls.i1
	,ls.mean_test_score as 'Mean Test Score'
from prtl_lit3_score ls
left join ref_lookup_student_type st on
	st.cd_student_type = ls.cd_student_type
where find_in_set(ls.cd_student_type,p_cd_student_type)>0
order by
	ls.year asc
	,ls.cd_student_type asc
	,ls.fl_disability desc;
END$$
DELIMITER ;
