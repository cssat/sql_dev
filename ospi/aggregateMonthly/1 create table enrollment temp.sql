USE [dbCoreAdministrativeTables]
GO

/****** Object:  Table [ospi].[temp]    Script Date: 04/29/2013 13:48:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
Drop table [ospi].[temp]
CREATE TABLE [ospi].[temp](
	[int_researchID] [int] NOT NULL,
	[DistrictID] [int] NOT NULL,
	[SchoolCode] [int] NOT NULL,
	[DateEnrolledInDistrict] [datetime] NULL,
	[DateExitedFromDistrict] [datetime] NULL,
	[DateEnrolledInSchool] [datetime] NOT NULL,
	[DateExitedFromSchool] [datetime] NOT NULL,
	[EnrollmentStatuS] [char](2) NULL,
	[frst_enr_mnth] [int] NULL,
	[last_enr_mnth] [int] NULL,
	[min_grade_level] [char](2) NULL,
	[max_grade_level] [char](2) NULL,
	[int_min_grade] [int] NULL,
	[int_max_grade] [int] NULL,
	[row_num_asc] [int] NULL,
	[row_num_desc] [int] NULL,
	[fl_multiple_primaryschool] [int] NULL,
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
	First_ZipCode int,
	Last_ZipCode int,
	[fl_delete] [int] NOT NULL,
	firstResidentDistrictID int,
	lastResidentDistrictID int,
PRIMARY KEY CLUSTERED 
(
	[int_researchID] ASC,
	[DistrictID] ASC,
	[SchoolCode] ASC,
	[DateEnrolledInSchool] ASC,
	[DateExitedFromSchool] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


