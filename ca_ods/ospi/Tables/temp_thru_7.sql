﻿CREATE TABLE [ospi].[temp_thru_7] (
    [int_researchID]            INT      NOT NULL,
    [DistrictID]                INT      NOT NULL,
    [SchoolCode]                INT      NOT NULL,
    [DateEnrolledInDistrict]    DATETIME NULL,
    [DateExitedFromDistrict]    DATETIME NULL,
    [DateEnrolledInSchool]      DATETIME NOT NULL,
    [DateExitedFromSchool]      DATETIME NOT NULL,
    [EnrollmentStatuS]          CHAR (2) NULL,
    [frst_enr_mnth]             INT      NULL,
    [last_enr_mnth]             INT      NULL,
    [min_grade_level]           CHAR (2) NULL,
    [max_grade_level]           CHAR (2) NULL,
    [int_min_grade]             INT      NULL,
    [int_max_grade]             INT      NULL,
    [row_num_asc]               INT      NULL,
    [row_num_desc]              INT      NULL,
    [fl_multiple_primaryschool] INT      NULL,
    [fl_prm_txfr]               SMALLINT NULL,
    [fl_prm_txfr_inter]         SMALLINT NULL,
    [fl_prm_txfr_intra]         SMALLINT NULL,
    [fl_other_txfr]             SMALLINT NULL,
    [fl_other_txfr_inter]       SMALLINT NULL,
    [fl_other_txfr_intra]       SMALLINT NULL,
    [overall_txfr_rank]         INT      NULL,
    [prom_txfr_rank]            INT      NULL,
    [other_txfr_rank]           INT      NULL,
    [enrollment_duration]       INT      NULL,
    [approx_age_enroll_start]   INT      NULL,
    [approx_age_enroll_end]     INT      NULL,
    [MonthYearBirth]            INT      NULL,
    [First_ZipCode]             INT      NULL,
    [Last_ZipCode]              INT      NULL,
    [fl_delete]                 INT      NOT NULL,
    [firstResidentDistrictID]   INT      NULL,
    [lastResidentDistrictID]    INT      NULL,
    [int_startGradeLevel]       INT      NULL,
    [int_stopGradeLevel]        INT      NULL,
    [startGradeLevel]           CHAR (2) NULL,
    [stopGradeLevel]            CHAR (2) NULL,
    [fl_migrant]                INT      NULL,
    [fl_homeless]               INT      NULL,
    [fl_504]                    INT      NULL,
    [fl_specialEd]              INT      NULL,
    [fl_privateSchool]          INT      NULL,
    [fl_homeBased]              INT      NULL,
    [fl_foreignExch]            INT      NULL,
    [fl_fostercare_1011]        INT      NULL,
    [fl_famlinkFC]              INT      NULL
);

