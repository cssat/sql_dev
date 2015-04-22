CREATE TABLE [dbo].[MENTAL_HEALTH_EVAL_DIM] (
    [ID_MENTAL_HEALTH_EVAL_DIM] INT           NOT NULL,
    [CD_EVAL_RESULT]            INT           NULL,
    [TX_EVAL_RESULT]            VARCHAR (200) NULL,
    [CD_EVAL_TYPE]              INT           NULL,
    [TX_EVAL_TYPE]              VARCHAR (200) NULL,
    [TX_IN_OUT_PATIENT]         VARCHAR (200) NULL,
    [DT_ROW_BEGIN]              DATETIME      NULL,
    [DT_ROW_END]                DATETIME      NULL,
    [ID_CYCLE]                  INT           NULL,
    [IS_CURRENT]                INT           NULL,
    CONSTRAINT [pk_ID_MENTAL_HEALTH_EVAL_DIM] PRIMARY KEY CLUSTERED ([ID_MENTAL_HEALTH_EVAL_DIM] ASC)
);

