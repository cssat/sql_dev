		update my
		set row_num_desc=q.row_num_desc
		from ospi.ospi_0910 my		
		join (select int_researchID,DistrictCode,SchoolCode,DateEnrolledInSchool,coalesce(DateExitedSchool,'12/31/3999') as DateExitedSchool
					
				,row_number() over (partition by int_researchID
										order by int_researchID,DateEnrolledInSchool desc,coalesce(DateExitedSchool,'12/31/3999') desc) as row_num_desc								
				from ospi.ospi_0910
				where primaryschoolflag='Y' 
					and coalesce(DateExitedSchool,'12/31/3999') > DateEnrolledInSchool
				) q on q.int_researchID=my.int_researchID
					and q.DistrictCode=my.DistrictCode
					and q.SchoolCode=my.SchoolCode
					and q.DateEnrolledInSchool=my.DateEnrolledInSchool
					and coalesce(q.DateExitedSchool,'12/31/3999')=coalesce(my.DateExitedSchool,'12/31/3999')	
		where my.primaryschoolflag='Y' 
			and coalesce(my.DateExitedSchool,'12/31/3999') > my.DateEnrolledInSchool
					
					
		update my
		set row_num_desc=q.row_num_desc
		from ospi.ospi_1011 my		
		join (select int_researchID,DistrictCode,SchoolCode,DateEnrolledInSchool,coalesce(DateExitedSchool,'12/31/3999') as DateExitedSchool
					
				,row_number() over (partition by int_researchID
										order by int_researchID,DateEnrolledInSchool desc,coalesce(DateExitedSchool,'12/31/3999') desc) as row_num_desc								
				from ospi.ospi_1011
				where primaryschoolflag='Y' 
					and coalesce(DateExitedSchool,'12/31/3999') > DateEnrolledInSchool
				) q on q.int_researchID=my.int_researchID
					and q.DistrictCode=my.DistrictCode
					and q.SchoolCode=my.SchoolCode
					and q.DateEnrolledInSchool=my.DateEnrolledInSchool
					and coalesce(q.DateExitedSchool,'12/31/3999')=coalesce(my.DateExitedSchool,'12/31/3999')	
		where my.primaryschoolflag='Y' 
			and coalesce(my.DateExitedSchool,'12/31/3999') > my.DateEnrolledInSchool