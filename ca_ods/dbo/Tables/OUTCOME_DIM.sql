﻿CREATE TABLE [dbo].[OUTCOME_DIM] (
	[ID_OUTCOME_DIM] INT NULL
	,[CD_MEETING_OUTCOME] INT NULL
	,[TX_MEETING_OUTCOME] VARCHAR(200) NULL
	,[DT_ROW_BEGIN] DATETIME NULL
	,[DT_ROW_END] DATETIME NULL
	,[ID_CYCLE] INT NULL
	,[IS_CURRENT] INT NULL
	)