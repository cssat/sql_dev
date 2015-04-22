﻿CREATE TABLE [dbo].[AUTHORIZATION_DIM] (
    [ID_AUTHORIZATION_DIM] INT           NOT NULL,
    [CD_AUTH_STATUS]       INT           NULL,
    [TX_AUTH_STATUS]       VARCHAR (200) NULL,
    [DT_ROW_BEGIN]         DATETIME      NULL,
    [DT_ROW_END]           DATETIME      NULL,
    [ID_CYCLE]             INT           NULL,
    [IS_CURRENT]           INT           NULL,
    CONSTRAINT [PK_ID_AUTHORIZATION_DIM] PRIMARY KEY CLUSTERED ([ID_AUTHORIZATION_DIM] ASC)
);

