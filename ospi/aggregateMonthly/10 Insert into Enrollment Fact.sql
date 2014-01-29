truncate table ospi.enrollment_fact
insert into ospi.enrollment_fact
SELECT [int_researchID]
      ,osp.[DistrictID]
      ,d.DistrictName
      ,osp.[SchoolCode]
      ,sc.SchoolName
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
      ,[First_ZipCode]
      ,[Last_ZipCode]
      ,[firstResidentDistrictID]
      ,d2.DistrictName as firstResDistrictName
      ,[lastResidentDistrictID]
      ,d3.DistrictName as lastResDistrictName
      ,[int_startGradeLevel] as int_overall_startGradeLevel
      ,[int_stopGradeLevel] as int_overall_stopGradeLevel
      ,[startGradeLevel] as overall_StartGradeLevel
      ,[stopGradeLevel] as overall_StopGradeLevel
      ,[fl_migrant]
      ,[fl_homeless]
      ,[fl_504]
      ,[fl_specialEd]
      ,[fl_privateSchool]
      ,[fl_homeBased]
      ,[fl_foreignExch]
      ,[fl_fostercare_1011]
      ,[fl_famlinkFC]
      ,[row_num_asc] as rank_asc
      ,[row_num_desc] as rank_desc
   --  into ospi.Enrollment_Fact
  FROM [dbCoreAdministrativeTables].[ospi].[temp] osp
 left join ospi.district d on d.[DistrictID]=osp.[DistrictID]
 left join ospi.school_dim sc on sc.schoolcode=osp.schoolcode
 left join ospi.district d2 on d2.[DistrictID]=osp.[firstResidentDistrictID]
left join ospi.district d3 on d3.[DistrictID]=osp.[lastResidentDistrictID]
 


alter table ospi.Enrollment_Fact
add  primary key(int_researchID,[DistrictID],schoolcode,[DateEnrolledInSchool],[DateExitedFromSchool])

