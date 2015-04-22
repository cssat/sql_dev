CREATE TABLE [dbo].[CASE_NOTE_TYPE_DIM] (
    [ID_CASE_NOTE_TYPE_DIM] INT           NOT NULL,
    [CD_ACTIVITY]           INT           NULL,
    [TX_ACTIVITY]           VARCHAR (255) NULL,
    [CD_CTGRY]              INT           NULL,
    [TX_CTGRY]              VARCHAR (200) NULL,
    [CD_TYPE]               INT           NULL,
    [TX_TYPE]               VARCHAR (200) NULL,
    [DT_ROW_BEGIN]          DATETIME      NULL,
    [DT_ROW_END]            DATETIME      NULL,
    [ID_CYCLE]              INT           NULL,
    [IS_CURRENT]            INT           NULL,
    CONSTRAINT [PK_ID_CASE_NOTE_TYPE_DIM] PRIMARY KEY CLUSTERED ([ID_CASE_NOTE_TYPE_DIM] ASC)
);

