--  Assumptions
-- 1  IGNORE records where DateEnrolledInSchool>=DateExitedFromSchool
-- 2 USE PRIMARY SCHOOL = 1 RECORDS ONLY
-- 3 Choose Multiple School Types by selecting the Minimum School Type
declare @yrMonth int
declare @stop_yrMonth int
declare @nxtMonth int
set @yrMonth =200408
set @nxtMonth = @yrMonth + 1;
set @stop_yrMonth=200507

---   if object_ID('tempDB..##ospi') is not null drop table ##ospi
if object_ID('tempDB..##ospi') is null 
create table ##ospi(int_researchID int not null
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


if object_ID('tempDB..##myTbl') is not null drop table ##myTbl
create table ##myTbl(int_researchID int not null
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


			
-- insert August Records records						
insert into ##myTbl (int_researchID,DistrictID,SchoolCode,DateEnrolledInDistrict
			,DateExitedFromDistrict
			,DateEnrolledInSchool
			,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
			,MonthYearBirth)
select    nw.int_researchID
		, nw.DistrictCode as DistrictID
		, nw.SchoolCode
		, nw.DateEnrolledInDistrict
		, coalesce(nw.DateExitedFromDistrict,'12/31/3999')
		, nw.DateEnrolledInSchool
		, nw.Date_Exit
		, nw.EnrollmentStatuS
		, @yrMonth
		, @yrMonth
		, cast(right(nw.dob,4) as int) * 100 + cast(left(nw.dob,2) as int)
from  (select osp.*
			, isnull(DateExitedFromSchool,'12/31/3999') as Date_Exit 
			, sch.int_schooltype
			, row_number() 
				over (
					partition by int_researchID ,DateEnrolledInSchool
					--partition by int_researchID ,DistrictCode,osp.SchoolCode,DateEnrolledInSchool
					order by int_researchID
								--,DistrictCode
								--,SchoolCode
								,DateEnrolledInSchool asc
								,isnull(DateExitedFromSchool,'12/31/3999') asc
								, sch.int_schooltype asc
								) as row_num
			from dbo.OSPI_0405 osp
			join ospi_school sch on sch.schoolcode=osp.schoolcode
			where yrmonth=@yrMonth
				and primarySchool=1
				and isnull(DateExitedFromSchool,'12/31/3999') >  DateEnrolledInSchool
			) nw  
--left join ##ospi enr 
--	on enr.int_researchID=nw.int_researchID
--	and enr.districtID=nw.districtcode
--	and enr.schoolcode=nw.schoolcode
--	and enr.enrollment_date=nw.enrollment_date
where nw.row_num = 1
		--and enr.int_researchID is null;
		
	

CREATE NONCLUSTERED INDEX idx_myTbl_DateExitedFromSchool_3_inc_3
ON ##myTbl ([DateExitedFromSchool],[last_enr_mnth],[DateEnrolledInSchool])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode])


CREATE NONCLUSTERED INDEX idx_myTbl_EnrollmentStatuS
ON ##myTbl  ([EnrollmentStatuS])
INCLUDE ([int_researchID],[DistrictID],[SchoolCode],[DateEnrolledInSchool],[DateExitedFromSchool])

