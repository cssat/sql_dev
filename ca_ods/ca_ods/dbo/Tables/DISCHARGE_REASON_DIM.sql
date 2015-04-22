CREATE TABLE [dbo].[DISCHARGE_REASON_DIM] (
    [ID_DISCHARGE_REASON_DIM] INT           NOT NULL,
    [CD_DSCH_RSN]             INT           NULL,
    [TX_DSCH_RSN]             VARCHAR (200) NULL,
    [CD_PLCM_DSCH_RSN]        INT           NULL,
    [TX_PLCM_DSCH_RSN]        VARCHAR (200) NULL,
    [DT_ROW_BEGIN]            DATETIME      NULL,
    [DT_ROW_END]              DATETIME      NULL,
    [ID_CYCLE]                INT           NULL,
    [IS_CURRENT]              INT           NULL,
    CONSTRAINT [PK_DISCHARGE_REASON_DIM] PRIMARY KEY CLUSTERED ([ID_DISCHARGE_REASON_DIM] ASC)
);

