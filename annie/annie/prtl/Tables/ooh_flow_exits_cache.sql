﻿CREATE TABLE [prtl].[ooh_flow_exits_cache] (
	[qry_type] TINYINT NOT NULL , 
    [date_type] TINYINT NOT NULL, 
    [start_date] DATE NOT NULL, 
	[age_grouping_cd] TINYINT NOT NULL, 
	[pk_gender] TINYINT NOT NULL, 
	[cd_race_census] TINYINT NOT NULL, 
	[initial_cd_placement_setting] TINYINT NOT NULL, 
	[longest_cd_placement_setting] TINYINT NOT NULL, 
	[cd_county] TINYINT NOT NULL, 
	[bin_dependency_cd] TINYINT NOT NULL, 
	[bin_los_cd] TINYINT NOT NULL, 
	[bin_placement_cd] TINYINT NOT NULL, 
	[bin_ihs_service_cd] TINYINT NOT NULL, 
	[cd_reporter_type] TINYINT NOT NULL, 
	[cd_access_type] TINYINT NOT NULL, 
	[cd_allegation] TINYINT NOT NULL, 
	[cd_finding] TINYINT NOT NULL, 
	[cd_discharge_type] TINYINT NOT NULL, 
    [cnt_exits] INT NOT NULL, 
    [x1] FLOAT NOT NULL, 
    [x2] FLOAT NOT NULL, 
    [jit_exits] INT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ooh_flow_exits_cache] ON [prtl].[ooh_flow_exits_cache] (
	[bin_dependency_cd]
	,[age_grouping_cd]
	,[pk_gender]
	,[cd_race_census]
	,[initial_cd_placement_setting]
	,[longest_cd_placement_setting]
	,[cd_county]
	,[bin_los_cd]
	,[bin_placement_cd]
	,[bin_ihs_service_cd]
	,[cd_reporter_type]
	,[cd_access_type]
	,[cd_allegation]
	,[cd_finding]
	) INCLUDE (
	[qry_type]
	,[date_type]
	,[start_date]
	,[cd_discharge_type]
	,[jit_exits]
	)
GO