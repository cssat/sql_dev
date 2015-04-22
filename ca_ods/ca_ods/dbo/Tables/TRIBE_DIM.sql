﻿CREATE TABLE [dbo].[TRIBE_DIM] (
    [ID_TRIBE_DIM]  INT           NOT NULL,
    [CD_TRIBE_TYPE] INT           NULL,
    [TX_TRIBE_TYPE] VARCHAR (200) NULL,
    [TX_TRIBE_NAME] VARCHAR (200) NULL,
    [FL_FED_TRIBE]  CHAR (1)      NULL,
    [DT_ROW_BEGIN]  DATETIME      NULL,
    [DT_ROW_END]    DATETIME      NULL,
    [ID_CYCLE]      INT           NULL,
    [IS_CURRENT]    INT           NULL,
    [ID_TRIBE]      INT           NULL,
    CONSTRAINT [PK_TRIBE_DIM] PRIMARY KEY CLUSTERED ([ID_TRIBE_DIM] ASC)
);

