CREATE TABLE [ref].[match_pk_gender] (
	[pk_gender] TINYINT NOT NULL
	,[pk_gender_match_code] TINYINT NOT NULL
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_pk_gender_code] ON [ref].[match_pk_gender] (
	[pk_gender]
	) INCLUDE (
	[pk_gender_match_code]
	)
GO

CREATE NONCLUSTERED INDEX [idx_match_pk_gender_match] ON [ref].[match_pk_gender] (
	[pk_gender_match_code]
	) INCLUDE (
	[pk_gender]
	)
GO
