USE [dbCoreAdministrativeTables]
GO

/****** Object:  Index [PK__temp__18826C35]    Script Date: 04/30/2013 15:56:00 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ospi].[temp]') AND name = N'PK__temp__18826C35')
ALTER TABLE [ospi].[temp] DROP CONSTRAINT [PK__temp__18826C35]
GO

USE [dbCoreAdministrativeTables]
GO

/****** Object:  Index [PK__temp__18826C35]    Script Date: 04/30/2013 15:56:00 ******/
ALTER TABLE [ospi].[temp] ADD PRIMARY KEY CLUSTERED 
(
	[int_researchID] ASC,
	[DistrictID] ASC,
	[SchoolCode] ASC,
	[DateEnrolledInSchool] ASC,
	[DateExitedFromSchool] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


select * from ospi.temp where int_researchID=711989 and districtID= 25118 and schoolcode=2214 

update ospi.temp
set min_grade_level=7,int_min_grade=7,frst_enr_mnth=200503
where int_researchID=711989 and districtID= 25118 and schoolcode=2214 and min_grade_level=12

delete from ospi.temp  where int_researchID=711989 and districtID= 25118 and schoolcode=2214 and row_num_asc=3


--Jun 21 2004 12:00AM, Sep  1 2010 12:00AM)

dateadd(dd,1,DateExitedFromSchool)