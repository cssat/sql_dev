CREATE TABLE [rodis].[portal_xwalk_ref_cnty] (
	[ref_cnty_pk] INT IDENTITY(1, 1) NOT NULL
	,[Portal_County_Code] INT NULL
	,[Portal_County] VARCHAR(20) NULL
	,[RODIS_County_Code] INT NULL
	,[RODIS_County] VARCHAR(20) NULL
	,PRIMARY KEY CLUSTERED ([ref_cnty_pk] ASC)
	)
