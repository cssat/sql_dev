USE [dbCoreAdministrativeTables]
GO

/****** Object:  Table [ospi].[enrollment_temp]    Script Date: 04/18/2013 15:06:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ospi].[enrollment_temp]') AND type in (N'U'))
DROP TABLE [ospi].[enrollment_temp]
GO

USE [dbCoreAdministrativeTables]
GO

/****** Object:  Table [ospi].[enrollment_temp]    Script Date: 04/18/2013 15:06:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [ospi].[enrollment_temp](
	[int_researchID] [int] NOT NULL,
	[districtID] [int] NOT NULL,
	[SchoolCode] [int] NOT NULL,
	[DateEnrolledInDistrict] [datetime] NOT NULL,
	[DateExitedFromDistrict] [datetime] NOT NULL,
	[DateEnrolledInSchool] [datetime] NOT NULL,
	[DateExitedFromSchool] [datetime] NOT NULL,
	[EnrollmentStatuS] [char](2) NULL,
	[frst_enr_mnth] [int] NULL,
	[last_enr_mnth] [int] NULL,
	[min_grade_level] [char](2) NULL,
	[max_grade_level] [char](2) NULL,
	[fl_prm_txfr] [smallint] NULL,
	[fl_prm_txfr_inter] [smallint] NULL,
	[fl_prm_txfr_intra] [smallint] NULL,
	[fl_other_txfr] [smallint] NULL,
	[fl_other_txfr_inter] [smallint] NULL,
	[fl_other_txfr_intra] [smallint] NULL,
	[overall_txfr_rank] [int] NULL,
	[prom_txfr_rank] [int] NULL,
	[other_txfr_rank] [int] NULL,
	[enrollment_duration] [int] NULL,
	[approx_age_enroll_start] [int] NULL,
	[approx_age_enroll_end] [int] NULL,
	[MonthYearBirth] [int] NULL,
	[schoolyearend] [int] NULL,
	[fl_delete] [int] NULL,
	[row_num] [int] NULL,
	[school_enroll_date] [datetime] NULL,
	[school_exit_date] [datetime] NULL,
	[int_min_grade] [int] NULL,
	[int_max_grade] [int] NULL,
 CONSTRAINT [PK_ospi_enrollment_temp] PRIMARY KEY CLUSTERED 
(
	[int_researchID] ASC,
	[districtID] ASC,
	[SchoolCode] ASC,
	[DateEnrolledInSchool] ASC,
	[DateExitedFromSchool] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

