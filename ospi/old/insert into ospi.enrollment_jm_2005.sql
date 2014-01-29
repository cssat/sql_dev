	    declare @stop_yrMonth int
	    declare @schoolyearend int
	    set @schoolyearend=2005
	    set @stop_yrMonth=@schoolyearend * 100 + 8
		
		declare @loop int
		declare @stoploop int
		declare @maxloop int
		set @loop=1
		set @stoploop=100000
		set @maxloop =2000000


if @schoolyearend=2005
begin
		truncate table ospi.enrollment_temp_jm
		insert into ospi.enrollment_temp_jm (int_researchID 
								, DistrictID 
								, SchoolCode 
								, DateEnrolledInDistrict 
								, DateExitedFromDistrict
								, DateEnrolledInSchool
								, DateExitedFromSchool 
								, EnrollmentStatuS 
								, frst_enr_mnth
								, last_enr_mnth 
								, min_grade_level
								, max_grade_level 
								, schoolyearend
								, int_min_grade
								, int_max_grade
								, fl_delete
								, school_enroll_date
								, school_exit_date)
		select int_researchID 
				, DistrictID 
				, SchoolCode 
				, DateEnrolledInDistrict 
				, DateExitedFromDistrict
				, DateEnrolledInSchool
				, DateExitedFromSchool 
				, EnrollmentStatuS 
				, frst_enr_mnth
				, last_enr_mnth 
				, min_grade_level
				, max_grade_level 
				, @schoolyearend
				, case when isnumeric(min_grade_level)=1 then cast(min_grade_level as int)
						when min_grade_level='PK' then -2
						when min_grade_level='K1' then -1
						when min_grade_level='K2' then 0 end
				, case when isnumeric(max_grade_level)=1 then cast(max_grade_level as int)
						when max_grade_level='PK' then -2
						when max_grade_level='K1' then -1
						when max_grade_level='K2' then 0 end
				, 0
				, DateEnrolledInSchool
				, DateExitedFromSchool
					
						
		from ospi.Enrollment_2005
end
update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool asc ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool

	update statistics ospi.enrollment_temp_jm;