while @yrMonth <=@stop_yrMonth
begin
		--update all that have a record next month for the same school and district.
		-- also if the district  enrollment date is earlier than preceding month update that also
		-- update the rows for exits
		-- if they have the same enrollment date
		--  we don't want to add the record only update the exit and enrollment status
		update ospi
		set last_enr_mnth=@nxtMonth
			,DateEnrolledInDistrict=case when nxt.DateEnrolledInDistrict < ospi.DateEnrolledInDistrict then nxt.DateEnrolledInDistrict else ospi.DateEnrolledInDistrict end
			,DateExitedFromDistrict=isnull(nxt.DateExitedFromDistrict,'12/31/3999')
			,DateExitedFromSchool=case when nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool 
									and nxt.Date_Exit < '12/31/3999'
										then nxt.Date_Exit else ospi.DateExitedFromSchool end
			,EnrollmentStatus=case when nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool then nxt.EnrollmentStatus else ospi.EnrollmentStatus end
		from ##myTbl ospi
		join (select *, isnull(DateExitedFromSchool,'12/31/3999') as Date_Exit,row_number() 
						over (
							partition by int_researchID 
								,DistrictCode
								,SchoolCode
								,DateEnrolledInSchool
							order by int_researchID
									,DistrictCode
									,SchoolCode
									,DateEnrolledInSchool asc
									,isnull(DateExitedFromSchool,'12/31/3999') asc) as row_num
				from dbo.OSPI_0405
				where yrmonth=@nxtMonth
					and primarySchool=1
					and isnull(DateExitedFromSchool,'12/31/3999') > DateEnrolledInSchool
				) nxt on  nxt.int_researchID=ospi.int_researchID 
					and nxt.DistrictCode=ospi.DistrictID
					and nxt.SchoolCode=ospi.SchoolCode
					--and nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool
					and nxt.row_num=1
		where last_enr_mnth=@yrMonth
								
						
						
		
						
		--update EXITS for transferred schools .... some have primaryschool=0 for the next month to end date
		update ospi
		set  DateExitedFromSchool=nxt.Date_Exit
			,EnrollmentStatus=nxt.EnrollmentStatus
			,DateExitedFromDistrict=case when nxt.DateExitedFromDistrict < '12/31/3999' then nxt.DateExitedFromDistrict 
			else ospi.DateExitedFromDistrict end
		--select sep.DateEnrolledInSchool,sep.DateExitedFromSchool,ospi.*
		from ##myTbl ospi
		 join (select *, isnull(DateExitedFromSchool,'12/31/3999') as Date_Exit,row_number() 
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
									,isnull(DateExitedFromSchool,'12/31/3999') asc) as row_num
					from dbo.OSPI_0405
					where yrmonth=@nxtMonth
						and primarySchool=0
						and isnull(DateExitedFromSchool,'12/31/3999') > DateEnrolledInSchool
					) nxt on  nxt.int_researchID=ospi.int_researchID 
						and nxt.SchoolCode=ospi.SchoolCode
						and nxt.DistrictCode=ospi.DistrictID
						and ospi.DateEnrolledInSchool=nxt.DateEnrolledInSchool
						and nxt.row_num=1
		where  ospi.DateExitedFromSchool ='12/31/3999'
		and ospi.last_enr_mnth=@yrMonth
		and @yrMonth<>@stop_yrMonth
		
		--update EXITS for those NOT in the NEXT Month
		--for those who do NOT have a record in next month we want to force an exit
		update ospi
		set  DateExitedFromSchool=dateadd(dd,-1,cast(convert(varchar(10),cast(@nxtMonth as varchar(6)) + '01',112) as datetime))
			,EnrollmentStatus='FE' -- force Exit
		--select sep.DateEnrolledInSchool,sep.DateExitedFromSchool,ospi.*
		from ##myTbl ospi
		left join (select *
						, isnull(DateExitedFromSchool,'12/31/3999') as Date_Exit
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
									,isnull(DateExitedFromSchool,'12/31/3999') asc) as row_num
					from dbo.OSPI_0405
					where yrmonth=@nxtMonth
						and primarySchool=1
					) nxt on  nxt.int_researchID=ospi.int_researchID 
						and nxt.SchoolCode=ospi.SchoolCode
						and nxt.DistrictCode=ospi.DistrictID
						and nxt.DateEnrolledInSchool=ospi.DateEnrolledInSchool
						and nxt.row_num=1
		where nxt.int_researchID is null
		and ospi.DateExitedFromSchool ='12/31/3999'
		and ospi.last_enr_mnth=@yrMonth
		and dateadd(dd,-1,cast(convert(varchar(10),cast(@nxtMonth as varchar(6)) + '01',112) as datetime)) > ospi.DateEnrolledInSchool
		and @yrMonth<>@stop_yrMonth
		
								
		--insert new ones that are NOT in myTbl with prior month	
		--since we updated all those with lst_enr_dt to next month we will match on this.			
						
		insert into ##myTbl (
			 int_researchID
			,DistrictID
			,SchoolCode
			,DateEnrolledInDistrict
			,DateExitedFromDistrict
			,DateEnrolledInSchool
			,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
			,MonthYearBirth
			)
		select  distinct
				  nw.int_researchID
				, nw.DistrictCode as DistrictID
				, nw.SchoolCode
				, nw.DateEnrolledInDistrict
				, coalesce(nw.DateExitedFromDistrict,'12/31/3999')
				, nw.DateEnrolledInSchool
				, nw.Date_Exit
				, nw.EnrollmentStatuS
				, @nxtMonth
				, @nxtMonth
				, cast(right(nw.dob,4) as int) * 100 + cast(left(nw.dob,2) as int)
		--select *		
		from 
		 (select osp.*, isnull(DateExitedFromSchool,'12/31/3999') as Date_Exit 
				, sch.int_schooltype
				, row_number() 
						over (
							partition by int_researchID ,DateEnrolledInSchool
							--partition by int_researchID ,DistrictCode,osp.SchoolCode,DateEnrolledInSchool
							order by int_researchID
										--,DistrictCode
										--,SchoolCode
										,DateEnrolledInSchool asc
										,isnull(DateExitedFromSchool,'12/31/3999') asc
										, sch.int_schooltype asc) as row_num
					from dbo.OSPI_0405 osp
					join ospi_school sch on sch.schoolcode=osp.schoolcode
					where yrmonth=@nxtMonth
					and primarySchool=1
					--and int_researchID=1597016
					and isnull(DateExitedFromSchool,'12/31/3999') >  DateEnrolledInSchool
					) nw 
		left join ##myTbl mt 
		on mt.int_researchID=nw.int_researchID
			and mt.DistrictID=nw.DistrictCode
			and mt.SchoolCode=nw.SchoolCode
			and mt.DateEnrolledInSchool = nw.DateEnrolledInSchool
			--and mt.DateExitedFromSchool=nw.Date_Exit
			--and mt.DateExitedFromSchool is null
			--and mt.DateEnrolledInDistrict=nw.DateEnrolledInDistrict
			--and mt.DateEnrolledInSchool=nw.DateEnrolledInSchool
		where  nw.row_num = 1 
				and  mt.int_researchID is null							

			
		update statistics ##myTbl
		--print str(@yrMonth)
		set @yrMonth=year(dateadd(mm,1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime))) * 100 + month(dateadd(mm,1,cast(convert(varchar(10),cast(@yrMonth as varchar(6)) + '01',112) as datetime)))
		set @nxtMonth=year(dateadd(mm,1,cast(convert(varchar(10),cast(@nxtMonth as varchar(6)) + '01',112) as datetime))) * 100 + month(dateadd(mm,1,cast(convert(varchar(10),cast(@nxtMonth as varchar(6)) + '01',112) as datetime)))
		
