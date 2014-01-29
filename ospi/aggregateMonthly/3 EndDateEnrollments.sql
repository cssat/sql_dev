--End Date Enrollments


--first resort
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
-- update exits for same student end of year
-- if the Last Enroll End of Month Date is greater than NEXT enroll date 
-- then end date record with day prior next enrollment date
--  else use the last day of last enrollment month
-- create table to hold  results for the current records meeting criteria
-- create table to hold temp rows NOT IN the first temp table 
--  (ALL other rows from ospi.temp with exception of current records meeting criteria)
--  truncate table temp then insert the records from the 2 tables using updated exit date and 'FE' enrollment status
if object_ID('tempDB..##curr') is not null drop table ##curr

select case when dateadd(dd,-1
					,dateadd(mm,1
						,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112))) 
						> nxt.DateEnrolledInSchool
								then dateadd(dd,-1,nxt.DateEnrolledInSchool)
		else
				dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112)))
		end as new_exit_date 
	  --,nxt.DateEnrolledInSchool as nxt_enroll_date
	  --,nxt.DateExitedFromSchool as nxt_exit_date
	  ,curr.int_researchID
      ,curr.DistrictID
      ,curr.SchoolCode
      ,curr.DateEnrolledInDistrict
      ,curr.DateExitedFromDistrict
      ,curr.DateEnrolledInSchool
      ,curr.DateExitedFromSchool
      ,curr.EnrollmentStatuS
      ,curr.frst_enr_mnth
      ,curr.last_enr_mnth
      ,curr.min_grade_level
      ,curr.max_grade_level
      ,curr.int_min_grade
      ,curr.int_max_grade
      ,curr.row_num_asc
      ,curr.row_num_desc
      ,curr.fl_multiple_primaryschool
      ,curr.fl_prm_txfr
      ,curr.fl_prm_txfr_inter
      ,curr.fl_prm_txfr_intra
      ,curr.fl_other_txfr
      ,curr.fl_other_txfr_inter
      ,curr.fl_other_txfr_intra
      ,curr.overall_txfr_rank
      ,curr.prom_txfr_rank
      ,curr.other_txfr_rank
      ,curr.enrollment_duration
      ,curr.approx_age_enroll_start
      ,curr.approx_age_enroll_end
      ,curr.MonthYearBirth
      ,curr.fl_delete
into ##curr
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID 
		and curr.row_num_asc+1=nxt.row_num_asc
where curr.DateExitedFromSchool> nxt.DateEnrolledInSchool	
	and curr.FL_multiple_primaryschool <> 1
	and nxt.FL_multiple_primaryschool <>1
	--and curr.schoolCode=nxt.SchoolCode
	and year(nxt.DateEnrolledInSchool)=year(convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112))
	and curr.last_enr_mnth < nxt.frst_enr_mnth

if object_ID('tempDB..#tmp') is not null drop table #tmp
select int_researchID
      ,DistrictID
      ,SchoolCode
      ,DateEnrolledInDistrict
      ,coalesce(DateExitedFromDistrict,'12/31/3999') as DateExitedFromDistrict
      ,DateEnrolledInSchool
      ,DateExitedFromSchool
      ,EnrollmentStatuS
      ,frst_enr_mnth
      ,last_enr_mnth
      ,min_grade_level
      ,max_grade_level
      ,int_min_grade
      ,int_max_grade
      ,row_num_asc
      ,row_num_desc
      ,fl_multiple_primaryschool
      ,fl_prm_txfr
      ,fl_prm_txfr_inter
      ,fl_prm_txfr_intra
      ,fl_other_txfr
      ,fl_other_txfr_inter
      ,fl_other_txfr_intra
      ,overall_txfr_rank
      ,prom_txfr_rank
      ,other_txfr_rank
      ,enrollment_duration
      ,approx_age_enroll_start
      ,approx_age_enroll_end
      ,MonthYearBirth
      ,fl_delete
into #tmp
from ospi.temp
except 
select int_researchID
      ,DistrictID
      ,SchoolCode
      ,DateEnrolledInDistrict
      ,coalesce(DateExitedFromDistrict,'12/31/3999') as DateExitedFromDistrict
      ,DateEnrolledInSchool
      ,DateExitedFromSchool
      ,EnrollmentStatuS
      ,frst_enr_mnth
      ,last_enr_mnth
      ,min_grade_level
      ,max_grade_level
      ,int_min_grade
      ,int_max_grade
      ,row_num_asc
      ,row_num_desc
      ,fl_multiple_primaryschool
      ,fl_prm_txfr
      ,fl_prm_txfr_inter
      ,fl_prm_txfr_intra
      ,fl_other_txfr
      ,fl_other_txfr_inter
      ,fl_other_txfr_intra
      ,overall_txfr_rank
      ,prom_txfr_rank
      ,other_txfr_rank
      ,enrollment_duration
      ,approx_age_enroll_start
      ,approx_age_enroll_end
      ,MonthYearBirth
      ,fl_delete
from ##curr  
where new_exit_date >= dateEnrolledInschool 

