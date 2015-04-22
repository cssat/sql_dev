CREATE TABLE [dbo].[INVESTIGATION_TYPE_DIM] (
    [ID_INVESTIGATION_TYPE_DIM] INT           NOT NULL,
    [CD_INVS_TYPE]              INT           NULL,
    [TX_INVS_TYPE]              VARCHAR (200) NULL,
    [DT_ROW_BEGIN]              DATETIME      NULL,
    [DT_ROW_END]                DATETIME      NULL,
    [ID_CYCLE]                  INT           NULL,
    [IS_CURRENT]                INT           NULL,
    CONSTRAINT [PK_ID_INVESTIGATION_TYPE_DIM] PRIMARY KEY CLUSTERED ([ID_INVESTIGATION_TYPE_DIM] ASC)
);

