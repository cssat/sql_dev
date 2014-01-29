
--select int_ResearchID,schoolcode 
----into ##missing
--from ospi.ospi_0405
--where primaryschool=1
--and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_0506
--where primaryschool=1
--and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_0607
--where primaryschool=1
--and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_0708
--where primaryschool=1
--and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_0809
--where primaryschool=1
--and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_0910
--where primaryschoolflag='Y'
--and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999') and int_researchID=1997
--union
--select int_ResearchID,schoolcode from ospi.ospi_1011
--where primaryschoolflag='Y'
--and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999') and int_researchID=1997
----except
----select int_ResearchID,schoolcode from ospi.enrollment_temp_jm
--order by int_ResearchID,schoolcode
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0405
where primaryschool=1 and int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0506
where primaryschool=1 and int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0607
where primaryschool=1 and int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0708
where primaryschool=1 and int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedFromSchool,gradelevel,enrollmentstatus 
from ospi.ospi_0809
where primaryschool=1 and int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedFromSchool,'12/31/3999')
union
select   int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedSchool,gradelevel,enrollmentstatus from ospi.ospi_0910
where int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'
union
select  int_ResearchID ,[districtCode],schoolcode,DateEnrolledInSchool,DateExitedSchool,gradelevel,enrollmentstatus from ospi.ospi_1011
where  int_researchID=1997
and DateEnrolledInSchool < coalesce(DateExitedSchool,'12/31/3999')
and primaryschoolflag='Y'
order by DateEnrolledInschool

select * from ##missing where  int_researchID=1997