﻿CREATE TABLE [dbo].[LEGAL_ACTION_DIM] (
    [ID_LEGAL_ACTION_DIM] INT           NOT NULL,
    [CD_LEGAL_ACTION]     INT           NULL,
    [TX_LEGAL_ACTION]     VARCHAR (200) NULL,
    [DT_ROW_BEGIN]        DATETIME      NULL,
    [DT_ROW_END]          DATETIME      NULL,
    [ID_CYCLE]            NUMERIC (18)  NULL,
    [IS_CURRENT]          NUMERIC (18)  NULL,
    CONSTRAINT [PK_LEGAL_ACTION_DIM] PRIMARY KEY CLUSTERED ([ID_LEGAL_ACTION_DIM] ASC)
);

