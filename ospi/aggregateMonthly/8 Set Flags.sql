-- MANUAL LOOP IN THIS SCRIPT (DISTRICTS) repeat until 0 rows updated commented with repeat

--------------------------------------------------------------------------MIGRANT WORKERS
if object_ID('tempDB..#migrant') is not null drop table #migrant
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,migrant as fl_migrant
into #migrant
from ospi.ospi_0405 where migrant=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),migrant as fl_migrant
from ospi.ospi_0506 where migrant=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),migrant as fl_migrant
from ospi.ospi_0607 where migrant=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),migrant as fl_migrant
from ospi.ospi_0708 where migrant=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),migrant as fl_migrant
from ospi.ospi_0809 where migrant=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_migrant
from ospi.ospi_0910 where migrantflag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_migrant
from ospi.ospi_1011 where migrantflag='Y'




update osp
set osp.fl_migrant=m.fl_migrant
from ospi.temp osp
join #migrant m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

	
go	
--------------------------------------------------------------------------homeBased
if object_ID('tempDB..#homeBased') is not null drop table #homeBased
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,1 as fl_homeBased
into #homeBased
from ospi.ospi_0405 where  IsHomeBasedStudentAttendingPartTime=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_0506 where  IsHomeBasedStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_0607 where  IsHomeBasedStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_0708 where  IsHomeBasedStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_0809 where  IsHomeBasedStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_0910 where  HomeBasedAttendPartTimeFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_homeBased
from ospi.ospi_1011 where  HomeBasedAttendPartTimeFlag='Y'


update osp
set osp.fl_homeBased=m.fl_homeBased
from ospi.temp osp
join #homeBased m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

	
go
--------------------------------------------------------------------------privateSchool
--loh
if object_ID('tempDB..#privateSchool') is not null drop table #privateSchool
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,1 as fl_privateSchool
into #privateSchool
from ospi.ospi_0405 where  IsApprovedPrivateSchoolStudentAttendingPartTime=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_0506 where  IsApprovedPrivateSchoolStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_0607 where  IsApprovedPrivateSchoolStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_0708 where  IsApprovedPrivateSchoolStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_0809 where  IsApprovedPrivateSchoolStudentAttendingPartTime=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_0910 where  ApprvdPrivateSchoolAttendPartTimeFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_privateSchool
from ospi.ospi_1011 where  ApprvdPrivateSchoolAttendPartTimeFlag='Y'


update osp
set osp.fl_privateSchool=m.fl_privateSchool
from ospi.temp osp
join #privateSchool m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

	
go
--------------------------------------------------------------------------HomeLess
if object_ID('tempDB..#HomeLess') is not null drop table #HomeLess
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,1 as fl_HomeLess
into #HomeLess
from ospi.ospi_0405 where  HomeLess=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_0506 where  HomeLess=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_0607 where  HomeLess=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_0708 where  HomeLess=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_0809 where  HomeLess=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_0910 where  HomeLessFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_HomeLess
from ospi.ospi_1011 where  HomeLessFlag='Y'

update osp
set osp.fl_HomeLess=m.fl_HomeLess
from ospi.temp osp
join #HomeLess m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

	
go

--------------------------------------------------------------------------Section 504

if object_ID('tempDB..#504') is not null drop table #504
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') 
as DateExitedFromSchool,1 as fl_504
into #504
from ospi.ospi_0405 where  Section504=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_0506 where  Section504=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_0607 where  Section504=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_0708 where  Section504=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_0809 where  Section504=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_0910 where  v504Flag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_504
from ospi.ospi_1011 where  v504Flag='Y'



update osp
set osp.fl_504=m.fl_504
from ospi.temp osp
join #504 m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

	
go

--------------------------------------------------------------------------foreign exchange
if object_ID('tempDB..#foreign') is not null drop table #foreign
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,1 as fl_foreignExch
into #foreign
from ospi.ospi_0405 where  IsForeignExchangeStudent=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_0506 where  IsForeignExchangeStudent=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_0607 where  IsForeignExchangeStudent=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_0708 where  IsForeignExchangeStudent=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_0809 where  IsForeignExchangeStudent=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_0910 where  F1VisaForeignExchgFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_foreignExch
from ospi.ospi_1011 where  F1VisaForeignExchgFlag='Y'

update osp
set osp.fl_foreignExch=m.fl_foreignExch
from ospi.temp osp
join #foreign m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool

--------------------------------------------------------------------------fl_specialEd

if object_ID('tempDB..#specEd') is not null drop table #specEd
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool,1 as fl_specialEd
into #specEd
from ospi.ospi_0405 where  SpecialEd=1
union 
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_0506 where  SpecialEd=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_0607 where  SpecialEd=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_0708 where  SpecialEd=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedFromSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_0809 where  SpecialEd=1
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_0910 where  SpecialEdFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_specialEd
from ospi.ospi_1011 where  SpecialEdFlag='Y'

update osp
set osp.fl_specialEd=m.fl_specialEd
from ospi.temp osp
join #specEd m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedFromSchool >=osp.DateEnrolledInSchool
go
--------------------------------------------------------------------------2010 2011 foster care

if object_ID('tempDB..#foster') is not null drop table #foster

select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999') as DateExitedSchool,1 as fl_fostercare_1011
into #foster
from ospi.ospi_0910 where  FosterCareFlag='Y'
union
select int_researchID,districtCode,schoolcode,DateEnrolledInSchool,isnull(DateExitedSchool,'12/31/3999'),1 as fl_fostercare_1011
from ospi.ospi_1011 where  FosterCareFlag='Y'



update osp
set osp.fl_fostercare_1011=m.fl_fostercare_1011
from ospi.temp osp
join #foster m on m.int_researchID=osp.int_researchID
	and m.districtcode=osp.districtID
	and m.schoolcode=osp.schoolcode
	and m.DateEnrolledInSchool<=osp.DateExitedFromSchool
	and m.DateExitedSchool >=osp.DateEnrolledInSchool
go	


update osp
set fl_famlinkFC=1
from ospi.temp osp
join ospi.ospi_episodes eps on eps.int_researchID=osp.int_researchID
and eps.strt_dte<=osp.DateExitedFromSchool
and eps.end_dte>=osp.DateEnrolledInSchool
--- SET NULL VALUES to 0
update osp
set osp.[fl_foreignExch]=0
from ospi.temp osp
where osp.[fl_foreignExch] is null
go
update osp
set osp.[fl_fostercare_1011]=0
from ospi.temp osp
where osp.[fl_fostercare_1011] is null
go
update osp
set osp.[fl_famlinkFC]=0
from ospi.temp osp
where osp.[fl_famlinkFC] is null
go
update osp
set osp.[fl_specialEd]=0
from ospi.temp osp
where osp.[fl_specialEd] is null
go

update osp
set osp.[fl_privateSchool]=0
from ospi.temp osp
where osp.[fl_privateSchool] is null
go
update osp
set osp.[fl_homeBased]=0
from ospi.temp osp
where osp.[fl_homeBased] is null
go
update osp
set osp.[fl_504]=0
from ospi.temp osp
where osp.[fl_504] is null

go
update osp
set osp.[fl_homeless]=0
from ospi.temp osp
where osp.[fl_homeless] is null
go

update osp
set osp.fl_migrant=0
from ospi.temp osp
where osp.fl_migrant is null
go


--select * from #temp

select * into ospi.temp_thru_8 from ospi.temp




-- select * from ospi.temp  order by int_researchID,row_num_asc	 	--where int_researchID=65