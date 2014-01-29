--78840  --993219 --
select p.* from ospi.enrollment_2005 p
--join (
--select int_researchID,count(*) as cnt from ####myTbl group by int_researchID having count(*) > 1
----order by count(*) desc
--) q on q.int_researchID=p.int_researchID
where p.int_researchID=78840
order by schoolCode,DateEnrolledInSchool,int_researchID



select int_researchID
	,primaryschool
	,districtcode
	,schoolcode
	,DateEnrolledInDistrict
	,DateExitedFromDistrict
	,DateEnrolledInSchool
	,DateExitedFromSchool
	,enrollmentstatus
	,yrmonth
	,GradeLevel
	,collectionperiod
from ospi.ospi_0405 
where int_researchID=317414 
and primaryschool=1 and isnull(DateExitedFromDistrict,'12/31/3999') > DateEnrolledInDistrict
union
select int_researchID
	,primaryschool
	,districtcode
	,schoolcode
	,DateEnrolledInDistrict
	,DateExitedFromDistrict
	,DateEnrolledInSchool
	,DateExitedFromSchool
	,enrollmentstatus
	,yrmonth
	,GradeLevel
	,collectionperiod
from ospi.ospi_0506
where int_researchID=317414
and primaryschool=1 and isnull(DateExitedFromDistrict,'12/31/3999') > DateEnrolledInDistrict
union
select int_researchID
	,primaryschool
	,districtcode
	,schoolcode
	,DateEnrolledInDistrict
	,DateExitedFromDistrict
	,DateEnrolledInSchool
	,DateExitedFromSchool
	,enrollmentstatus
	,yrmonth
	,GradeLevel
	,collectionperiod
from ospi.ospi_0607
where int_researchID=317414
 -- 78840--993219 
and primaryschool=1 and isnull(DateExitedFromDistrict,'12/31/3999') > DateEnrolledInDistrict
union
select int_researchID
	,primaryschool
	,districtcode
	,schoolcode
	,DateEnrolledInDistrict
	,DateExitedFromDistrict
	,DateEnrolledInSchool
	,DateExitedFromSchool
	,enrollmentstatus
	,yrmonth
	,GradeLevel
	,collectionperiod
from ospi.ospi_0708
where int_researchID=317414
  --78840--993219 
and primaryschool=1 and isnull(DateExitedFromDistrict,'12/31/3999') > DateEnrolledInDistrict
union
select int_researchID
	,primaryschool
	,districtcode
	,schoolcode
	,DateEnrolledInDistrict
	,DateExitedFromDistrict
	,DateEnrolledInSchool
	,DateExitedFromSchool
	,enrollmentstatus
	,yrmonth
	,GradeLevel
	,collectionperiod
from ospi.ospi_0809
where int_researchID=317414

  --78840--993219 
and primaryschool=1 and isnull(DateExitedFromDistrict,'12/31/3999') > DateEnrolledInDistrict
order by yrmonth,DateEnrolledInSchool,schoolcode


select * from ospi.enrollment_temp_jm where school_exit_date='12/31/3999' and last_enr_mnth between 200409 and 200508


select count(*) from ospi.temp
select count(*) from ospi.Enrollment_2006


select osp.*
from ospi.Enrollment_2006 osp
join (
select int_researchID,schoolcode from ospi.temp
except
select int_researchID,schoolcode from ospi.Enrollment_2006 ) q on q.int_researchID=osp.int_researchID
order by osp.int_researchID,osp.DateEnrolledInSchool

select osp.* from ospi.Enrollment_2006 osp
join (
	select int_researchID,schoolcode,DateEnrolledInSchool from ospi.Enrollment_2006
	except
	select int_researchID,schoolcode,DateEnrolledInSchool from ospi.temp ) q on q.int_researchID=osp.int_researchID
where osp.int_researchID=q.int_researchID
order by osp.int_researchID,osp.DateEnrolledInSchool

select * from ospi.ospi_0506 where int_researchID=23600
 and DateEnrolledInSchool='2005-09-06 00:00:00.000'

select top 100  * from ospi.enrollment_2009