CREATE TABLE [dbo].[IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] (
    [ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] INT           NOT NULL,
    [CD_TYPE]                            INT           NULL,
    [TX_TYPE]                            VARCHAR (200) NULL,
    [CD_PARTICIPATION_STATUS]            INT           NULL,
    [TX_PARTICIPATION_STATUS]            VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                       DATETIME      NULL,
    [DT_ROW_END]                         DATETIME      NULL,
    [ID_CYCLE]                           INT           NULL,
    [IS_CURRENT]                         INT           NULL,
    PRIMARY KEY CLUSTERED ([ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] ASC)
);

