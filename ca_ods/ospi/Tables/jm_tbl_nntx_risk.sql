CREATE TABLE [ospi].[jm_tbl_nntx_risk] (
	[int_researchid] INT NOT NULL
	,[rank_asc] INT NULL
	,[rank_desc] INT NULL
	,[districtid] INT NOT NULL
	,[schoolcode] INT NOT NULL
	,[dateenrolledinschool] DATETIME NOT NULL
	,[dateexitedfromschool] DATETIME NOT NULL
	,[int_min_grade] INT NULL
	,[int_max_grade] INT NULL
	,[enrollmentstatus] CHAR(2) NULL
	,[int_overall_startGradeLevel] INT NULL
	,[int_overall_stopGradeLevel] INT NULL
	,[fl_famlinkFC] INT NULL
	,[fl_other_txfr] SMALLINT NULL
	,[fl_migrant] INT NULL
	,[fl_homeless] INT NULL
	,[fl_504] INT NULL
	,[fl_specialed] INT NULL
	,[fl_privateschool] INT NULL
	,[fl_homebased] INT NULL
	,[gradelevel0405] INT NULL
	)
