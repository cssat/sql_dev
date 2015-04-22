CREATE TABLE [dbo].[RGAP_ELIGIBILITY_STATUS_DIM] (
    [ID_RGAP_ELIGIBILITY_STATUS_DIM] INT           NOT NULL,
    [CD_RGAP_ELIG_STAT]              INT           NULL,
    [TX_RGAP_ELIG_STAT]              VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                   DATETIME      NULL,
    [DT_ROW_END]                     DATETIME      NULL,
    [ID_CYCLE]                       INT           NULL,
    [IS_CURRENT]                     INT           NULL,
    CONSTRAINT [PK_RGAP_ELIGIBILITY_STATUS_DIM] PRIMARY KEY CLUSTERED ([ID_RGAP_ELIGIBILITY_STATUS_DIM] ASC)
);

