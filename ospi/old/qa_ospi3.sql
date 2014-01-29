--select row_number() over (partition by int_researchID
--					order by int_researchID,DateEnrolledInSchool,DateExitedFromSchool) as row_num,* from ospi.enrollment_2005
					
--select * from ospi.Enrollment_YE2005_thru_YE2009 where int_researchID=129
--select * from ospi.enrollment_temp_jm where int_researchID=129	order by DateEnrolledInSchool
--select * from ospi.enrollment_temp_jm where int_researchID=129	order by DateEnrolledInSchool			
--select * from ospi.ospi_1011 where int_researchID=129 order by DateEnrolledInSchool
--select * from ospi.ospi_0910 where int_researchID=129 order by DateEnrolledInSchool


--select * from ospi.school_dim
--where schoolcode in (
--select  schoolcode from ospi.enrollment_2005 
--except
--select schoolcode from ospi.school_dim where schooltype is not null)

--select max(schoolyearend) from ospi.enrollment_temp_jm 
/**
truncate table ospi.enrollment_temp_jm
insert into ospi.enrollment_temp_jm  select * from ospi.enrollment_YE2005_thru_YE2009

update 	ospi.enrollment_YE2005_thru_YE2009
set int_max_grade=   cast(max_grade_level as int) 
where isnumeric(max_grade_level) =1 and cast(max_grade_level as int)<>int_max_grade


update 	ospi.enrollment_YE2005_thru_YE2009 
set int_min_grade=   cast(min_grade_level as int) 
where isnumeric(min_grade_level) =1 and cast(min_grade_level as int)<>int_min_grade



update ospi.enrollment_YE2005_thru_YE2009 
set int_max_grade=   case when max_grade_level='PK' then -2
		when max_grade_level='K1' then -1
		when max_grade_level='K2' then 0 end 
where isnumeric(max_grade_level) =0
and int_max_grade <> case when max_grade_level='PK' then -2
		when max_grade_level='K1' then -1
		when max_grade_level='K2' then 0 end 
		
		
update ospi.enrollment_YE2005_thru_YE2009 
set int_min_grade=   case when min_grade_level='PK' then -2
		when min_grade_level='K1' then -1
		when min_grade_level='K2' then 0 end 
where isnumeric(min_grade_level) =0
and int_min_grade <> case when min_grade_level='PK' then -2
		when min_grade_level='K1' then -1
		when min_grade_level='K2' then 0 end 			

**/

select ospi.enrollment_temp_jm.int_researchID
      ,[districtID]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[school_enroll_date]
      ,[school_exit_date]
      ,[EnrollmentStatuS]
      ,[min_grade_level]
      ,[max_grade_level]
       ,[int_min_grade]
      ,[int_max_grade]
      ,row_num
      ,frst_enr_mnth
      ,last_enr_mnth
from ospi.enrollment_temp_jm	
--join (select distinct int_researchID from ospi.enrollment_temp_jm where enrollmentstatus='FE') q 
--on q.int_researchID=ospi.enrollment_temp_jm.int_researchID
where ospi.enrollment_temp_jm.int_researchID=129
order by  int_researchID, row_num	




select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0405
where primaryschool=1 and int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0506
where primaryschool=1 and int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0607
where primaryschool=1 and int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0708
where primaryschool=1 and int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0809
where primaryschool=1 and int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select   int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0910
where int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'
union
select  int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedSchool,gradelevel,enrollmentstatus 
from ospi.ospi_1011
where  int_researchID=129
and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'
order by DateEnrolledInschool



