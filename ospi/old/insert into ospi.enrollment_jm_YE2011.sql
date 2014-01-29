	    declare @stop_yrMonth int
	    declare @schoolyearend int
	    set @schoolyearend=2011
	    set @stop_yrMonth=@schoolyearend * 100 + 8
		
		
		
		
		declare @loop int
		declare @stoploop int
		declare @maxloop int
		set @loop=1
		set @stoploop=100000
		set @maxloop =2000000
		
		
		
	if object_ID('tempDB..#tmp') is not null drop table #tmp
	select distinct int_researchID,DistrictCode,SchoolCode
	,max(case when gradelevel='PK' then -2
			when gradelevel='K1' then -1
			when gradelevel='K2' then 0
			else cast(gradelevel as int) end) as int_max_grade,
	min(case when gradelevel='PK' then -2
			when gradelevel='K1' then -1
			when gradelevel='K2' then 0
			else  cast(gradelevel as int) end) as int_min_grade
		,cast(null as char(2)) as max_grade_level
		,cast(null as char(2)) as min_grade_level
		,year(min(DateEnrolledInSchool)) * 100  + month(min(DateEnrolledInSchool)) as frst_enr_mnth
		, year(max(case when DateExitedSchool is not null then DateExitedSchool else convert(datetime,cast(@stop_yrMonth * 100 + 1 as varchar(10)),112) end)) * 100  + month(max(case when DateExitedSchool is not null then DateExitedSchool else convert(datetime,cast(@stop_yrMonth * 100 + 1 as varchar(10)),112) end)) as last_enr_mnth
	into #tmp
	from 	ospi.ospi_1011	
	where primaryschoolflag='Y'
	group by int_researchID,DistrictCode,SchoolCode
	
	
	

update #tmp
set max_grade_level=case when int_max_grade=-2 then 'PK' 
		when int_max_grade= -1 then 'K1' 
		when int_max_grade=0 then 'K2'
		else cast(int_max_grade as char(2)) end
