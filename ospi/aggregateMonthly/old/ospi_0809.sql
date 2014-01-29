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
set @schoolyearend = 2009
set @yrMonth =(@schoolyearend - 1) * 100 + 8
set @prevMonth=@yrMonth-1
set @stop_yrMonth=@yrMonth + 100
set @yearenddate=convert(datetime,cast(@stop_yrMonth as varchar(6)) + '31',112)


set @loop=1
set @loopStop=13


if object_ID('tempDB..##myTbl9') is not null drop table ##myTbl9
create table ##myTbl9(int_researchID int not null
						, DistrictID int not null
						, SchoolCode int not null
						, DateEnrolledInDistrict datetime not null
						, DateExitedFromDistrict datetime not null
						, DateEnrolledInSchool datetime not null
						, DateExitedFromSchool datetime not null
						, EnrollmentStatuS char(2)
						, frst_enr_mnth int
						, last_enr_mnth int
						, min_grade_level char(2)
						, max_grade_level char(2) 
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
						, primary key (int_researchID,DistrictID,SchoolCode,DateEnrolledInSchool,DateExitedFromSchool))




CREATE NONCLUSTERED INDEX idx_myTbl_DateExitedFromSchool_3_inc_3
ON ##myTbl9 ([DateExitedFromSchool],[last_enr_mnth],[DateEnrolledInSchool])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode])


CREATE NONCLUSTERED INDEX idx_myTbl_EnrollmentStatuS
ON ##myTbl9  ([EnrollmentStatuS])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode],[DateEnrolledInSchool],[DateExitedFromSchool])

while @loop <=@loopStop
begin


		
		-- insert NEW records						
		insert into ##myTbl9 (int_researchID,DistrictID,SchoolCode,DateEnrolledInDistrict
					,DateExitedFromDistrict
					,DateEnrolledInSchool
					,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,MonthYearBirth)
		select    nw.int_researchID
				, nw.DistrictCode as DistrictID
				, nw.SchoolCode
				, nw.DateEnrolledInDistrict
				, coalesce(nw.DateExitedFromDistrict,@yearenddate)
				, nw.DateEnrolledInSchool
				, nw.Date_Exit
				, nw.EnrollmentStatuS
				, @yrMonth
				, @yrMonth
				, cast(right(nw.dob,4) as int) * 100 + cast(left(nw.dob,2) as int)
		from  (select osp.*
					, isnull(DateExitedFromSchool,@yearenddate) as Date_Exit 
					, sch.int_schooltype
					, row_number() 
						over (
							partition by int_researchID ,DateEnrolledInSchool
							--partition by int_researchID ,DistrictCode,osp.SchoolCode,DateEnrolledInSchool
							order by int_researchID
										--,DistrictCode
										--,SchoolCode
										,DateEnrolledInSchool asc
										,isnull(DateExitedFromSchool,@yearenddate) asc
										, sch.int_schooltype asc
										) as row_num
					from ospi.OSPI_0809 osp
					join ospi.school_dim sch on sch.schoolcode=osp.schoolcode
					where yrmonth=@yrMonth
						and primarySchool=1
						and isnull(DateExitedFromSchool,'12/31/3999') >  DateEnrolledInSchool
					) nw  
		left join ##myTbl9 enr 
			on enr.int_researchID=nw.int_researchID
			and enr.districtID=nw.districtcode
			and enr.schoolcode=nw.schoolcode
			and enr.last_enr_mnth <= case when @loop=1 then @yrMonth else @prevMonth end
			and enr.DateEnrolledInSchool =nw.DateEnrolledInSchool
		where nw.row_num = 1 and enr.int_researchID is null;
		
		if @loop > 1
		begin 

				
