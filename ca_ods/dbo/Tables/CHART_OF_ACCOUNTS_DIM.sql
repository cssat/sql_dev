CREATE TABLE [dbo].[CHART_OF_ACCOUNTS_DIM] (
    [ID_CHART_OF_ACCOUNTS_DIM] INT         NOT NULL,
    [ID_CHART_OF_ACCOUNTS]     INT         NULL,
    [CD_SRVC]                  INT         NULL,
    [TX_ALLOCATION]            VARCHAR (4) NULL,
    [TX_APPROPRIATION_INDEX]   VARCHAR (3) NULL,
    [TX_FUND]                  VARCHAR (3) NULL,
    [TX_PROGRAM_INDEX]         VARCHAR (5) NULL,
    [TX_SOURCE_OF_FUNDS]       CHAR (1)    NULL,
    [TX_SUB_OBJECT]            VARCHAR (2) NULL,
    [TX_SUB_SUB_OBJECT]        VARCHAR (4) NULL,
    [DT_END]                   DATETIME    NULL,
    [DT_START]                 DATETIME    NULL,
    [DT_ROW_BEGIN]             DATETIME    NULL,
    [DT_ROW_END]               DATETIME    NULL,
    [ID_CYCLE]                 INT         NULL,
    [IS_CURRENT]               INT         NULL,
    CONSTRAINT [PK_CHART_OF_ACCOUNTS_DIM] PRIMARY KEY CLUSTERED ([ID_CHART_OF_ACCOUNTS_DIM] ASC)
);

