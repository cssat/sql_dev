CREATE TABLE [dbo].[PLACEMENT_TYPE_DIM] (
    [ID_PLACEMENT_TYPE_DIM] INT           NOT NULL,
    [CD_EPSD_TYPE]          INT           NULL,
    [TX_EPSD_TYPE]          VARCHAR (200) NULL,
    [CD_PLCM_SETNG]         INT           NULL,
    [TX_PLCM_SETNG]         VARCHAR (200) NULL,
    [DT_ROW_BEGIN]          DATETIME      NULL,
    [DT_ROW_END]            DATETIME      NULL,
    [ID_CYCLE]              INT           NULL,
    [IS_CURRENT]            INT           NULL,
    CONSTRAINT [PK_ID_PLACEMENT_TYPE_DIM] PRIMARY KEY CLUSTERED ([ID_PLACEMENT_TYPE_DIM] ASC)
);

