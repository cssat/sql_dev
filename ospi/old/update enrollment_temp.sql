--update tmp
--set row_num = curr.row_sort
--from ospi.enrollment_temp  tmp
--join (
----select   nxt.DateEnrolledInSchool,curr.*
--     select *,row_number() over (partition by int_researchID order by int_researchID,DateEnrolledInDistrict) as row_sort
--		from ospi.enrollment_temp
--		) curr on curr.int_researchID=tmp.int_researchID
--			and curr.districtID=tmp.districtID
--			and curr.schoolcode=tmp.schoolcode
--			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
--			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool

--update ospi.enrollment_temp
--set int_min_grade =min_grade_level
--where isnumeric(min_grade_level)=1

--update ospi.enrollment_temp
--set int_min_grade =case when min_grade_level = 'PK' then -2 when min_grade_level='K1' then -1 when min_grade_level='K2' then 0 end
--where int_min_grade is null

--update ospi.enrollment_temp
--set int_max_grade =max_grade_level
--where isnumeric(max_grade_level)=1


--update ospi.enrollment_temp
--set int_max_grade =case when max_grade_level = 'PK' then -2 when max_grade_level='K1' then -1 when max_grade_level='K2' then 0 end
--where int_max_grade is null		

--update ospi.enrollment_temp
--set fl_delete = 0
		
select   nxt.int_researchID,nxt.DistrictID,nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
nxt.min_grade_level,nxt.max_grade_level,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level
from ospi.enrollment_temp curr		
join  ospi.enrollment_temp  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
				and Curr.schoolcode=nxt.schoolcode
				and curr.districtID=nxt.districtID
				and  curr.last_enr_mnth < nxt.frst_enr_mnth
				and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
				and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool

 -- where curr.int_researchID=35
order by curr.int_researchID



update nxt
set fl_delete = 1
from ospi.enrollment_temp curr
join  ospi.enrollment_temp  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
				and Curr.schoolcode=nxt.schoolcode
				and curr.districtID=nxt.districtID
				and  (curr.last_enr_mnth = nxt.frst_enr_mnth
					or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
				and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
				and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool



update curr
set max_grade_level=case when nxt.int_max_grade > curr.int_max_grade then nxt.max_grade_level else curr.max_grade_level end
select  nxt.fl_delete, nxt.int_researchID,nxt.DistrictID,nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
nxt.min_grade_level,nxt.max_grade_level,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level
, last_enr_mnth=nxt.last_enr_mnth
,school_exit_date = nxt.school_exit_date
from ospi.enrollment_temp curr
join  ospi.enrollment_temp  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
				and Curr.schoolcode=nxt.schoolcode
				and curr.districtID=nxt.districtID
				and  (curr.last_enr_mnth = nxt.frst_enr_mnth
					or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
				and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
				and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool
order by curr.int_researchID









