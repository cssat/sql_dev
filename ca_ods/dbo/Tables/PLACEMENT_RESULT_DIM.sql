CREATE TABLE [dbo].[PLACEMENT_RESULT_DIM] (
    [ID_PLACEMENT_RESULT_DIM] INT           NOT NULL,
    [CD_ENDING_PURPOSE]       INT           NULL,
    [TX_END_PURPOSE]          VARCHAR (200) NULL,
    [CD_END_RSN]              INT           NULL,
    [TX_END_RSN]              VARCHAR (200) NULL,
    [DT_ROW_BEGIN]            DATETIME      NULL,
    [DT_ROW_END]              DATETIME      NULL,
    [ID_CYCLE]                INT           NULL,
    [IS_CURRENT]              INT           NULL,
    CONSTRAINT [PK_PLACEMENT_RESULT_DIM] PRIMARY KEY CLUSTERED ([ID_PLACEMENT_RESULT_DIM] ASC)
);

