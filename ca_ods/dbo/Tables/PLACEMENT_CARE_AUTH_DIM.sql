CREATE TABLE [dbo].[PLACEMENT_CARE_AUTH_DIM] (
    [ID_PLACEMENT_CARE_AUTH_DIM] INT           NOT NULL,
    [CD_PLACEMENT_CARE_AUTH]     INT           NULL,
    [TX_PLACEMENT_CARE_AUTH]     VARCHAR (200) NULL,
    [CD_TRIBE]                   INT           NULL,
    [TX_TRIBE]                   VARCHAR (200) NULL,
    [DT_ROW_BEGIN]               DATETIME      NULL,
    [DT_ROW_END]                 DATETIME      NULL,
    [ID_CYCLE]                   INT           NULL,
    [IS_CURRENT]                 INT           NULL,
    CONSTRAINT [PK_ID_PLACEMENT_CARE_AUTH_DIM] PRIMARY KEY CLUSTERED ([ID_PLACEMENT_CARE_AUTH_DIM] ASC)
);