, min_grade_level=case when int_min_grade=-2 then 'PK' 
		when int_min_grade= -1 then 'K1' 
		when int_min_grade=0 then 'K2'
		else cast(int_min_grade as char(2)) end






		while @stoploop <= @maxloop
		begin
				begin tran t1
	
				update OSP
				set   DateExitedFromSchool=isnull(mtb.DateExitedSchool,'12/31/3999')
					, DateExitedFromDistrict=isnull(mtb.DateExitedDistrict,'12/31/3999')
					, last_enr_mnth = t.last_enr_mnth
					, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
					, max_grade_level=t.max_grade_level
					, enrollmentstatus=mtb.enrollmentstatus
					, schoolyearend=@schoolyearend
				from ospi.enrollment_temp_jm osp
				join ospi.ospi_1011 mtb
					on mtb.int_researchID=osp.int_researchID
					and mtb.schoolCode=osp.SchoolCode
					and mtb.DistrictCode=osp.DistrictID
					and mtb.DateEnrolledInSchool=osp.DateEnrolledInSchool
					and mtb.primaryschoolflag='Y'
					and isnull(mtb.DateExitedSchool,'12/31/3999') <> osp.DateExitedFromSchool
				join #tmp t on t.int_researchID=osp.int_researchID
					and t.schoolCode=osp.schoolCode
					and t.DistrictCode=osp.DistrictID
					and osp.last_enr_mnth=@stop_yrMonth-100
				where osp.int_researchID between @loop and @stoploop
				
				commit tran t1

				begin tran t2
				 --update records for clients same school all year
				update OSP
				set   last_enr_mnth = t.last_enr_mnth
					--, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
					, max_grade_level=t.max_grade_level
					, enrollmentstatus=mtb.enrollmentstatus
					, schoolyearend=@schoolyearend
				--select mtb.*,osp.dateenrolledinschool,osp.DateExitedSchool
				from ospi.enrollment_temp_jm osp
				join #tmp t on t.int_researchID=osp.int_researchID
					and t.schoolCode=osp.schoolCode
					and t.DistrictCode=osp.DistrictID
					and osp.last_enr_mnth=@stop_yrMonth-100
				join ospi.ospi_1011 mtb
					on mtb.int_researchID=osp.int_researchID
					and mtb.schoolCode=osp.SchoolCode
					and mtb.DistrictCode=osp.DistrictID
					and  mtb.primaryschoolflag='Y'
					and ((mtb.DateEnrolledInSchool=osp.DateEnrolledInSchool
						and isnull(mtb.DateExitedSchool,'12/31/3999') = osp.DateExitedFromSchool)
						OR ( mtb.DateEnrolledInSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
							and isnull(mtb.DateExitedSchool,'12/31/3999') between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
							and osp.last_enr_mnth=@stop_yrMonth  - 100 --- August of previous year
							--and mtb.frst_enr_mnth=@stop_yrMonth  - 100 --beginning of this year
							--and mtb.last_enr_mnth=@stop_yrMonth   -- August of this year 
						))
				where osp.int_researchID between @loop and @stoploop
				
				commit tran t2;	
				set @loop = @loop + 100000
				set @stoploop = @stoploop + 100000	
						
		end
			
		--INSERT NEW RECORD
			insert into ospi.enrollment_temp_jm (int_researchID 
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
								, int_min_grade
								, int_max_grade
								, fl_delete
								, schoolyearend
								, school_enroll_date
								, school_exit_date)
		select distinct
				 mt.int_researchID 
				, mt.DistrictCode 
				, mt.SchoolCode 
				, mt.DateEnrolledInDistrict 
				, isnull(mt.DateExitedDistrict,'12/31/3999')
				, mt.DateEnrolledInSchool
				, isnull(mt.DateExitedSchool ,'12/31/3999')
				, mt.EnrollmentStatuS 
				, t.frst_enr_mnth
				, t.last_enr_mnth 
				, t.min_grade_level
				, t.max_grade_level
				, t.int_min_grade
				, t.int_max_grade
				, 0
				, @schoolyearend
				, mt.DateEnrolledInSchool
				, isnull(mt.DateExitedSchool ,'12/31/3999')
		from ospi.ospi_1011 mt
		join #tmp t on t.int_researchID=mt.int_researchID
					and t.schoolCode=mt.schoolCode
					and t.DistrictCode=mt.DistrictCode
		left join ospi.enrollment_temp_jm osp 
			on osp.int_researchID=mt.int_researchID
			and osp.DistrictID=mt.DistrictCode
			and osp.SchoolCode=mt.SchoolCode
			and ((mt.DateEnrolledInSchool=osp.DateEnrolledInSchool
					and isnull(mt.DateExitedSchool,'12/31/3999')  = osp.DateExitedFromSchool)
				OR ( mt.DateEnrolledInSchool between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and isnull(mt.DateExitedSchool,'12/31/3999') between osp.DateEnrolledInSchool and osp.DateExitedFromSchool
					and osp.last_enr_mnth=@stop_yrMonth  - 100 --- August of previous year
					--and mt.frst_enr_mnth=@stop_yrMonth  - 100 --beginning of this year
					--and mt.last_enr_mnth=@stop_yrMonth    -- August of this year 
				))
		where osp.int_researchID is null and mt.primaryschoolflag='Y'
		
		set @loop=1
		set @stoploop=100000
		
		while @stoploop <= @maxloop
		begin

			begin tran t3
				-- update district dates where there is only 1 district
				UPDATE OSP
				set OSP.DateEnrolledInDistrict=q.DateEnrolledInDistrict
				From ospi.enrollment_temp_jm OSP
				join (
					 select int_researchID,count(distinct districtID) as district_cnt
							from ospi.enrollment_temp_jm
							group by int_researchID 
					) q2 on q2.int_researchID=osp.int_researchID
				join (
						select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
						  , row_number() over (partition by int_researchID,ot.districtID
												order by int_researchID,ot.districtID,DateEnrolledInDistrict asc) as frst_date
						 from ospi.enrollment_temp_jm ot
						) q on q.int_researchID=osp.int_researchID
								and q.districtID=osp.districtID
								and q.frst_date=1 
					where q2.district_cnt=1 
					and osp.int_researchID between @loop and @stoploop
					
			commit tran t3;
			
			begin tran t4	
				UPDATE OSP
				set OSP.DateExitedFromDistrict=q.DateExitedFromDistrict
				From ospi.enrollment_temp_jm OSP
				join (
					select int_researchID,count(distinct districtID) as district_cnt
					from ospi.enrollment_temp_jm
					group by int_researchID 
					) q2 on q2.int_researchID=OSP.int_researchID
				join (
						select  ot.int_researchID,ot.districtID,DateEnrolledInDistrict,DateExitedFromDistrict
						  , row_number() over (partition by int_researchID,ot.districtID
												order by int_researchID,ot.districtID,DateExitedFromDistrict desc) as frst_date
						 from ospi.enrollment_temp_jm ot
						) q on q.int_researchID=OSP.int_researchID
								and q.districtID=OSP.districtID
								and q.frst_date=1 
					where q2.district_cnt=1 
						and osp.int_researchID between @loop and @stoploop
			commit tran t4;
		
			set @loop = @loop + 100000
			set @stoploop = @stoploop + 100000	
				
	end	
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


update ospi.enrollment_temp_jm 
set school_exit_date=DateExitedFromSchool
		
		
update statistics ospi.enrollment_temp_jm;
	
--	select max(last_enr_mnth),count(*) from ospi.enrollment_temp_jm
	
--	select * into ospi.temp from ospi.enrollment_temp_jm
	
--	select count(*) from ospi.enrollment_temp_jm
	
	
--insert into ospi.enrollment_temp_jm
--select * from ospi.temp


truncate table ospi.Enrollment_YE2005_thru_YE2011
insert into ospi.Enrollment_YE2005_thru_YE2011
select * from ospi.enrollment_temp_jm 