CREATE TABLE [dbo].[LEGAL_RESULT_DIM] (
    [ID_LEGAL_RESULT_DIM] INT           NOT NULL,
    [CD_RESULT]           INT           NULL,
    [TX_RESULT]           VARCHAR (200) NULL,
    [DT_ROW_BEGIN]        DATETIME      NULL,
    [DT_ROW_END]          DATETIME      NULL,
    [ID_CYCLE]            INT           NULL,
    [IS_CURRENT]          INT           NULL,
    CONSTRAINT [PK_ID_LEGAL_RESULT_DIM] PRIMARY KEY CLUSTERED ([ID_LEGAL_RESULT_DIM] ASC)
);