--update all those with a record next month for the same school and district that have an exit.
-- also if the district  enrollment date is earlier than preceding month update that also

				update ospi
				set last_enr_mnth=@yrMonth
					,DateEnrolledInDistrict=case when nxt.DateEnrolledInDistrict < ospi.DateEnrolledInDistrict then nxt.DateEnrolledInDistrict else ospi.DateEnrolledInDistrict end
					,DateExitedFromDistrict=isnull(nxt.DateExitedFromDistrict,@yearenddate)
					,DateExitedFromSchool=case when nxt.Date_Exit < @yearenddate
												then nxt.Date_Exit else ospi.DateExitedFromSchool end
					,EnrollmentStatus=case when nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool then nxt.EnrollmentStatus else ospi.EnrollmentStatus end
				from ##myTbl9 ospi
				join (select *, isnull(DateExitedFromSchool,@yearenddate) as Date_Exit,row_number() 
								over (
									partition by int_researchID 
										,DistrictCode
										,SchoolCode
										,DateEnrolledInSchool
									order by int_researchID
											,DistrictCode
											,SchoolCode
											,DateEnrolledInSchool
											,isnull(DateExitedFromSchool,@yearenddate) asc
									) as row_num
						from ospi.OSPI_0809
						where yrmonth=@yrMonth
							and primarySchool=1
							and isnull(DateExitedFromSchool,'12/31/3999') >  DateEnrolledInSchool
						) nxt on  nxt.int_researchID=ospi.int_researchID 
							and nxt.DistrictCode=ospi.DistrictID
							and nxt.SchoolCode=ospi.SchoolCode
							and nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool
							and nxt.row_num=1
				where last_enr_mnth=@prevMonth --and nxt.Date_Exit < @yearenddate
								
--update EXITS for transferred schools that have primaryschool=0 for the next month to end date
				update ospi
				set  DateExitedFromSchool=case when nxt.Date_Exit < @yearenddate then nxt.date_Exit else ospi.DateExitedFromSchool  end
					,EnrollmentStatus=nxt.EnrollmentStatus
					,DateExitedFromDistrict=case when nxt.DateExitedFromDistrict < @yearenddate then nxt.DateExitedFromDistrict 
					else ospi.DateExitedFromDistrict end
				--select sep.DateEnrolledInSchool,sep.DateExitedFromSchool,ospi.*
				from ##myTbl9 ospi
				 join (select *, isnull(DateExitedFromSchool,@yearenddate) as Date_Exit,row_number() 
								over (
									partition by int_researchID 
											,DistrictCode
											,SchoolCode
											,DateEnrolledInSchool
									order by int_researchID
											,DistrictCode
											,SchoolCode
											,DistrictCode
											,DateEnrolledInSchool asc
											,isnull(DateExitedFromSchool,@yearenddate) asc) as row_num
							from ospi.OSPI_0809
							where yrmonth=@yrMonth
								and primarySchool=0
								and isnull(DateExitedFromSchool,'12/31/3999') >  DateEnrolledInSchool
							) nxt on  nxt.int_researchID=ospi.int_researchID 
								and nxt.SchoolCode=ospi.SchoolCode
								and nxt.DistrictCode=ospi.DistrictID
								and ospi.DateEnrolledInSchool=nxt.DateEnrolledInSchool
								and nxt.row_num=1
				where  ospi.DateExitedFromSchool =@yearenddate
				and ospi.last_enr_mnth=@prevMonth
				and @yrMonth<>@stop_yrMonth	
				
									
--update EXITS for those NOT in the NEXT Month
				--for those who do NOT have a record in next month we want to force an exit
				update ospi
				set  DateExitedFromSchool=dateadd(dd,-1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime))
					,EnrollmentStatus='FE' -- force Exit
				--select sep.DateEnrolledInSchool,sep.DateExitedFromSchool,ospi.*
				from ##myTbl9 ospi
				left join (select *
								, isnull(DateExitedFromSchool,@yearenddate) as Date_Exit
								, row_number() 
								over (
									partition by 
										int_researchID
										,DistrictCode
										,SchoolCode
										,DateEnrolledInSchool
									order by int_researchID
											,DistrictCode
											,SchoolCode
											,DateEnrolledInSchool asc
											,isnull(DateExitedFromSchool,@yearenddate) asc) as row_num
							from ospi.OSPI_0809
							where yrmonth=@yrMonth
								and primarySchool=1
							) nxt on  nxt.int_researchID=ospi.int_researchID 
								and nxt.SchoolCode=ospi.SchoolCode
								and nxt.DistrictCode=ospi.DistrictID
								--and nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool
								and nxt.row_num=1
				where nxt.int_researchID is null
				and ospi.DateExitedFromSchool =@yearenddate
				and ospi.last_enr_mnth=@prevMonth
				and dateadd(dd,-1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime)) > ospi.DateEnrolledInSchool
				and @yrMonth<>@stop_yrMonth		
		
								

				

		end
								
				
		update statistics ##myTbl9;
		set @loop=@loop + 1;
		--print str(@yrMonth)
		set @prevMonth=@yrMonth
		set @yrMonth=year(dateadd(mm,1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime))) * 100 + month(dateadd(mm,1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime)))
		
		
