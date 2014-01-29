
truncate table ospi.temp
insert into ospi.temp(int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
					)
		select    int_researchID
				, DistrictID
				, SchoolCode
				--, nw.DateEnrolledInDistrict
				--, coalesce(nw.DateExitedFromDistrict,@yearenddate)
				, DateEnrolledInSchool
				, min(coalesce(DateExitedFromSchool,'12/31/3999')) 
				, min(int_min_grade)
				, max(int_max_grade)
				, min(frst_enr_mnth)
				, max(last_enr_mnth)
				, 0
from (select int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
		from ospi.Enrollment_2005
		union
		select int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
		from ospi.Enrollment_2006
		union
		select int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
		from ospi.Enrollment_2007
		union
		select int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
		from ospi.Enrollment_2008
		union
		select int_researchID
					,DistrictID
					,SchoolCode
					,DateEnrolledInSchool
					,DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,int_min_grade
					,int_max_grade
					,frst_enr_mnth
					,last_enr_mnth
					,fl_multiple_primaryschool
		from ospi.Enrollment_2009
		union
		select int_researchID
					,DistrictCode
					,SchoolCode
					,DateEnrolledInSchool
					,min(coalesce(DateExitedSchool,'12/31/3999')) as DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,MIN(case when isnumeric(gradelevel)=1 then cast(gradelevel as int)
						when gradelevel='K2' then 0
						when gradelevel = 'K1' then -1
						when gradelevel = 'PK' then -2 end) as int_min_grade
					,max(case when isnumeric(gradelevel)=1 then cast(gradelevel as int)
						when gradelevel='K2' then 0
						when gradelevel = 'K1' then -1
						when gradelevel = 'PK' then -2 end)
					,200909
					,201008
					,0
		from ospi.ospi_0910
		where primaryschoolflag='Y'
		and coalesce(DateExitedSchool,'12/31/3999') > DateEnrolledInSchool
		group by int_researchID
					,DistrictCode
					,SchoolCode
					,DateEnrolledInSchool

		union
				select int_researchID
					,DistrictCode
					,SchoolCode
					,DateEnrolledInSchool
					,min(coalesce(DateExitedSchool,'12/31/3999')) as DateExitedFromSchool
					--,DateExitedFromSchool,EnrollmentStatuS,frst_enr_mnth,last_enr_mnth
					,MIN(case when isnumeric(gradelevel)=1 then cast(gradelevel as int)
						when gradelevel='K2' then 0
						when gradelevel = 'K1' then -1
						when gradelevel = 'PK' then -2 end) as int_min_grade
					,max(case when isnumeric(gradelevel)=1 then cast(gradelevel as int)
						when gradelevel='K2' then 0
						when gradelevel = 'K1' then -1
						when gradelevel = 'PK' then -2 end)
					,201009
					,201108
					,0
		from ospi.ospi_1011
		where primaryschoolflag='Y'
		and coalesce(DateExitedSchool,'12/31/3999') > DateEnrolledInSchool
		group by int_researchID
					,DistrictCode
					,SchoolCode
					,DateEnrolledInSchool 
					) q
		group by int_researchID
				, DistrictID 
				, SchoolCode
				, DateEnrolledInSchool
				
		go		
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedFromDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= ospi.MonthYearBirth
		from ospi.temp tmp 
		join ospi.Enrollment_2005 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictID=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.last_enr_mnth=tmp.last_enr_mnth

		go			
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedFromDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= ospi.MonthYearBirth
		from ospi.temp tmp 
		join ospi.Enrollment_2006 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictID=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.last_enr_mnth=tmp.last_enr_mnth
		go	
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedFromDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= ospi.MonthYearBirth
		from ospi.temp tmp 
		join ospi.Enrollment_2007 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictID=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.last_enr_mnth=tmp.last_enr_mnth
		go	

		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedFromDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= ospi.MonthYearBirth
		from ospi.temp tmp 
		join ospi.Enrollment_2008 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictID=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.last_enr_mnth=tmp.last_enr_mnth
		go	
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedFromDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= ospi.MonthYearBirth
		from ospi.temp tmp 
		join ospi.Enrollment_2009 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictID=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.last_enr_mnth=tmp.last_enr_mnth
		go	
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= 
			cast(right(ospi.MonthYearOfBirth,4) as int) * 100 + cast(left(ospi.MonthYearOfBirth,2) as int)
		from ospi.temp tmp 
		join ospi.ospi_0910 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictCode=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.row_num_desc is not null
		where tmp.last_enr_mnth=201008
					
		go	
		update tmp
		set DateEnrolledInDistrict = ospi.DateEnrolledInDistrict
			,DateExitedFromDistrict=ospi.DateExitedDistrict
			,EnrollmentStatuS=ospi.EnrollmentStatuS
			,MonthYearBirth= 
			cast(right(ospi.MonthYearOfBirth,4) as int) * 100 + cast(left(ospi.MonthYearOfBirth,2) as int)
		from ospi.temp tmp 
		join ospi.ospi_1011 ospi
		on  ospi.int_researchID=tmp.int_researchID
			and ospi.DistrictCode=tmp.DistrictID
			and ospi.SchoolCode=tmp.SchoolCode
			and ospi.DateEnrolledInSchool=tmp.DateEnrolledInSchool
			and ospi.row_num_desc is not null
		where tmp.last_enr_mnth=201108	
		
		go
		
			
		update ospi.temp 										
		set  min_grade_level = case when int_min_grade > 0 then cast(int_min_grade as char(2))
								when int_min_grade=0 then 'K2'
								when int_min_grade=-1 then 'K1'
								when int_min_grade=-2 then 'PK' end
			,max_grade_level = case when int_max_grade > 0 then cast(int_max_grade as char(2))
								when int_max_grade=0 then 'K2'
								when int_max_grade=-1 then 'K1'
								when int_max_grade=-2 then 'PK' end
		
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
				
				
				
select * into ospi.temp_all from ospi.temp		


truncate table ospi.temp

insert into ospi.temp  ([int_researchID]
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
select * from ospi.temp_all
								