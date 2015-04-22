CREATE TABLE [dbo].[TRAINING_TYPE_DIM] (
    [ID_TRAINING_TYPE_DIM] INT           NOT NULL,
    [CD_TRAINING_TYPE]     INT           NULL,
    [TX_TRAINING_TYPE]     VARCHAR (200) NULL,
    [DT_ROW_BEGIN]         DATETIME      NULL,
    [DT_ROW_END]           DATETIME      NULL,
    [ID_CYCLE]             INT           NULL,
    [IS_CURRENT]           INT           NULL,
    PRIMARY KEY CLUSTERED ([ID_TRAINING_TYPE_DIM] ASC)
);

