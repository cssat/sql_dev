CREATE TABLE [dbo].[AGREEMENT_DIM] (
    [ID_AGREEMENT_DIM]  INT           NOT NULL,
    [CD_ADPTN_SUB_TYPE] INT           NULL,
    [TX_ADPTN_SUB_TYPE] VARCHAR (200) NULL,
    [CD_AGRM_TYPE]      INT           NULL,
    [TX_AGRM_TYPE]      VARCHAR (200) NULL,
    [CD_STAT]           INT           NULL,
    [TX_STAT]           VARCHAR (200) NULL,
    [DT_ROW_BEGIN]      DATETIME      NULL,
    [DT_ROW_END]        DATETIME      NULL,
    [ID_CYCLE]          INT           NULL,
    [IS_CURRENT]        INT           NULL,
    CONSTRAINT [PK_ID_AGREEMENT_DIM] PRIMARY KEY CLUSTERED ([ID_AGREEMENT_DIM] ASC)
);

