


if object_ID('tempDB..##frst') is not null drop table ##frst
select int_researchID,min(DateEnrolledInSchool) as DateEnrolledInSchool, cast(null as int) as schoolcode,cast(null as int) as First_ZipCode
, cast(null as int) as firstResidentDistrictID
into ##frst from ospi.temp
group by int_researchID


update frst
set schoolcode=ospi.schoolcode
from 	##frst frst
join ospi.temp ospi on ospi.int_researchID=frst.int_researchID and ospi.DateEnrolledInSchool=frst.DateEnrolledInSchool		



update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode 
							when ResidentDistrictCode =0 then  DistrictCode 
							else firstResidentDistrictID end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0405  mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q
			
	

update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0506 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null	

update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0607 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null	
	
update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0708 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null			

update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0809 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null	

update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 and charindex('.',q.zipcode) = 0 then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0910 mn
			where  primaryschoolflag='Y'
			and isnull(DateExitedSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null	

update frst
set First_ZipCode=case when isnumeric(q.zipcode)=1 and charindex('.',q.zipcode) = 0  then q.zipcode else null end
	,firstResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##frst frst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_1011 mn
			where  primaryschoolflag='Y'
			and isnull(DateExitedSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=frst.int_researchID
			and mn.DateEnrolledInSchool=frst.DateEnrolledInSchool
			and mn.schoolcode=frst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	firstResidentDistrictID is null	




	
	--------------------------------------------------------------------------------  LAST
	
if object_ID('tempDB..##last') is not null drop table ##last
select int_researchID,max(DateEnrolledInSchool) as DateEnrolledInSchool, cast(null as int) as schoolcode
	,cast(null as int) as last_ZipCode
, cast(null as int) as lastResidentDistrictID
into ##last from ospi.temp
group by int_researchID


update lst
set schoolcode=ospi.schoolcode
from 	##last lst
join ospi.temp ospi on ospi.int_researchID=lst.int_researchID and ospi.DateEnrolledInSchool=lst.DateEnrolledInSchool		


update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 and charindex('.',q.zipcode) = 0  then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_1011 mn
			where  primaryschoolflag='Y'
			and isnull(DateExitedSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	lastResidentDistrictID is null		
go
update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 and charindex('.',q.zipcode) = 0 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0910 mn
			where  primaryschoolflag='Y'
			and isnull(DateExitedSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			and lst.lastResidentDistrictID is null	 
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	

go

update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0809 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			and lst.lastResidentDistrictID is null
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
			
go


update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0708 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			and lst.lastResidentDistrictID is null	
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
 			
go

update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0607 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			and lst.lastResidentDistrictID is null	
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
	
go	
			
	

update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode else DistrictCode end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0506 mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q	
where 	lastResidentDistrictID is null	
go
update lst
set last_ZipCode=case when isnumeric(q.zipcode)=1 then q.zipcode else null end
	,lastResidentDistrictID=case when ResidentDistrictCode <> 0  
							then ResidentDistrictCode 
							else   DistrictCode  end
from ##last lst
cross apply (select top 1 mn.int_researchID
				,mn.DateEnrolledInSchool
				,mn.zipcode
				,isnull(ResidentDistrictCode,0) as ResidentDistrictCode
				, mn.DistrictCode
				, mn.schoolcode 
			from ospi.ospi_0405  mn
			where  primaryschool=1
			and isnull(DateExitedFromSchool,'12/31/3999' ) > mn.DateEnrolledInSchool
			and mn.int_researchID=lst.int_researchID
			and mn.DateEnrolledInSchool=lst.DateEnrolledInSchool
			and mn.schoolcode=lst.schoolcode
			order by mn.int_researchID,isnull(ResidentDistrictCode,0) desc
			) q
where 	lastResidentDistrictID is null	
go

update ospi
set firstResidentDistrictID=frst.firstResidentDistrictID
	,first_zipcode=frst.first_zipcode
from  ospi.temp ospi
join ##frst frst on frst.int_researchID=ospi.int_researchID

update ospi.temp
set first_zipcode=0
where first_zipcode is null


update ospi
set lastResidentDistrictID=lst.lastResidentDistrictID
	,last_zipcode=isnull(lst.last_zipcode,0)
from  ospi.temp ospi
join ##last lst on lst.int_researchID=ospi.int_researchID


--- QA
--select *
--from ospi.temp
--join (
--	select int_researchID,count(distinct firstResidentDistrictID) as cnt
--	from ospi.temp
--	group by int_researchID
--	having count(distinct firstResidentDistrictID)  > 1
--	) q on q.int_researchID=ospi.temp.int_researchID
	
--select *
--from ospi.temp
--join (
--	select int_researchID,count(distinct lastResidentDistrictID) as cnt
--	from ospi.temp
--	group by int_researchID
--	having count(distinct lastResidentDistrictID)  > 1
--	) q on q.int_researchID=ospi.temp.int_researchID	


select * into ospi.temp_thru_5 from ospi.temp


truncate table ospi.temp
insert into ospi.temp
select * from ospi.temp_thru_5