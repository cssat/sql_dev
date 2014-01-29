-- select * from ospi.temp where int_researchID=5 order by int_researchID,row_num_asc
if object_ID('tempDB..##ss') is not null drop table ##ss

update ospi.temp
set fl_delete = 0

select curr.*,cast(0 as int) as ss_row_num,cast(0 as int) as frst
into ##ss
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
		OR (month(curr.DateExitedFromSchool) in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
union
select nxt.*,cast(0 as int) as ss_row_num,cast(0 as int) as frst
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
		OR (month(curr.DateExitedFromSchool) in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
--LOH
--select * from ##ss where int_researchID=153593
--select * from ospi.temp where int_researchID=153593 order by row_num_asc
update curr
set fl_delete = 1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
		OR (month(curr.DateExitedFromSchool)  in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
	
update nxt
set fl_delete = 1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
		OR (month(curr.DateExitedFromSchool)  in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))


update my
set ss_row_num = q.ss_row_num
from ##SS my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID
								,DateEnrolledInSchool asc
								,DateExitedFromSchool asc) as ss_row_num
		from ##SS
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
			
			


update ##ss
set frst=1
where ss_row_num=1	

update nxt
set frst=1
from ##ss curr
join ##ss nxt 
	on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
	and NOT(
		((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
		OR (month(curr.DateExitedFromSchool)  in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
	 and curr.schoolCode = nxt.SchoolCode)

--select * from ##ss  where int_researchID=153593

declare @i int
declare @stopLoop int
set @stopLoop = (select max(ss_row_num) from ##ss)
set @i=1

while @i <=@stopLoop
begin	

	update nxt
	set fl_delete=1
	from ##ss curr
	join ##ss nxt 
		on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
		and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
			OR (month(curr.DateExitedFromSchool)  in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
		and curr.schoolcode=nxt.schoolcode
		and nxt.frst=0
	where curr.frst=1 
	 
	update curr
	set ss_row_num=nxt.ss_row_num
	,DateExitedFromSchool=nxt.DateExitedFromSchool
	,DateExitedFromDistrict=nxt.DateExitedFromDistrict
	,int_max_grade=nxt.int_max_grade
	,max_grade_level=nxt.max_grade_level
	,last_enr_mnth=nxt.last_enr_mnth
	,EnrollmentStatus=nxt.EnrollmentStatus
	from ##ss curr
	join ##ss nxt 
		on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
		and ((datediff(dd,curr.DateExitedFromSchool,nxt.DateEnrolledInSchool) <=2)
			OR (month(curr.DateExitedFromSchool)  in (5,6,7,8) 
			and month(nxt.DateEnrolledInSchool) in (8,9)
			and year(curr.DateExitedFromSchool)=year(nxt.DateEnrolledInSchool)
				))
		and curr.schoolcode=nxt.schoolcode
		and nxt.frst=0
	where curr.frst=1 

	delete from ##ss where fl_delete=1;

	update my
	set ss_row_num = q.ss_row_num
	from ##SS my		
	join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
				,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
			,row_number() over (partition by int_researchID
									order by int_researchID
									,DateEnrolledInSchool asc
									,DateExitedFromSchool asc) as ss_row_num
			from ##SS
			) q on q.int_researchID=my.int_researchID
				and q.DistrictID=my.DistrictID
				and q.SchoolCode=my.SchoolCode
				and q.DateEnrolledInSchool=my.DateEnrolledInSchool
				and q.DateExitedFromSchool=my.DateExitedFromSchool
	
	set @i=@i+1;
end
---LOH
--select * from ##ss  where int_researchID=153593
--select * from ospi.temp  where int_researchID=153593 order by row_num_asc

delete from ospi.temp where fl_delete = 1;

--- RUN TO HERE	
insert into ospi.temp
    ([int_researchID]
           ,[DistrictID]
           ,[SchoolCode]
           ,[DateEnrolledInDistrict]
           ,[DateExitedFromDistrict]
           ,[DateEnrolledInSchool]
           ,[DateExitedFromSchool]
           ,[EnrollmentStatuS]
           ,[frst_enr_mnth]
           ,[last_enr_mnth]
           ,[min_grade_level]
           ,[max_grade_level]
           ,[int_min_grade]
           ,[int_max_grade]
           ,[row_num_asc]
           ,[row_num_desc]
           ,[fl_multiple_primaryschool]
           ,[fl_prm_txfr]
           ,[fl_prm_txfr_inter]
           ,[fl_prm_txfr_intra]
           ,[fl_other_txfr]
           ,[fl_other_txfr_inter]
           ,[fl_other_txfr_intra]
           ,[overall_txfr_rank]
           ,[prom_txfr_rank]
           ,[other_txfr_rank]
           ,[enrollment_duration]
           ,[approx_age_enroll_start]
           ,[approx_age_enroll_end]
           ,[MonthYearBirth]
           ,[fl_delete])
SELECT [int_researchID]
      ,[DistrictID]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,[EnrollmentStatuS]
      ,[frst_enr_mnth]
      ,[last_enr_mnth]
      ,[min_grade_level]
      ,[max_grade_level]
      ,[int_min_grade]
      ,[int_max_grade]
      ,[row_num_asc]
      ,[row_num_desc]
      ,[fl_multiple_primaryschool]
      ,[fl_prm_txfr]
      ,[fl_prm_txfr_inter]
      ,[fl_prm_txfr_intra]
      ,[fl_other_txfr]
      ,[fl_other_txfr_inter]
      ,[fl_other_txfr_intra]
      ,[overall_txfr_rank]
      ,[prom_txfr_rank]
      ,[other_txfr_rank]
      ,[enrollment_duration]
      ,[approx_age_enroll_start]
      ,[approx_age_enroll_end]
      ,[MonthYearBirth]
      ,0 as [fl_delete]
  FROM ##SS
  where frst=1;
 

update my
set row_num_asc = q.row_num_asc
	,row_num_desc=q.row_num_desc
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go	

--------------------------------------------------------------------------------- FLAG MULTIPLE PRIMARY SCHOOL
update ospi.temp
set fl_multiple_primaryschool = 0
go
update my
set fl_multiple_primaryschool = 1
from ospi.temp  my
join (					  
	select int_researchID,DateEnrolledInSchool,count(*) as cnt
	 from ospi.temp 
	 group by int_researchID,DateEnrolledInSchool
	 having count(*) > 1 ) q on q.int_researchID=my.int_researchID
		and my.DateEnrolledInSchool=q.DateEnrolledInSchool
go
update ospi.temp
set fl_delete = 0
if object_ID('tempDB..##ss') is not null drop table ##ss

select curr.*,cast(0 as int) as ss_row_num
into ##ss
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode<>nxt.schoolcode
	and curr.fl_multiple_primaryschool=1
	and nxt.fl_multiple_primaryschool=1
union
select nxt.*,cast(0 as int) as ss_row_num
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode<>nxt.schoolcode
	and curr.fl_multiple_primaryschool=1
	and nxt.fl_multiple_primaryschool=1

update curr
set fl_delete=1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode<>nxt.schoolcode
	and curr.fl_multiple_primaryschool=1
	and nxt.fl_multiple_primaryschool=1

update nxt
set fl_delete=1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode<>nxt.schoolcode
	and curr.fl_multiple_primaryschool=1
	and nxt.fl_multiple_primaryschool=1



update my
	set ss_row_num = q.ss_row_num
	from ##SS my		
	join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
				,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
			,row_number() over (partition by int_researchID
									order by int_researchID
									,DateEnrolledInSchool asc
									,DateExitedFromSchool asc) as ss_row_num
			from ##SS
			) q on q.int_researchID=my.int_researchID
				and q.DistrictID=my.DistrictID
				and q.SchoolCode=my.SchoolCode
				and q.DateEnrolledInSchool=my.DateEnrolledInSchool
				and q.DateExitedFromSchool=my.DateExitedFromSchool
	
	update nxt
	set fl_multiple_primaryschool=0
	from ##SS curr
	join ##SS nxt on curr.int_researchID=nxt.int_researchID
		and nxt.ss_row_num=curr.ss_row_num + 1
	where curr.DateExitedFromSchool <> '12/31/3999'
		and curr.DateExitedFromSchool < nxt.DateExitedFromSchool;

	update curr
	set fl_multiple_primaryschool=0
	from ##SS curr
	join ##SS nxt on curr.int_researchID=nxt.int_researchID
		and nxt.ss_row_num=curr.ss_row_num + 1
	where curr.DateExitedFromSchool <> '12/31/3999'
		and curr.DateExitedFromSchool < nxt.DateExitedFromSchool;
		
	update nxt
	set nxt.DateEnrolledInSchool=dateadd(dd,1,curr.DateExitedFromSchool)
		,nxt.frst_enr_mnth=cast(left(convert(varchar(10),dateadd(dd,1,curr.DateExitedFromSchool),112),6) as int)
	from ##SS curr
	join ##SS nxt on curr.int_researchID=nxt.int_researchID
		and nxt.ss_row_num=curr.ss_row_num + 1
	where curr.DateExitedFromSchool <> '12/31/3999'
		and curr.DateExitedFromSchool < nxt.DateExitedFromSchool;

	-- now update the remaining with the first_enr_mnth Last_enr_mnth
	update curr
	set curr.DateEnrolledInSchool=convert(datetime,cast(curr.frst_enr_mnth as varchar(6)) + '01',112)
		,curr.DateExitedFromSchool=dateadd(dd,-1,dateadd(mm,1,(convert(datetime,(cast(curr.last_enr_mnth as varchar(6)) + '01'),112))))
	from ##SS curr
	where curr.fl_multiple_primaryschool=1 

	
   delete from ospi.temp where fl_delete=1;

   insert into ospi.temp
       ([int_researchID]
           ,[DistrictID]
           ,[SchoolCode]
           ,[DateEnrolledInDistrict]
           ,[DateExitedFromDistrict]
           ,[DateEnrolledInSchool]
           ,[DateExitedFromSchool]
           ,[EnrollmentStatuS]
           ,[frst_enr_mnth]
           ,[last_enr_mnth]
           ,[min_grade_level]
           ,[max_grade_level]
           ,[int_min_grade]
           ,[int_max_grade]
           ,[row_num_asc]
           ,[row_num_desc]
           ,[fl_multiple_primaryschool]
           ,[fl_prm_txfr]
           ,[fl_prm_txfr_inter]
           ,[fl_prm_txfr_intra]
           ,[fl_other_txfr]
           ,[fl_other_txfr_inter]
           ,[fl_other_txfr_intra]
           ,[overall_txfr_rank]
           ,[prom_txfr_rank]
           ,[other_txfr_rank]
           ,[enrollment_duration]
           ,[approx_age_enroll_start]
           ,[approx_age_enroll_end]
           ,[MonthYearBirth]
           ,[fl_delete])
   select [int_researchID]
           ,[DistrictID]
           ,[SchoolCode]
           ,[DateEnrolledInDistrict]
           ,[DateExitedFromDistrict]
           ,[DateEnrolledInSchool]
           ,[DateExitedFromSchool]
           ,[EnrollmentStatuS]
           ,[frst_enr_mnth]
           ,[last_enr_mnth]
           ,[min_grade_level]
           ,[max_grade_level]
           ,[int_min_grade]
           ,[int_max_grade]
           ,[row_num_asc]
           ,[row_num_desc]
           ,[fl_multiple_primaryschool]
           ,[fl_prm_txfr]
           ,[fl_prm_txfr_inter]
           ,[fl_prm_txfr_intra]
           ,[fl_other_txfr]
           ,[fl_other_txfr_inter]
           ,[fl_other_txfr_intra]
           ,[overall_txfr_rank]
           ,[prom_txfr_rank]
           ,[other_txfr_rank]
           ,[enrollment_duration]
           ,[approx_age_enroll_start]
           ,[approx_age_enroll_end]
           ,[MonthYearBirth]
           ,0 as fl_delete from ##SS

update my
set row_num_asc = q.row_num_asc
	,row_num_desc=q.row_num_desc
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go	

--LOH

--select * from ospi.temp where fl_delete=1
--order by int_researchID,row_num_asc;
--------------------------------------------------------------------------------- NOW remove overlapping segments one last time.
if object_ID('tempDB..##ss') is not null drop table ##ss
select curr.*,0 as ss_row_num,0 as frst
into ##SS
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
union 
select nxt.*,0 as ss_row_num,0 as frst
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool

update curr
set fl_delete = 1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool

update nxt
set fl_delete = 1
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	and curr.schoolcode=nxt.schoolcode
	and curr.districtid=nxt.districtid
	and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool

--  select int_researchID,count(*) from ##SS group by int_researchID having count(*) > 2


update my
set ss_row_num = q.ss_row_num
from ##SS my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth
		,row_number() over (partition by int_researchID
								order by int_researchID
								,DateEnrolledInSchool asc
								,DateExitedFromSchool asc) as ss_row_num
		from ##SS
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
			

update ##ss
set frst=1
where ss_row_num=1	

update nxt
set frst=1
from ##ss curr
join ##ss nxt 
	on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
	 and NOT( curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
				and curr.schoolCode = nxt.SchoolCode)



update ##ss
set fl_delete=0


declare @i int
declare @stopLoop int
set @stopLoop = (select max(ss_row_num) from ##ss)
set @i=1

while @i <=@stopLoop
begin	

	update nxt
	set fl_delete=1
	from ##ss curr
	join ##ss nxt 
		on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
		and curr.schoolcode=nxt.schoolcode
		and  curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
		and nxt.frst=0
	where curr.frst=1 
	 
	update curr
	set ss_row_num=nxt.ss_row_num
	,DateExitedFromSchool=nxt.DateExitedFromSchool
	,DateExitedFromDistrict=nxt.DateExitedFromDistrict
	,int_max_grade=nxt.int_max_grade
	,max_grade_level=nxt.max_grade_level
	,last_enr_mnth=nxt.last_enr_mnth
	,EnrollmentStatus=nxt.EnrollmentStatus
	from ##ss curr
	join ##ss nxt 
		on curr.int_researchID=nxt.int_researchID and curr.ss_row_num + 1=nxt.ss_row_num		
		and curr.schoolcode=nxt.schoolcode
		and  curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
		and nxt.frst=0
	where curr.frst=1 

	delete from ##ss where fl_delete=1;

	update my
	set ss_row_num = q.ss_row_num
	from ##SS my		
	join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
				,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
			,row_number() over (partition by int_researchID
									order by int_researchID
									,DateEnrolledInSchool asc
									,DateExitedFromSchool asc) as ss_row_num
			from ##SS
			) q on q.int_researchID=my.int_researchID
				and q.DistrictID=my.DistrictID
				and q.SchoolCode=my.SchoolCode
				and q.DateEnrolledInSchool=my.DateEnrolledInSchool
				and q.DateExitedFromSchool=my.DateExitedFromSchool
	
	set @i=@i+1;
end


   insert into ospi.temp
       ([int_researchID]
           ,[DistrictID]
           ,[SchoolCode]
           ,[DateEnrolledInDistrict]
           ,[DateExitedFromDistrict]
           ,[DateEnrolledInSchool]
           ,[DateExitedFromSchool]
           ,[EnrollmentStatuS]
           ,[frst_enr_mnth]
           ,[last_enr_mnth]
           ,[min_grade_level]
           ,[max_grade_level]
           ,[int_min_grade]
           ,[int_max_grade]
           ,[row_num_asc]
           ,[row_num_desc]
           ,[fl_multiple_primaryschool]
           ,[fl_prm_txfr]
           ,[fl_prm_txfr_inter]
           ,[fl_prm_txfr_intra]
           ,[fl_other_txfr]
           ,[fl_other_txfr_inter]
           ,[fl_other_txfr_intra]
           ,[overall_txfr_rank]
           ,[prom_txfr_rank]
           ,[other_txfr_rank]
           ,[enrollment_duration]
           ,[approx_age_enroll_start]
           ,[approx_age_enroll_end]
           ,[MonthYearBirth]
           ,[fl_delete])
   select [int_researchID]
           ,[DistrictID]
           ,[SchoolCode]
           ,[DateEnrolledInDistrict]
           ,[DateExitedFromDistrict]
           ,[DateEnrolledInSchool]
           ,[DateExitedFromSchool]
           ,[EnrollmentStatuS]
           ,[frst_enr_mnth]
           ,[last_enr_mnth]
           ,[min_grade_level]
           ,[max_grade_level]
           ,[int_min_grade]
           ,[int_max_grade]
           ,[row_num_asc]
           ,[row_num_desc]
           ,[fl_multiple_primaryschool]
           ,[fl_prm_txfr]
           ,[fl_prm_txfr_inter]
           ,[fl_prm_txfr_intra]
           ,[fl_other_txfr]
           ,[fl_other_txfr_inter]
           ,[fl_other_txfr_intra]
           ,[overall_txfr_rank]
           ,[prom_txfr_rank]
           ,[other_txfr_rank]
           ,[enrollment_duration]
           ,[approx_age_enroll_start]
           ,[approx_age_enroll_end]
           ,[MonthYearBirth]
           ,0 as [fl_delete] from ##SS

update my
set row_num_asc = q.row_num_asc
	,row_num_desc=q.row_num_desc
from ospi.temp my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from ospi.temp
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
go	

truncate table  ospi.temp_thru_4 
insert into ospi.temp_thru_4
select *  from ospi.temp	

select * from ospi.temp where int_researchID=153593  order by row_num_asc



