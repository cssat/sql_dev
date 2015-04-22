CREATE TABLE [dbo].[PAYMENT_DIM] (
    [ID_PAYMENT_DIM]            INT           NOT NULL,
    [CD_PAYMENT_SRVC_UNIT_TYPE] INT           NULL,
    [tx_PAYMENT_SRVC_UNIT_TYPE] VARCHAR (200) NULL,
    [DT_ROW_BEGIN]              DATETIME      NULL,
    [DT_ROW_END]                DATETIME      NULL,
    [ID_CYCLE]                  INT           NULL,
    [IS_CURRENT]                INT           NULL,
    CONSTRAINT [PK_ID_PAYMENT_DIM] PRIMARY KEY CLUSTERED ([ID_PAYMENT_DIM] ASC)
);

