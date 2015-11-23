CREATE TABLE [prtl].[ia_safety_cache] (
	[row_id] INT NOT NULL
		CONSTRAINT [pk_ia_safety_cache] PRIMARY KEY,
    [month] TINYINT NOT NULL, 
	[qry_type] TINYINT NOT NULL, 
    [start_year] SMALLINT NOT NULL, 
    [age_sib_group_cd] TINYINT NOT NULL, 
    [cd_race_census] TINYINT NOT NULL, 
    [cd_county] TINYINT NOT NULL, 
    [cd_reporter_type] TINYINT NOT NULL, 
    [cd_access_type] TINYINT NOT NULL, 
    [cd_allegation] TINYINT NOT NULL, 
    [cd_finding] TINYINT NOT NULL, 
    [among_first_cmpt_rereferred] DECIMAL(9, 2) NOT NULL 
)
GO

CREATE NONCLUSTERED INDEX idx_ia_safety_cache ON prtl.ia_safety_cache (
	age_sib_group_cd
	,cd_race_census
	,cd_county
	,cd_reporter_type
	,cd_access_type
	,cd_allegation
	,cd_finding
	) INCLUDE (
	row_id
	,qry_type
	,start_year
	,month
	,among_first_cmpt_rereferred
	)
GO
