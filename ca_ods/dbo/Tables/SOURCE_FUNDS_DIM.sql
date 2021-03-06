﻿CREATE TABLE [dbo].[SOURCE_FUNDS_DIM] (
    [ID_SOURCE_FUNDS_DIM] INT           NOT NULL,
    [CD_ELIG_STATUS]      INT           NULL,
    [TX_ELIG_STATUS]      VARCHAR (200) NULL,
    [CD_SOURCE_FUNDS]     CHAR (1)      NULL,
    [TX_SOURCE_FUNDS]     VARCHAR (200) NULL,
    [DT_ROW_BEGIN]        DATETIME      NULL,
    [DT_ROW_END]          DATETIME      NULL,
    [ID_CYCLE]            INT           NULL,
    [IS_CURRENT]          INT           NULL,
    CONSTRAINT [PK_ID_SOURCE_FUNDS_DIM] PRIMARY KEY CLUSTERED ([ID_SOURCE_FUNDS_DIM] ASC)
);

