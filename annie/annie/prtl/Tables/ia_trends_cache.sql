CREATE TABLE [prtl].[ia_trends_cache] (
	[row_id] INT NOT NULL 
		CONSTRAINT [pk_ia_trends_cache] PRIMARY KEY, 
	[qry_type] TINYINT NOT NULL, 
	[date_type] TINYINT NOT NULL, 
	[start_date] DATETIME NOT NULL, 
	[age_sib_group_cd] TINYINT NOT NULL, 
	[cd_race_census] TINYINT NOT NULL, 
	[cd_county] TINYINT NOT NULL, 
	[cd_reporter_type] TINYINT NOT NULL, 
	[cd_access_type] TINYINT NOT NULL, 
	[cd_allegation] TINYINT NOT NULL, 
	[cd_finding] TINYINT NOT NULL,
	[cnt_start_date] INT NOT NULL,
	[cnt_opened] INT NOT NULL,
	[x1] FLOAT NOT NULL,
	[x2] FLOAT NOT NULL,
	[jit_start_date] INT NULL, 
	[jit_opened] INT NULL, 
	[rate_opened] DECIMAL(9, 2) NULL,
	[fl_include_perCapita] BIT NOT NULL DEFAULT 1
)
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_cache_builder] ON [prtl].[ia_trends_cache] (
	[age_sib_group_cd]
	,[cd_race_census]
	,[cd_county]
	,[start_date]
	) INCLUDE (
	[cnt_start_date]
	,[cnt_opened]
	,[jit_opened]
	)
GO

CREATE NONCLUSTERED INDEX [idx_ia_trends_cache] ON [prtl].[ia_trends_cache] (
	[age_sib_group_cd]
	,[cd_race_census]
	,[cd_county]
	,[cd_reporter_type]
	,[cd_access_type]
	,[cd_allegation]
	,[cd_finding]
	) INCLUDE (
	[row_id]
	,[qry_type]
	,[start_date]
	,[jit_start_date]
	,[jit_opened]
	,[rate_opened]
	,[fl_include_perCapita]
	)
GO
