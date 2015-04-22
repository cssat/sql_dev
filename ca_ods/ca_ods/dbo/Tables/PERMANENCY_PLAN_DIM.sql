CREATE TABLE [dbo].[PERMANENCY_PLAN_DIM] (
    [ID_PERMANENCY_PLAN_DIM] INT           NOT NULL,
    [CD_RESULT]              INT           NULL,
    [TX_PERM_PLAN]           VARCHAR (200) NULL,
    [TX_PERM_TYPE]           VARCHAR (200) NULL,
    [DT_ROW_BEGIN]           DATETIME      NULL,
    [DT_ROW_END]             DATETIME      NULL,
    [ID_CYCLE]               INT           NULL,
    [IS_CURRENT]             INT           NULL,
    CONSTRAINT [PK_ID_PERMANENCY_PLAN_DIM] PRIMARY KEY CLUSTERED ([ID_PERMANENCY_PLAN_DIM] ASC)
);

