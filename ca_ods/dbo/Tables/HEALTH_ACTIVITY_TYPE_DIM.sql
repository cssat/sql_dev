CREATE TABLE [dbo].[HEALTH_ACTIVITY_TYPE_DIM] (
    [ID_HEALTH_ACTIVITY_TYPE_DIM] INT           NOT NULL,
    [TX_HLTH_ACTVTY]              VARCHAR (200) NULL,
    [TX_SOURCE_TABLE]             VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                DATETIME      NULL,
    [DT_ROW_END]                  DATETIME      NULL,
    [ID_CYCLE]                    INT           NULL,
    [IS_CURRENT]                  INT           NULL,
    CONSTRAINT [PK_HEALTH_ACTIVITY_TYPE_DIM] PRIMARY KEY CLUSTERED ([ID_HEALTH_ACTIVITY_TYPE_DIM] ASC)
);