truncate table ospi.temp
insert into ospi.temp([int_researchID]
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
select int_researchID
      ,DistrictID
      ,SchoolCode
      ,DateEnrolledInDistrict
      ,coalesce(DateExitedFromDistrict,'12/31/3999') as DateExitedFromDistrict
      ,DateEnrolledInSchool
      ,DateExitedFromSchool
      ,EnrollmentStatuS
      ,frst_enr_mnth
      ,last_enr_mnth
      ,min_grade_level
      ,max_grade_level
      ,int_min_grade
      ,int_max_grade
      ,row_num_asc
      ,row_num_desc
      ,fl_multiple_primaryschool
      ,fl_prm_txfr
      ,fl_prm_txfr_inter
      ,fl_prm_txfr_intra
      ,fl_other_txfr
      ,fl_other_txfr_inter
      ,fl_other_txfr_intra
      ,overall_txfr_rank
      ,prom_txfr_rank
      ,other_txfr_rank
      ,enrollment_duration
      ,approx_age_enroll_start
      ,approx_age_enroll_end
      ,MonthYearBirth
      ,fl_delete
from #tmp

insert into ospi.temp([int_researchID]
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
select int_researchID
      ,DistrictID
      ,SchoolCode
      ,DateEnrolledInDistrict
      ,coalesce(DateExitedFromDistrict,'12/31/3999') as DateExitedFromDistrict
      ,DateEnrolledInSchool
      ,new_exit_date
      ,'FE'
      ,frst_enr_mnth
      ,last_enr_mnth
      ,min_grade_level
      ,max_grade_level
      ,int_min_grade
      ,int_max_grade
      ,row_num_asc
      ,row_num_desc
      ,fl_multiple_primaryschool
      ,fl_prm_txfr
      ,fl_prm_txfr_inter
      ,fl_prm_txfr_intra
      ,fl_other_txfr
      ,fl_other_txfr_inter
      ,fl_other_txfr_intra
      ,overall_txfr_rank
      ,prom_txfr_rank
      ,other_txfr_rank
      ,enrollment_duration
      ,approx_age_enroll_start
      ,approx_age_enroll_end
      ,MonthYearBirth
      ,fl_delete
from  ##curr
where new_exit_date >= dateEnrolledInschool 
go


--resort records
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
---update where there is a next record for the same student but enrollment years don't match and enrollment end date = '12/31/3999'
update curr
set DateExitedFromSchool = 
	case when dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112))) < nxt.DateEnrolledInSchool
	then dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112)))
	else DateAdd(dd,-1,nxt.DateEnrolledInSchool) end
	,EnrollmentStatuS=case when curr.EnrollmentStatus in ('E0','P1') then 'FE' else curr.EnrollmentStatus end
from ospi.temp curr
join ospi.temp nxt 
	on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
where curr.DateExitedFromSchool> nxt.DateEnrolledInSchool	
	--and curr.schoolCode=nxt.SchoolCode
	and curr.DateExitedFromSchool='12/31/3999'
	and case when dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112))) < nxt.DateEnrolledInSchool
	then dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(curr.last_enr_mnth as char(6)) + '01',112)))
	else DateAdd(dd,-1,nxt.DateEnrolledInSchool) end >=curr.DateEnrolledInSchool
	--and nxt.DateExitedFromSchool='12/31/3999'
	--and curr.last_enr_mnth < nxt.frst_enr_mnth
go	
select * from ospi.temp where DateExitedFromSchool < DateEnrolledInSchool	

update ospi.temp
set enrollmentstatus='FE'
    ,DateExitedFromSchool=dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(last_enr_mnth as char(6)) + '01',112)))
where last_enr_mnth <=200908 and DateExitedFromSchool='12/31/3999'
and dateadd(dd,-1,dateadd(mm,1,convert(datetime,cast(last_enr_mnth as char(6)) + '01',112))) >= DateEnrolledInSchool
		


/**
drop table ospi_thru_3
select * into ospi_thru_3 from ospi.temp 



select * from ospi.temp  where int_researchID=993219 order by int_researchID,row_num_asc

select * from ospi.temp where int_researchID=8 order by int_researchID,row_num_asc


truncate table ospi.temp
insert into ospi.temp
select * from ospi.temp_all

**/

update enr
set DateEnrolledInDistrict='2006-08-05'
	,DateEnrolledInSchool='2006-08-05'
from ospi.temp enr
where int_researchID=170806 and DateEnrolledInSchool='3020-08-05 00:00:00.000'

update enr
set DateEnrolledInSchool='2007-11-26 00:00:00.000'
from ospi.temp enr
where int_researchID=1367240 and DateEnrolledInSchool='2207-11-26 00:00:00.000'

update enr
set DateEnrolledInDistrict='2008-02-21 00:00:00.000'
	,DateEnrolledInSchool='2008-02-21 00:00:00.000'
from ospi.temp enr
where int_researchID=1445257 and DateEnrolledInSchool='2208-02-21 00:00:00.000'


update enr
set DateEnrolledInSchool='2005-09-06 00:00:00.000'
from ospi.temp enr
where int_researchID=751268 and DateEnrolledInSchool='2205-09-06 00:00:00.000'

update enr
set DateEnrolledInSchool='2009-03-23 00:00:00.000'
from ospi.temp enr
where int_researchID=102532 and DateEnrolledInSchool='3009-03-23 00:00:00.000'

-- resort rows
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

select * into ospi.temp_thru_3 from ospi.temp