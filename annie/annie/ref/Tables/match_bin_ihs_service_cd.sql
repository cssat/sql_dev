CREATE TABLE [ref].[match_bin_ihs_service_cd] (
	[bin_ihs_service_cd] TINYINT NOT NULL
	,[bin_ihs_service_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_ihs_service_cd_code] ON [ref].[match_bin_ihs_service_cd] (
	[bin_ihs_service_cd]
	) INCLUDE (
	[bin_ihs_service_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_bin_ihs_service_cd_match] ON [ref].[match_bin_ihs_service_cd] (
	[bin_ihs_service_match_code]
	) INCLUDE (
	[bin_ihs_service_cd]
	)
GO
