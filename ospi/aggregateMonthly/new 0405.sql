--  Assumptions
-- 1  IGNORE records where DateEnrolledInSchool>=DateExitedFromSchool
-- 2 USE PRIMARY SCHOOL = 1 RECORDS ONLY
-- 3 Choose Multiple School Types by selecting the Minimum School Type
declare @yrMonth int
declare @stop_yrMonth int
declare @prevMonth int
declare @loopStop int
declare @loop int
declare @schoolyearend int
declare @yearenddate datetime
set @schoolyearend = 2005
set @yrMonth =(@schoolyearend - 1) * 100 + 8
set @prevMonth=@yrMonth-1
set @stop_yrMonth=@yrMonth + 100
set @yearenddate=convert(datetime,cast(@stop_yrMonth as varchar(6)) + '31',112)


set @loop=1
set @loopStop=13


if object_ID('tempDB..#myTbl') is not null drop table #myTbl
create table #myTbl(int_researchID int not null
						, DistrictID int not null
						, SchoolCode int not null
						, DateEnrolledInDistrict datetime  null
						, DateExitedFromDistrict datetime  null
						, DateEnrolledInSchool datetime not null
						, DateExitedFromSchool datetime not null
						, EnrollmentStatuS char(2)
						, frst_enr_mnth int
						, last_enr_mnth int
						, min_grade_level char(2)
						, max_grade_level char(2) 
						, int_min_grade int
						, int_max_grade int
						, row_num_asc int
						, row_num_desc int
						, fl_multiple_primaryschool int
						, fl_prm_txfr smallint default 0
						, fl_prm_txfr_inter smallint default 0
						, fl_prm_txfr_intra smallint default 0
						, fl_other_txfr smallint default 0
						, fl_other_txfr_inter smallint default 0
						, fl_other_txfr_intra smallint default 0
						, overall_txfr_rank int default 0
						, prom_txfr_rank int default 0
						, other_txfr_rank int default 0
						, enrollment_duration int default 0
						, approx_age_enroll_start int default 0
						, approx_age_enroll_end int default 0
						, MonthYearBirth int default 0
						, fl_delete int not null default 0
						, primary key (int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool))




CREATE NONCLUSTERED INDEX idx_myTbl_DateExitedFromSchool_3_inc_3
ON #myTbl ([DateExitedFromSchool],[last_enr_mnth],[DateEnrolledInSchool])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode])


CREATE NONCLUSTERED INDEX idx_myTbl_EnrollmentStatuS
ON #myTbl  ([EnrollmentStatuS])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode],[DateEnrolledInSchool],[DateExitedFromSchool])


		
		-- insert NEW records						
		insert into #myTbl (int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,row_num_asc
					,row_num_desc
					,fl_multiple_primaryschool
					)
		select    nw.int_researchID
				, nw.DistrictCode as DistrictID
				, nw.SchoolCode
				--, nw.DateEnrolledInDistrict
				--, coalesce(nw.DateExitedFromDistrict,@yearenddate)
				, nw.DateEnrolledInSchool
				, min(coalesce(nw.DateExitedFromSchool,'12/31/3999')) 
				, min(case when isnumeric(gradelevel) = 1
						then cast(gradelevel as int)
						when gradelevel='PK' then -2
						when gradelevel='K1' then -1
						when gradelevel='K2' then 0 end)
				, max(case when isnumeric(gradelevel) = 1
						then cast(gradelevel as int)
						when gradelevel='PK' then -2
						when gradelevel='K1' then -1
						when gradelevel='K2' then 0 end)
				, min(yrmonth)
				, max(yrmonth)
				, 0
				, 0
				, 0
		from ospi.OSPI_0405 nw
		where primarySchool=1
		and coalesce(nw.DateExitedFromSchool,'12/31/3999') > nw.DateEnrolledInSchool
		group by nw.int_researchID
				, nw.DistrictCode 
				, nw.SchoolCode
				, nw.DateEnrolledInSchool
				