end
------------------------------------------------------------------------------------- update grade level
update MTB
set max_grade_level=q.GradeLevel 
from ##myTbl9 MTB
join (
		select 
		  my.int_researchID
		, my.schoolcode
		, my.DistrictCode
		, my.DateEnrolledInSchool
		, coalesce(my.DateExitedFromSchool,@yearenddate) as DateExitedFromSchool
		, GradeLevel
		, yrmonth
		, case when GradeLevel = 'PK' then -2
				when GradeLevel='K1' then -1
				when GradeLevel='K2' then 0
				else cast(GradeLevel as int) end as int_GradeLevel
		, row_number() over (partition by my.int_researchID,my.DistrictCode,my.schoolcode,my.DateEnrolledInSchool
			order by my.int_researchID,my.DistrictCode,my.schoolcode,DateEnrolledInSchool
					,case when GradeLevel = 'PK' then -2
						when GradeLevel='K1' then -1
						when GradeLevel='K2' then 0
						else cast(GradeLevel as int) end  desc) as row_num
		from ospi.OSPI_0809 my
		where primaryschool=1 
		--	and int_researchID=78840--993219
		--order by my.int_researchID,my.schoolcode,my.DateExitedFromSchool,my.DateEnrolledInSchool	
		) q 	on (q.row_num=1  )
				and q.int_researchID=MTB.int_researchID
				and q.schoolCode=MTB.SchoolCode
				and q.DistrictCode=MTB.districtID
				and q.DateEnrolledInSchool=MTB.DateEnrolledInSchool
				
update MTB
set min_grade_level=q.GradeLevel 
from ##myTbl9 MTB
join (
		select 
		  my.int_researchID
		, my.schoolcode
		, my.DistrictCode
		, my.DateEnrolledInSchool
		, coalesce(my.DateExitedFromSchool,@yearenddate) as DateExitedFromSchool
		, GradeLevel
		, yrmonth
		, case when GradeLevel = 'PK' then -2
				when GradeLevel='K1' then -1
				when GradeLevel='K2' then 0
				else cast(GradeLevel as int) end as int_GradeLevel		
		, row_number() over (partition by my.int_researchID,my.DistrictCode,my.schoolcode,my.DateEnrolledInSchool
			order by my.int_researchID,my.DistrictCode,my.schoolcode,DateEnrolledInSchool
			,case when GradeLevel = 'PK' then -2
						when GradeLevel='K1' then -1
						when GradeLevel='K2' then 0
						else cast(GradeLevel as int) end asc) as row_num
		from ospi.OSPI_0809 my
		where primaryschool=1 
		--order by my.int_researchID,my.schoolcode,my.DateExitedFromSchool,my.DateEnrolledInSchool	
		) q 	on (q.row_num=1  )
				and q.int_researchID=MTB.int_researchID
				and q.schoolCode=MTB.SchoolCode
				and q.DistrictCode=MTB.districtID				
				and q.DateEnrolledInSchool=MTB.DateEnrolledInSchool
				

				
-----------------------------------------------------------------------------------------  Clean up District Dates
update MTB
set DateEnrolledInDistrict=DateEnrolledInSchool
--select *
from ##myTbl9 MTB
where DateEnrolledInDistrict > DateExitedFromDistrict


update MTB
set DateExitedFromDistrict=DateExitedFromSchool
--select *
from ##myTbl9 MTB
where DateEnrolledInDistrict > DateExitedFromDistrict

