	    declare @stop_yrMonth int
	    declare @schoolyearend int
	    declare @prevYrEndDate datetime
	    declare @prevYrMonth int
	    set @schoolyearend=2006 --didn't run 2009 yet
	    set @stop_yrMonth=@schoolyearend * 100 + 8
	    set @prevYrMonth=@stop_yrMonth -100
		set @prevYrEndDate=convert(datetime,cast(@schoolyearend - 1 as varchar(4)) + '0831',112)
		
		
		
		declare @loop int
		declare @stoploop int
		declare @maxloop int
		set @loop=1
		set @stoploop=100000
		set @maxloop =2000000

		while @stoploop <= @maxloop
		begin
				
				begin tran t1
				--exact match primary key
				update OSP
				set   last_enr_mnth = mtb.last_enr_mnth
					--, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
					, max_grade_level=mtb.max_grade_level
					, int_max_grade=case when isnumeric(mtb.max_grade_level)=1 then cast(mtb.max_grade_level as int)
							when mtb.max_grade_level='PK' then -2
							when mtb.max_grade_level='K1' then -1
							when mtb.max_grade_level='K2' then 0 end
					, enrollmentstatus=mtb.enrollmentstatus
					, schoolyearend=@schoolyearend
				--select mtb.*,osp.dateenrolledinschool,osp.dateexitedfromschool
				from ospi.enrollment_temp_jm osp
				join ospi.Enrollment_2006 mtb
				on 	mtb.int_researchID= osp.int_researchID
				and mtb.districtID=osp.districtID
				and mtb.SchoolCode=osp.SchoolCode
				and mtb.DateEnrolledInSchool=osp.DateEnrolledInSchool
				and mtb.DateExitedFromSchool=osp.DateExitedFromSchool
				where osp.int_researchID between @loop and @stoploop
				
				commit tran t1

				begin tran t2
				 --update records for clients same school at beginning of year 
				 -- and same school last enrollment date previous year
				update OSP
				set   last_enr_mnth = mtb.last_enr_mnth
					--, DateEnrolledInDistrict=mtb.DateEnrolledInDistrict
					, max_grade_level=mtb.max_grade_level
					, int_max_grade=case when isnumeric(mtb.max_grade_level)=1 then cast(mtb.max_grade_level as int)
							when mtb.max_grade_level='PK' then -2
							when mtb.max_grade_level='K1' then -1
							when mtb.max_grade_level='K2' then 0 end
					, enrollmentstatus=mtb.enrollmentstatus
					, schoolyearend=@schoolyearend
					, school_exit_date=mtb.DateExitedFromSchool
					, DateExitedFromSchool=mtb.DateExitedFromSchool
				--select mtb.*,osp.dateenrolledinschool,osp.dateexitedfromschool
				from ospi.enrollment_temp_jm osp
				join ospi.Enrollment_2006 mtb
					on mtb.int_researchID=osp.int_researchID
					and mtb.schoolCode=osp.SchoolCode
					and mtb.DistrictID=osp.DistrictID
					and osp.row_num=1 
					and mtb.row_num=1
							--and osp.last_enr_mnth = @stop_yrMonth  - 100 --- August of previous year
							--and mtb.frst_enr_mnth=@stop_yrMonth  - 100 --beginning of this year
							--and mtb.last_enr_mnth=@stop_yrMonth   -- August of this year 
						--))
				where osp.int_researchID between @loop and @stoploop
				commit tran t2;	
				set @loop = @loop + 100000
				set @stoploop = @stoploop + 100000	
						
		end
			
		---INSERT NEW RECORD
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
								, schoolyearend
								, int_min_grade
								, int_max_grade
								, fl_delete
								, school_enroll_date
								, school_exit_date)
		select mt.int_researchID 
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
				, @schoolyearend as schoolyearend
				, case when isnumeric(mt.min_grade_level)=1 then cast(mt.min_grade_level as int)
						when mt.min_grade_level='PK' then -2
						when mt.min_grade_level='K1' then -1
						when mt.min_grade_level='K2' then 0 end as int_min_grade
				, case when isnumeric(mt.max_grade_level)=1 then cast(mt.max_grade_level as int)
						when mt.max_grade_level='PK' then -2
						when mt.max_grade_level='K1' then -1
						when mt.max_grade_level='K2' then 0 end as int_max_grade
				, 0 as fl_delete
				, mt.DateEnrolledInSchool as School_Enroll_Date
				, mt.DateExitedFromSchool as School_Exit_Date
		--into ##temp
		from ospi.Enrollment_2006 mt
		left join ospi.enrollment_temp_jm osp 
			on osp.int_researchID=mt.int_researchID
			and osp.DistrictID=mt.DistrictID
			and osp.SchoolCode=mt.SchoolCode
			and (osp.row_num=1 	and mt.row_num=1)
		left join ospi.Enrollment_2006 t
		on 	t.int_researchID= mt.int_researchID
				and t.districtID=mt.districtID
				and t.SchoolCode=mt.SchoolCode
				and t.DateEnrolledInSchool=mt.DateEnrolledInSchool
				and t.DateExitedFromSchool=mt.DateExitedFromSchool
		where osp.int_researchID is null and t.int_researchID is null
		
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

	update statistics ospi.enrollment_temp_jm;
	-- sort descending order 
	update tmp
	set row_num = curr.row_sort
	from ospi.enrollment_temp_jm  tmp
	join (
		 select *,row_number() over (
				partition by int_researchID 
				order by int_researchID,DateEnrolledInSchool desc,DateExitedFromSchool asc ) as row_sort
			from ospi.enrollment_temp_jm
			) curr on curr.int_researchID=tmp.int_researchID
				and curr.districtID=tmp.districtID
				and curr.schoolcode=tmp.schoolcode
				and curr.DateEnrolledInSchool=tmp.DateEnrolledInSchool
				and curr.DateExitedFromSchool=tmp.DateExitedFromSchool
			
			
	