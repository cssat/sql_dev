CREATE TABLE [dbo].[PROVIDER_NOTES_TYPE_DIM] (
    [ID_PROVIDER_NOTES_TYPE_DIM] INT           NOT NULL,
    [CD_CTGRY]                   INT           NULL,
    [TX_CATEGORY]                VARCHAR (200) NULL,
    [CD_TYPE]                    INT           NULL,
    [TX_CATEGORY_TYPE]           VARCHAR (200) NULL,
    [DT_ROW_BEGIN]               DATETIME      NULL,
    [DT_ROW_END]                 DATETIME      NULL,
    [ID_CYCLE]                   INT           NULL,
    [IS_CURRENT]                 INT           NULL,
    CONSTRAINT [PK_ID_PROVIDER_NOTES_TYPE_DIM] PRIMARY KEY CLUSTERED ([ID_PROVIDER_NOTES_TYPE_DIM] ASC)
);

