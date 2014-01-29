SELECT [int_researchID]
      ,[DistrictID]
      ,[DistrictName]
      ,[SchoolCode]
      ,[SchoolName]
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
FROM [dbCoreAdministrativeTables].[ospi].[Enrollment_Fact]
where [int_researchID] = 1422293
order by [DateEnrolledInSchool]


select [int_researchID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,gradelevel
      
       from ospi.ospi_0405 
       where [int_researchID] = 1422293 
union
select [int_researchID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,gradelevel
      
       from ospi.ospi_0506 
       where [int_researchID] = 1422293 
union       
select [int_researchID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,gradelevel
      
       from ospi.ospi_0607 
       where [int_researchID] = 1422293 
union        
select [int_researchID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,gradelevel
      
       from ospi.ospi_0708
       where [int_researchID] = 1422293
       
       union
       select [int_researchID]
      ,[DistrictCode]
      ,[SchoolCode]
      ,[DateEnrolledInDistrict]
      ,[DateExitedFromDistrict]
      ,[DateEnrolledInSchool]
      ,[DateExitedFromSchool]
      ,gradelevel
      
       from ospi.ospi_0809
       where [int_researchID] = 1422293 
        order by [DateEnrolledInSchool]       
   
   
   select [int_researchID] ,[DistrictID],[SchoolCode],[DateEnrolledInDistrict],[DateExitedFromDistrict],[DateEnrolledInSchool],[DateExitedFromSchool],[EnrollmentStatuS],[frst_enr_mnth],[last_enr_mnth],[min_grade_level],[max_grade_level],[int_min_grade],[int_max_grade] from ospi.enrollment_2005 where [int_researchID] = 1422293  union
   select [int_researchID] ,[DistrictID],[SchoolCode],[DateEnrolledInDistrict],[DateExitedFromDistrict],[DateEnrolledInSchool],[DateExitedFromSchool],[EnrollmentStatuS],[frst_enr_mnth],[last_enr_mnth],[min_grade_level],[max_grade_level],[int_min_grade],[int_max_grade] from ospi.enrollment_2006 where [int_researchID] = 1422293  union
   select [int_researchID] ,[DistrictID],[SchoolCode],[DateEnrolledInDistrict],[DateExitedFromDistrict],[DateEnrolledInSchool],[DateExitedFromSchool],[EnrollmentStatuS],[frst_enr_mnth],[last_enr_mnth],[min_grade_level],[max_grade_level],[int_min_grade],[int_max_grade] from ospi.enrollment_2007 where [int_researchID] = 1422293  union
   select [int_researchID] ,[DistrictID],[SchoolCode],[DateEnrolledInDistrict],[DateExitedFromDistrict],[DateEnrolledInSchool],[DateExitedFromSchool],[EnrollmentStatuS],[frst_enr_mnth],[last_enr_mnth],[min_grade_level],[max_grade_level],[int_min_grade],[int_max_grade] from ospi.enrollment_2008 where [int_researchID] = 1422293  union
   select [int_researchID] ,[DistrictID],[SchoolCode],[DateEnrolledInDistrict],[DateExitedFromDistrict],[DateEnrolledInSchool],[DateExitedFromSchool],[EnrollmentStatuS],[frst_enr_mnth],[last_enr_mnth],[min_grade_level],[max_grade_level],[int_min_grade],[int_max_grade] from ospi.enrollment_2009 where [int_researchID] = 1422293  order by [DateEnrolledInSchool]
   
   select * from ospi.temp_all where [int_researchID] = 1422293 order by DateEnrolledInSchool	
   
--insert into ospi.temp ([int_researchID]
--      ,[DistrictID]
--      ,[SchoolCode]
--      ,[DateEnrolledInDistrict]
--      ,[DateExitedFromDistrict]
--      ,[DateEnrolledInSchool]
--      ,[DateExitedFromSchool]
--      ,[EnrollmentStatuS]
--      ,[frst_enr_mnth]
--      ,[last_enr_mnth]
--      ,[min_grade_level]
--      ,[max_grade_level]
--      ,[int_min_grade]
--      ,[int_max_grade]
--      ,[row_num_asc]
--      ,[row_num_desc]
--      ,[fl_multiple_primaryschool]
--      ,[fl_prm_txfr]
--      ,[fl_prm_txfr_inter]
--      ,[fl_prm_txfr_intra]
--      ,[fl_other_txfr]
--      ,[fl_other_txfr_inter]
--      ,[fl_other_txfr_intra]
--      ,[overall_txfr_rank]
--      ,[prom_txfr_rank]
--      ,[other_txfr_rank]
--      ,[enrollment_duration]
--      ,[approx_age_enroll_start]
--      ,[approx_age_enroll_end]
--      ,[MonthYearBirth]
--      ,[fl_delete])
--      select * from ospi.temp_all

   
   