CREATE TABLE [dbo].[LEGAL_STATUS_DIM] (
    [ID_LEGAL_STATUS_DIM] INT           NOT NULL,
    [CD_LGL_STAT]         INT           NULL,
    [TX_LGL_STAT]         VARCHAR (200) NULL,
    [DT_ROW_BEGIN]        DATETIME      NULL,
    [DT_ROW_END]          DATETIME      NULL,
    [ID_CYCLE]            INT           NULL,
    [IS_CURRENT]          INT           NULL,
    CONSTRAINT [PK_ID_LEGAL_STATUS_DIM] PRIMARY KEY CLUSTERED ([ID_LEGAL_STATUS_DIM] ASC)
);

