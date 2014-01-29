
if object_ID('tempDB..##sameschool') is not null drop table ##sameschool
select q.*
into ##sameschool
from (
		select int_researchID,DistrictID,schoolcode,min(school_enroll_date) as min_school_enroll_date
				,max(school_exit_date) as max_school_exit_date
				,min(frst_enr_mnth) as min_frst_enr_mnth
				,max(last_enr_mnth) as max_last_enr_mnth
				,min(int_min_grade) as int_min_grade
				,max(int_max_grade) as int_max_grade
				,count(*) as school_cnt 
				,cast(null as varchar(2)) as min_grade_level
				,cast(null as varchar(2)) as max_grade_level
				,cast(null as varchar(2)) as EnrollmentStatus
		from ospi.enrollment_temp_jm
		group by  int_researchID,DistrictID,schoolcode ) q
join (
		select int_researchID,count(*) as record_cnt ,count(distinct schoolcode) as cnt_school
		from ospi.enrollment_temp_jm 
		group by int_researchID
		having count(*) > 1) q2
	on q2.int_researchID=q.int_researchID
where school_cnt=record_cnt 
and cnt_school=1
order by q.int_researchID


select * from ##sameschool where EnrollmentStatus is null

update SS
set EnrollmentStatus=enr.EnrollmentStatus
from ##sameschool SS
join ospi.enrollment_temp_jm enr
	on SS.int_researchID=enr.int_researchID
	and ss.schoolcode=enr.schoolcode
	and ss.max_last_enr_mnth=enr.last_enr_mnth

update ##sameschool
set max_grade_level= case when int_max_grade=-2 then 'PK'
		when int_max_grade=  -1 then 'K1'
		when int_max_grade= 0 then 'K2' 
		else cast(int_max_grade as char(2)) end
	,min_grade_level= case when int_min_grade=-2 then 'PK'
		when int_min_grade=  -1 then 'K1'
		when int_min_grade= 0 then 'K2' 
		else cast(int_min_grade as char(2)) end


if object_ID('tempDB..#grade') is not null drop table #grade
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
into #grade
from ospi.ospi_0405 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where primaryschool=1 
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_0506 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where primaryschool=1 
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_0607 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where primaryschool=1 
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_0708 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where primaryschool=1 
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_0809 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where primaryschool=1 
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_0910 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where  DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'
union
select distinct osp.int_ResearchID ,gradelevel,case when isnumeric(gradelevel)=1 then cast(gradelevel as int) when gradelevel='PK' then -2 when gradelevel='K1' then -1 when gradelevel='K2' then 0 end as int_grade_level
from ospi.ospi_1011 osp
join ##sameschool ss on ss.int_researchID=osp.int_researchID and ss.schoolcode=osp.schoolcode
where   DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'



if object_id('tempDB..#cntGrade') is not null drop table #cntGrade
select int_researchID,min(int_grade_level) as int_min_grade,max(int_grade_level) as int_max_grade,count(distinct gradelevel) as cnt_grades
,case when min(int_grade_level) < 0 and max(int_grade_level) > 0
		then abs(min(int_grade_level)) + 1 + max(int_grade_level)
	  when  min(int_grade_level) = 0 and  max(int_grade_level) > 0
		then max(int_grade_level) + 1
	  when  min(int_grade_level) > 0 and max(int_grade_level) > 0
		 then max(int_grade_level) - min(int_grade_level) + 1
	  when min(int_grade_level) < 0 and  max(int_grade_level) <= 0
		then abs( max(int_grade_level)) - abs(min(int_grade_level)) + 1
	  else null end as grades_between_max_min
into #cntGrade  
 from #grade group by int_researchID
 
 select * from #cntGrade where grades_between_max_min=cnt_grades
 order by int_researchID


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
where fl_delete=1
order by int_researchID,row_num

select * from ##sameschool	