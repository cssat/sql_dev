CREATE TABLE [ref].[match_cd_placement_setting] (
	[cd_placement_setting] TINYINT NOT NULL
	,[placement_setting_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_placement_setting_code] ON [ref].[match_cd_placement_setting] (
	[cd_placement_setting]
	) INCLUDE (
	[placement_setting_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_cd_placement_setting_match] ON [ref].[match_cd_placement_setting] (
	[placement_setting_match_code]
	) INCLUDE (
	[cd_placement_setting]
	)
GO