-- update missing fields from last record
update my
set MonthYearBirth= cast(right(q.dob,4) as int) * 100 + cast(left(q.dob,2) as int)
	,EnrollmentStatus=q.EnrollmentStatus
	,DateEnrolledInDistrict=q.DateEnrolledInDistrict
	,DateExitedFromDistrict=q.DateExitedFromDistrict
from #myTbl my 
join ospi.ospi_0405 q
on q.yrmonth=my.last_enr_mnth
	and q.int_researchID=my.int_researchID
			and q.DistrictCode=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
	
	
update	 my
set min_grade_level=case when int_min_grade > 0 then cast(int_min_grade as varchar(2))
							when int_min_grade=0 then 'K2'
							when int_min_grade=-1 then 'K1'
							when int_min_grade=-2 then 'PK' end

	,max_grade_level=case when int_max_grade > 0 then cast(int_max_grade as varchar(2))
							when int_max_grade=0 then 'K2'
							when int_max_grade=-1 then 'K1'
							when int_max_grade=-2 then 'PK' end						
from #myTbl my 				

--flag multiple schools				
update my
set fl_multiple_primaryschool = 1
from #myTbl my
join (					  
	select int_researchID,DateEnrolledInSchool,count(*) as cnt
	 from #myTbl
	 group by int_researchID,DateEnrolledInSchool
	 having count(*) > 1 ) q on q.int_researchID=my.int_researchID
		and my.DateEnrolledInSchool=q.DateEnrolledInSchool
			 

	update my
	set row_num_asc = q.row_num_asc
	from #myTbl my		
	join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
				,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
			,row_number() over (partition by int_researchID
									order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
			from #myTbl
			) q on q.int_researchID=my.int_researchID
				and q.DistrictID=my.DistrictID
				and q.SchoolCode=my.SchoolCode
				and q.DateEnrolledInSchool=my.DateEnrolledInSchool
				and q.DateExitedFromSchool=my.DateExitedFromSchool
			
			
	update curr
	set fl_delete = 1
	from #myTbl curr
	join #myTbl nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
			and nxt.fl_multiple_primaryschool=1
	where curr.fl_multiple_primaryschool=1
	and curr.frst_enr_mnth=curr.last_enr_mnth

	update nxt
	set fl_multiple_primaryschool = 0
	from #myTbl curr
	join #myTbl nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
			and nxt.fl_multiple_primaryschool=1
	where curr.fl_multiple_primaryschool=1
	and curr.frst_enr_mnth=curr.last_enr_mnth
	
	
	delete from 	#myTbl where fl_delete = 1
-- update row_num sort asc

update my
set row_num_asc = q.row_num_asc
	,row_num_desc=q.row_num_desc
from #myTbl my		
join (select int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool
			,int_min_grade,int_max_grade,frst_enr_mnth,last_enr_mnth,fl_multiple_primaryschool
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool asc,DateExitedFromSchool asc) as row_num_asc
		,row_number() over (partition by int_researchID
								order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool desc) as row_num_desc								
		from #myTbl
		) q on q.int_researchID=my.int_researchID
			and q.DistrictID=my.DistrictID
			and q.SchoolCode=my.SchoolCode
			and q.DateEnrolledInSchool=my.DateEnrolledInSchool
			and q.DateExitedFromSchool=my.DateExitedFromSchool
			
			
if object_ID(N'ospi.Enrollment_2005',N'U') is not null drop table ospi.Enrollment_2005
select *  into ospi.Enrollment_2005 from #myTbl 


ALTER TABLE [ospi].Enrollment_2005 ADD  CONSTRAINT [PK_ospi_ye2005] PRIMARY KEY CLUSTERED 
(
	[int_researchID] ASC,
	[DistrictID] ASC,
	[SchoolCode] ASC,
	[DateEnrolledInSchool] ASC,
	[DateExitedFromSchool] ASC
)		
			



