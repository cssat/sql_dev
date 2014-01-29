

update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,DateEnrolledInSchool,DateExitedFromSchool ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool

	

declare @loop int
declare @stoploop int
declare @maxloop int
set @loop=1
set @stoploop=100000
set @maxloop =2000000

while @stoploop <= @maxloop
begin
	
		begin tran t1
		-- update flag delete for the next segment where the next segment is included in the current segment
		update nxt
		set fl_delete = 1
		from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt on nxt.int_researchID=curr.int_researchID 
						and curr.row_num + 1 = nxt.row_num
						and Curr.schoolcode=nxt.schoolcode
						and curr.districtID=nxt.districtID
						and    (curr.last_enr_mnth = nxt.frst_enr_mnth
							or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
						and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
						and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool
		where curr.int_researchID between @loop and @stopLoop
		commit tran t1
		
		begin tran t2
		--update current segment where the next segment is included in current segment
		update curr
		set max_grade_level=case when nxt.int_max_grade > curr.int_max_grade then nxt.max_grade_level else curr.max_grade_level end
		, last_enr_mnth=nxt.last_enr_mnth
		,school_exit_date = nxt.school_exit_date
		--select  nxt.fl_delete, nxt.int_researchID,nxt.DistrictID,nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
		--nxt.min_grade_level,nxt.max_grade_level,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level
		from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
						and Curr.schoolcode=nxt.schoolcode
						and curr.districtID=nxt.districtID
						and  (curr.last_enr_mnth = nxt.frst_enr_mnth
							or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
						and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
						and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool
		where curr.int_researchID between @loop and @stopLoop
			
		
		commit tran t2
		
		
		

	

	set @loop = @loop + 100000
	set @stoploop = @stoploop + 100000	
				
end

set @loop=1
set @stoploop=100000

while @stoploop <= @maxloop
begin
	begin tran t3

		delete from ospi.enrollment_temp_jm
		where fl_delete = 1 and int_researchID between @loop and @stopLoop
		
	commit tran t3
	
	set @loop = @loop + 100000
	set @stoploop = @stoploop + 100000
end

-----------------------------------------------------------------------------------------------------
--resort the enrollments
update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,school_enroll_date,school_exit_date ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool
			
			
--declare @loop int
--declare @stoploop int
--declare @maxloop int
--set @loop=1
--set @stoploop=50000
--set @maxloop =1902534

set @loop=1
set @stoploop=100000

while @stoploop <= @maxloop
begin
	
		begin tran t4
		
		update nxt
		set fl_delete = 1
		--select  nxt.fl_delete, nxt.int_researchID,nxt.DistrictID,nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
		--nxt.min_grade_level,nxt.max_grade_level,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level
		from ospi.enrollment_temp_jm curr
				join  ospi.enrollment_temp_jm  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
						and Curr.schoolcode=nxt.schoolcode
						and curr.districtID=nxt.districtID
						and NOT (curr.last_enr_mnth = nxt.frst_enr_mnth
							or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
						and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
						and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool
						and curr.last_enr_mnth=nxt.last_enr_mnth
		where curr.int_researchID between @loop and @stopLoop
		commit tran t4
		
		begin tran t5
		update curr
		set max_grade_level=case when nxt.int_max_grade > curr.int_max_grade then nxt.max_grade_level else curr.max_grade_level end
		, last_enr_mnth=nxt.last_enr_mnth
		,school_exit_date = nxt.school_exit_date
		--select  nxt.fl_delete, nxt.int_researchID,nxt.DistrictID,nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
		--nxt.min_grade_level,nxt.max_grade_level,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level
		from ospi.enrollment_temp_jm curr
				join  ospi.enrollment_temp_jm  nxt on nxt.int_researchID=curr.int_researchID and curr.row_num + 1 = nxt.row_num
						and Curr.schoolcode=nxt.schoolcode
						and curr.districtID=nxt.districtID
						and NOT (curr.last_enr_mnth = nxt.frst_enr_mnth
							or curr.last_enr_mnth + 1 = nxt.frst_enr_mnth)
						and curr.DateExitedFromSchool > nxt.DateEnrolledInSchool
						and curr.DateEnrolledInSchool <= nxt.DateEnrolledInSchool
						and curr.last_enr_mnth=nxt.last_enr_mnth
		where curr.int_researchID between @loop and @stopLoop
		
		
		commit tran t5
	
	

		
	set @loop = @loop + 100000
	set @stoploop = @stoploop + 100000	
				
end


set @loop=1
set @stoploop=100000

while @stoploop <= @maxloop
begin
	begin tran t6
		delete from ospi.enrollment_temp_jm
			where fl_delete = 1 and int_researchID between @loop and @stopLoop
	
	commit tran t6
	set @loop = @loop + 100000
	set @stoploop = @stoploop + 100000
end

					
update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,School_enroll_date,school_exit_date ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool

				
-- update exit date for those school transfers where exit date is 12/31/3999 for school student is transferring from.				
update curr
set School_Exit_Date=dateadd(dd,-1,nxt.School_Enroll_date)
	,enrollmentstatus=case when curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID=nxt.districtID then 'T1' 
	when  curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID<>nxt.districtID then 'T0' 
	else curr.enrollmentstatus
	end
--select 				
--	case when curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID=nxt.districtID then 'T1' 
--	when  curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID<>nxt.districtID then 'T0' 
--	else curr.enrollmentstatus
--	end as new_stat,curr.enrollmentstatus, nxt.enrollmentstatus,nxt.int_researchID,curr.SchoolCode,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level,
--	nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
--	nxt.min_grade_level,nxt.max_grade_level
from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt 
		on nxt.int_researchID=curr.int_researchID and curr.row_num + 1= nxt.row_num
where curr.int_researchID=nxt.int_researchID
	and curr.schoolcode<>nxt.schoolcode
	and curr.school_exit_date='12/31/3999'
	and ( nxt.school_exit_date='12/31/3999'
	or  (nxt.school_exit_date<'12/31/3999'
			and nxt.enrollmentstatus in ('T1','T0','G0','U3')))
	and dateadd(dd,-1,nxt.School_Enroll_date) > curr.School_Enroll_date
--order by curr.int_researchID,curr.row_num


--update schools that are not the same but current end date was a Force exit and is earlier than next school enrollment date
--  update the enrollment status
update curr
set --School_Exit_Date=dateadd(dd,-1,nxt.School_Enroll_date)
	enrollmentstatus=case when curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID=nxt.districtID then 'T1' 
	when  curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID<>nxt.districtID then 'T0' 
	else curr.enrollmentstatus
	end
	--select 				
	--	case when curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID=nxt.districtID then 'T1' 
	--	when  curr.enrollmentstatus in ('E0','P1','FE') and curr.districtID<>nxt.districtID then 'T0' 
	--	else curr.enrollmentstatus
	--	end as new_stat,curr.enrollmentstatus, nxt.enrollmentstatus,nxt.int_researchID,curr.SchoolCode,curr.School_Enroll_Date,curr.School_Exit_Date,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level,
	--	nxt.SchoolCode,nxt.School_Enroll_Date,nxt.School_Exit_Date,nxt.frst_enr_mnth,nxt.last_enr_mnth,
	--	nxt.min_grade_level,nxt.max_grade_level
from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt 
		on nxt.int_researchID=curr.int_researchID and curr.row_num + 1= nxt.row_num
where curr.int_researchID=nxt.int_researchID
		and curr.schoolcode<>nxt.schoolcode
		and datediff(dd,curr.school_exit_date,nxt.school_enroll_date)>1
		and curr.enrollmentstatus='FE'
		and dateadd(dd,-1,nxt.School_Enroll_date) > curr.School_Enroll_date


-- for those with Forced exit at end of  year & enrolled in next year same school set the NEXT fl_delete =1
update nxt
set fl_delete=1
	--select 				
	--	curr.enrollmentstatus as currstat, nxt.enrollmentstatus as nxtstat,nxt.int_researchID,curr.SchoolCode,nxt.SchoolCode
	--	,curr.School_Enroll_Date,curr.School_Exit_Date,nxt.School_Enroll_Date as nxt_enroll,nxt.School_Exit_Date as nxt_exit,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level,
	--	nxt.min_grade_level,nxt.max_grade_level,nxt.frst_enr_mnth,nxt.last_enr_mnth
from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt 
		on nxt.int_researchID=curr.int_researchID and curr.row_num + 1= nxt.row_num
where curr.int_researchID=nxt.int_researchID
		and curr.schoolcode=nxt.schoolcode
		and datediff(dd,curr.school_exit_date,nxt.school_enroll_date)>1
		and curr.enrollmentstatus='FE'
		and dateadd(dd,-1,nxt.School_Enroll_date) > curr.School_Enroll_date
		and ((nxt.int_min_grade=curr.int_max_grade and nxt.int_min_grade<>-2)
				or nxt.int_min_grade=curr.int_max_grade + 1)
		and month(curr.school_exit_date)	between 6 and 8
		and year(curr.school_exit_date)= year(nxt.school_enroll_date)
		and month(nxt.school_enroll_date) between 8 and 9
		
update curr
set   School_Exit_Date=nxt.School_Exit_Date
	, EnrollmentStatus=nxt.EnrollmentStatus
	, max_Grade_Level=nxt.max_Grade_level
	, last_enr_mnth=nxt.last_enr_mnth
	, int_max_grade=nxt.int_max_grade
	--select 				
	--	curr.DateEnrolledInDistrict,curr.DateExitedFromDistrict,nxt.DateEnrolledInDistrict as nxt_district_enroll_date,nxt.DateExitedFromDistrict as nxt_district_exit_date,
	--	curr.enrollmentstatus as currstat, nxt.enrollmentstatus as nxtstat,nxt.int_researchID,curr.SchoolCode,nxt.SchoolCode
	--	,curr.School_Enroll_Date,curr.School_Exit_Date,nxt.School_Enroll_Date as nxt_enroll,nxt.School_Exit_Date as nxt_exit,curr.frst_enr_mnth,curr.last_enr_mnth,curr.min_grade_level,curr.max_grade_level,
	--	nxt.min_grade_level,nxt.max_grade_level,nxt.frst_enr_mnth,nxt.last_enr_mnth
from ospi.enrollment_temp_jm curr
		join  ospi.enrollment_temp_jm  nxt 
		on nxt.int_researchID=curr.int_researchID and curr.row_num + 1= nxt.row_num
where curr.int_researchID=nxt.int_researchID
		and curr.schoolcode=nxt.schoolcode
		and datediff(dd,curr.school_exit_date,nxt.school_enroll_date)>1
		and curr.enrollmentstatus='FE'
		and dateadd(dd,-1,nxt.School_Enroll_date) > curr.School_Enroll_date
		and ((nxt.int_min_grade=curr.int_max_grade and nxt.int_min_grade<>-2)
				or nxt.int_min_grade=curr.int_max_grade + 1)
		and month(curr.school_exit_date)	between 6 and 8
		and year(curr.school_exit_date)= year(nxt.school_enroll_date)
		and month(nxt.school_enroll_date) between 8 and 9		
			

set @loop=1
set @stoploop=100000

while @stoploop <= @maxloop
begin
	begin tran t7
		delete from ospi.enrollment_temp_jm
			where fl_delete = 1 and int_researchID between @loop and @stopLoop
	
	commit tran t7
	set @loop = @loop + 100000
	set @stoploop = @stoploop + 100000
end

					
update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,School_enroll_date,school_exit_date ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool




update 	ospi.enrollment_temp_jm 
set int_max_grade=   cast(max_grade_level as int) 
where isnumeric(max_grade_level) =1 and cast(max_grade_level as int)<>int_max_grade


update 	ospi.enrollment_temp_jm 
set int_min_grade=   cast(min_grade_level as int) 
where isnumeric(min_grade_level) =1 and cast(min_grade_level as int)<>int_min_grade


update ospi.enrollment_temp_jm 
set int_max_grade=   case when max_grade_level='PK' then -2
		when max_grade_level='K1' then -1
		when max_grade_level='K2' then 0 end 
where isnumeric(max_grade_level) =0
and int_max_grade <> case when max_grade_level='PK' then -2
		when max_grade_level='K1' then -1
		when max_grade_level='K2' then 0 end 
		
		
update ospi.enrollment_temp_jm 
set int_min_grade=   case when min_grade_level='PK' then -2
		when min_grade_level='K1' then -1
		when min_grade_level='K2' then 0 end 
where isnumeric(min_grade_level) =0
and int_min_grade <> case when min_grade_level='PK' then -2
		when min_grade_level='K1' then -1
		when min_grade_level='K2' then 0 end 	
		
-- now update those in the same school all year

if object_ID('tempDB..##sameschool') is not null drop table ##sameschool
select q.*
into ##sameschool
from (
		select int_researchID,DistrictID,schoolcode,min(school_enroll_date) as min_school_enroll_date
				,max(school_exit_date) as max_school_exit_date
				,cast(null as datetime) as district_enroll_date
				,cast(null as datetime) as district_exit_date
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



update SS
set EnrollmentStatus=enr.EnrollmentStatus
	,District_Enroll_date=DateEnrolledInDistrict
	,District_Exit_Date=DateExitedFromDistrict
from ##sameschool SS
join ospi.enrollment_temp_jm enr
	on SS.int_researchID=enr.int_researchID
	and ss.schoolcode=enr.schoolcode
	and ss.districtID=enr.DistrictID
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
		
		
update enr
set fl_delete = 1
from ospi.enrollment_temp_jm  enr
join ##sameschool SS on SS.int_researchID=enr.int_researchID
	and ss.schoolcode=enr.schoolcode
	and ss.DistrictID=enr.DistrictID
	
	
delete from ospi.enrollment_temp_jm  where fl_delete = 1;

INSERT INTO [dbCoreAdministrativeTables].[ospi].[enrollment_temp_jm]
           ([int_researchID]
           ,[districtID]
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
           ,[fl_delete]
           ,[row_num]
           ,[school_enroll_date]
           ,[school_exit_date]
           ,[int_min_grade]
           ,[int_max_grade])
           
          select 
			  int_researchID
			, [districtID]
			, [SchoolCode]
			, District_Enroll_date
			, District_Exit_Date
			, min_school_enroll_date
			, max_school_exit_date
			, enrollmentstatus
			, min_frst_enr_mnth
			, max_last_enr_mnth
			, min_grade_level
			, max_grade_level
			, 0
			, 0
			, min_school_enroll_date
			, max_school_exit_date
			, int_min_grade
			, int_max_grade
			
          from ##sameschool

					
update tmp
set row_num = curr.row_sort
from ospi.enrollment_temp_jm  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,School_enroll_date,school_exit_date ) as row_sort
		from ospi.enrollment_temp_jm
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool	
		
update statistics ospi.enrollment_temp_jm	

update ospi.enrollment_temp_jm 
set school_exit_date=dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(last_enr_mnth as varchar(6)) + '01',112)))
where school_exit_date='12/31/3999' and last_enr_mnth <=201009	