end
----------------------------------------------------------------------------------- update grade level
update MTB
set max_grade_level=q.GradeLevel 
from ##MYTBL MTB
join (
		select 
		  my.int_researchID
		, my.schoolcode
		, my.DistrictCode
		, my.DateEnrolledInSchool
		, coalesce(my.DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool
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
		from OSPI_0405 my
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
from ##MYTBL MTB
join (
		select 
		  my.int_researchID
		, my.schoolcode
		, my.DistrictCode
		, my.DateEnrolledInSchool
		, coalesce(my.DateExitedFromSchool,'12/31/3999') as DateExitedFromSchool
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
		from OSPI_0405 my
		where primaryschool=1 
		--order by my.int_researchID,my.schoolcode,my.DateExitedFromSchool,my.DateEnrolledInSchool	
		) q 	on (q.row_num=1  )
				and q.int_researchID=MTB.int_researchID
				and q.schoolCode=MTB.SchoolCode
				and q.DistrictCode=MTB.districtID				
				and q.DateEnrolledInSchool=MTB.DateEnrolledInSchool
				

				
---------------------------------------------------------------------------------------  Clean up District Dates
update MTB
set DateEnrolledInDistrict=DateEnrolledInSchool
--select *
from ##MYTBL MTB
where DateEnrolledInDistrict > DateExitedFromDistrict


update MTB
set DateExitedFromDistrict=DateExitedFromSchool
--select *
from ##MYTBL MTB
where DateEnrolledInDistrict > DateExitedFromDistrict

UPDATE MTB
set MTB.DateEnrolledInDistrict=q.DateEnrolledInDistrict
From ##myTbl MTB
join (
	 select int_researchID,count(distinct DistrictCode) as district_cnt
			from OSPI_0405
			where primaryschool=1
			group by int_researchID 
	) q2 on q2.int_researchID=mtb.int_researchID
join (
		select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
		  , row_number() over (partition by int_researchID,ot.districtID
								order by int_researchID,ot.districtID,DateEnrolledInDistrict asc) as frst_date
		 from ##myTbl ot
		) q on q.int_researchID=mtb.int_researchID
				and q.districtID=mtb.districtID
				and q.frst_date=1 
	where q2.district_cnt=1 
	
UPDATE MTB
set MTB.DateExitedFromDistrict=q.DateExitedFromDistrict
From ##myTbl MTB
join (
	 select int_researchID,count(distinct DistrictCode) as district_cnt
			from OSPI_0405
			where primaryschool=1
			group by int_researchID 
	) q2 on q2.int_researchID=mtb.int_researchID
join (
		select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
		  , row_number() over (partition by int_researchID,ot.districtID
								order by int_researchID,ot.districtID,DateExitedFromDistrict desc) as frst_date
		 from ##myTbl ot
		) q on q.int_researchID=mtb.int_researchID
				and q.districtID=mtb.districtID
				and q.frst_date=1 
	where q2.district_cnt=1 

------------------------------------------------------update exit dates for forced exit where there is a school change
update MTB
set DateExitedFromSchool=q2.DateEnrolledInSchool
--select q2.schoolcode,q2.DateEnrolledInSchool,MTB.*
from ##MYTBL MTB
join (select *
		,row_number() over 
		(  partition by int_researchID
			order by int_researchID,DateEnrolledInSchool ) as row_num
	   from ##MYTBL
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
	   from ##MYTBL
	   -- where int_researchID=993219 
	   ) q2
	   on q.int_ResearchID=q2.int_researchID
		and q.row_num +1=q2.row_num
Where q.SchoolCode <> q2.SchoolCode
	and q.DateExitedFromSchool > q2.DateEnrolledInSchool
	 --and q.int_researchID=993219   
	 --and q.EnrollmentStatus='FE'
	 

--delete entry exit same day for forced exits
--delete
--from ##MYTBL 
--where DateEnrolledInSchool=DateExitedFromSchool
--and EnrollmentStatus='FE'

	 


	
	
if @stop_yrMonth = 	200507
	begin
		truncate table ##ospi
		insert into ##ospi (int_researchID 
								, DistrictID 
								, SchoolCode 
								, DateEnrolledInDistrict 
								, DateExitedFromDistrict
								, DateEnrolledInSchool
								, DateExitedFromSchool 
								, EnrollmentStatuS 
								, frst_enr_mnth
								, last_enr_mnth 
								, min_grade_level
								, max_grade_level )
		select int_researchID 
				, DistrictID 
				, SchoolCode 
				, DateEnrolledInDistrict 
				, DateExitedFromDistrict
				, DateEnrolledInSchool
				, DateExitedFromSchool 
				, EnrollmentStatuS 
				, frst_enr_mnth
				, last_enr_mnth 
				, min_grade_level
				, max_grade_level 
		from ##myTbl
	end;
else
	begin
		-- END DATE SCHOOL RECORDS THAT CLOSED DURING PERIOD
		update OSP
		set   DateExitedFromSchool=mtb.DateExitedFromSchool
			, DateExitedFromDistrict=mtb.DateExitedFromDistrict
			, last_enr_mnth = mtb.last_enr_mnth
			, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
			, max_grade_level=mtb.max_grade_level
			, enrollmentstatus=mtb.enrollmentstatus
		from ##ospi osp
		join ##myTbl mtb
			on mtb.int_researchID=osp.int_researchID
			and mtb.schoolCode=osp.SchoolCode
			and mtb.DistrictID=osp.DistrictID
			and mtb.DateEnrolledInSchool=osp.DateEnrolledInSchool
			and mtb.DateExitedFromSchool <> osp.DateExitedFromSchool
		

		 --update records for clients same school all year
		update OSP
		set   last_enr_mnth = mtb.last_enr_mnth
			--, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
			, max_grade_level=mtb.max_grade_level
			, enrollmentstatus=mtb.enrollmentstatus
		--select mtb.*,osp.dateenrolledinschool,osp.dateexitedfromschool
		from ##ospi osp
		join ##myTbl mtb
			on mtb.int_researchID=osp.int_researchID
			and mtb.schoolCode=osp.SchoolCode
			and mtb.DistrictID=osp.DistrictID
			and ((mtb.DateEnrolledInSchool=osp.DateEnrolledInSchool
				and mtb.DateExitedFromSchool = osp.DateExitedFromSchool)
				OR ( mtb.DateEnrolledInSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and mtb.DateExitedFromSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and osp.last_enr_mnth=@stop_yrMonth + 1 - 100 --- August of previous year
					and mtb.frst_enr_mnth=@stop_yrMonth + 1 - 100 --beginning of this year
					and mtb.last_enr_mnth=@stop_yrMonth + 1   -- August of this year 
				))
			
			
			
		--INSERT NEW RECORD
		insert into ##ospi (int_researchID 
								, DistrictID 
								, SchoolCode 
								, DateEnrolledInDistrict 
								, DateExitedFromDistrict
								, DateEnrolledInSchool
								, DateExitedFromSchool 
								, EnrollmentStatuS 
								, frst_enr_mnth
								, last_enr_mnth 
								, min_grade_level
								, max_grade_level )
		select distinct 
				  mt.int_researchID 
				, mt.DistrictID 
				, mt.SchoolCode 
				, mt.DateEnrolledInDistrict 
				, mt.DateExitedFromDistrict
				, mt.DateEnrolledInSchool
				, mt.DateExitedFromSchool 
				, mt.EnrollmentStatuS 
				, mt.frst_enr_mnth
				, mt.last_enr_mnth 
				, mt.min_grade_level
				, mt.max_grade_level 
		from ##myTbl mt
		left join ##ospi osp 
			on osp.int_researchID=mt.int_researchID
			and osp.DistrictID=mt.DistrictID
			and osp.SchoolCode=mt.SchoolCode
			and ((mt.DateEnrolledInSchool=osp.DateEnrolledInSchool
					and mt.DateExitedFromSchool = osp.DateExitedFromSchool)
				OR ( mt.DateEnrolledInSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and mt.DateExitedFromSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and osp.last_enr_mnth=@stop_yrMonth + 1 - 100 --- August of previous year
					and mt.frst_enr_mnth=@stop_yrMonth + 1 - 100 --beginning of this year
					and mt.last_enr_mnth=@stop_yrMonth + 1   -- August of this year 
				))
		where osp.int_researchID is null
		
		-- update district dates where there is only 1 district
		UPDATE OSP
		set OSP.DateEnrolledInDistrict=q.DateEnrolledInDistrict
		From ##ospi OSP
		join (
			 select int_researchID,count(distinct districtID) as district_cnt
					from ##ospi
					group by int_researchID 
			) q2 on q2.int_researchID=osp.int_researchID
		join (
				select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
				  , row_number() over (partition by int_researchID,ot.districtID
										order by int_researchID,ot.districtID,DateEnrolledInDistrict asc) as frst_date
				 from ##ospi ot
				) q on q.int_researchID=osp.int_researchID
						and q.districtID=osp.districtID
						and q.frst_date=1 
			where q2.district_cnt=1 
			
		UPDATE OSP
		set OSP.DateExitedFromDistrict=q.DateExitedFromDistrict
		From ##ospi OSP
		join (
			select int_researchID,count(distinct districtID) as district_cnt
			from ##ospi
			group by int_researchID 
			) q2 on q2.int_researchID=OSP.int_researchID
		join (
				select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
				  , row_number() over (partition by int_researchID,ot.districtID
										order by int_researchID,ot.districtID,DateExitedFromDistrict desc) as frst_date
				 from ##ospi ot
				) q on q.int_researchID=OSP.int_researchID
						and q.districtID=OSP.districtID
						and q.frst_date=1 
			where q2.district_cnt=1 	
	end