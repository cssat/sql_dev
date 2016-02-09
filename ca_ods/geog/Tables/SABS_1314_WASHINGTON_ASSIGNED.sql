﻿CREATE TABLE [geog].[SABS_1314_WASHINGTON_ASSIGNED] (
	[OBJECTID] INT IDENTITY(1, 1) NOT NULL
	,[Shape] GEOMETRY NULL
	,[SrcName] NVARCHAR(100) NULL
	,[ncessch] NVARCHAR(254) NULL
	,[schnam] NVARCHAR(254) NULL
	,[leaid] NVARCHAR(7) NULL
	,[updateDate] DATETIME2(7) NULL
	,[gslo] NVARCHAR(2) NULL
	,[gshi] NVARCHAR(2) NULL
	,[defacto] NVARCHAR(3) NULL
	,[stAbbrev] NVARCHAR(2) NULL
	,[sLevel] NVARCHAR(1) NULL
	,[openEnroll] NVARCHAR(1) NULL
	,[MultiBdy] NVARCHAR(1) NULL
	,[Shape_Leng] NUMERIC(38, 8) NULL
	,PRIMARY KEY CLUSTERED ([OBJECTID] ASC)
	)