UPDATE MTB
set MTB.DateEnrolledInDistrict=q.DateEnrolledInDistrict
From ##myTbl9 MTB
join (
	 select int_researchID,count(distinct DistrictCode) as district_cnt
			from ospi.OSPI_0809
			where primaryschool=1
			group by int_researchID 
	) q2 on q2.int_researchID=mtb.int_researchID
join (
		select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
		  , row_number() over (partition by int_researchID,ot.districtID
								order by int_researchID,ot.districtID,DateEnrolledInDistrict asc) as frst_date
		 from ##myTbl9 ot
		) q on q.int_researchID=mtb.int_researchID
				and q.districtID=mtb.districtID
				and q.frst_date=1 
	where q2.district_cnt=1 
	
UPDATE MTB
set MTB.DateExitedFromDistrict=q.DateExitedFromDistrict
From ##myTbl9 MTB
join (
	 select int_researchID,count(distinct DistrictCode) as district_cnt
			from ospi.OSPI_0809
			where primaryschool=1
			group by int_researchID 
	) q2 on q2.int_researchID=mtb.int_researchID
join (
		select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
		  , row_number() over (partition by int_researchID,ot.districtID
								order by int_researchID,ot.districtID,DateExitedFromDistrict desc) as frst_date
		 from ##myTbl9 ot
		) q on q.int_researchID=mtb.int_researchID
				and q.districtID=mtb.districtID
				and q.frst_date=1 
	where q2.district_cnt=1 

------------------------------------------------------update exit dates  where there is a school change
update MTB
set DateExitedFromSchool=q2.DateEnrolledInSchool
--select q2.schoolcode,q2.DateEnrolledInSchool,MTB.*
from ##myTbl9 MTB
join (select *
		,row_number() over 
		(  partition by int_researchID
			order by int_researchID,DateEnrolledInSchool ) as row_num
	   from ##myTbl9
	   -- where int_researchID=993219 
	   ) q
	   on q.int_ResearchID=MTB.int_researchID 
		and q.schoolcode=MTB.schoolcode
		and q.DistrictID=MTB.DistrictID
		and q.DateEnrolledInSchool=MTB.DateEnrolledInSchool
		and q.DateExitedFromSchool=MTB.DateExitedFromSchool
join (select *
		,row_number() over 
		(  partition by int_researchID
			order by int_researchID,DateEnrolledInSchool ) as row_num
	   from ##myTbl9
	   -- where int_researchID=993219 
	   ) q2
	   on q.int_ResearchID=q2.int_researchID
		and q.row_num +1=q2.row_num
Where q.SchoolCode <> q2.SchoolCode
	and q.DateExitedFromSchool > q2.DateEnrolledInSchool
	 --and q.int_researchID=993219   
	 --and q.EnrollmentStatus='FE'
	 

-- delete entry exit same day for forced exits
--delete
--from ##myTbl9 
--where DateEnrolledInSchool=DateExitedFromSchool
--and EnrollmentStatus='FE'


if object_ID(N'ospi.Enrollment_2009',N'U') is not null drop table ospi.Enrollment_2009
select * ,cast(null as int) as row_num into ospi.Enrollment_2009 from ##myTbl9 


ALTER TABLE [ospi].Enrollment_2009 ADD  CONSTRAINT [PK_ospi_ye2009] PRIMARY KEY CLUSTERED 
(
	[int_researchID] ASC,
	[DistrictID] ASC,
	[SchoolCode] ASC,
	[DateEnrolledInSchool] ASC,
	[DateExitedFromSchool] ASC
)
	
	

update tmp
set row_num = curr.row_sort
from ospi.enrollment_2009  tmp
join (
     select *,row_number() over (
			partition by int_researchID 
			order by int_researchID,DateEnrolledInSchool,DateExitedFromSchool ) as row_sort
		from ospi.enrollment_2009
		) curr on curr.int_researchID=tmp.int_researchID
			and curr.districtID=tmp.districtID
			and curr.schoolcode=tmp.schoolcode
			and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and curr.DateExitedFromSchool=tmp.DateExitedFromSchool