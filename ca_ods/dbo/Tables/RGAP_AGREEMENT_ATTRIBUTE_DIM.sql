CREATE TABLE [dbo].[RGAP_AGREEMENT_ATTRIBUTE_DIM] (
    [ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] INT           NOT NULL,
    [CD_RGAP_AGREEMENT_TYPE]          INT           NULL,
    [TX_RGAP_AGREEMENT_TYPE]          VARCHAR (200) NULL,
    [CD_RGAP_SUB_TYPE]                INT           NULL,
    [TX_RGAP_SUB_TYPE]                VARCHAR (200) NULL,
    [CD_RGAP_STAT]                    INT           NULL,
    [TX_RGAP_STAT]                    VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                    DATETIME      NULL,
    [DT_ROW_END]                      DATETIME      NULL,
    [ID_CYCLE]                        INT           NULL,
    [IS_CURRENT]                      INT           NULL,
    CONSTRAINT [PK_ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] PRIMARY KEY CLUSTERED ([ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] ASC)
);

