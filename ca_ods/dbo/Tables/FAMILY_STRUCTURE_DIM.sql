CREATE TABLE [dbo].[FAMILY_STRUCTURE_DIM] (
    [ID_FAMILY_STRUCTURE_DIM] INT           NOT NULL,
    [CD_CRTKR]                INT           NULL,
    [TX_CRTKR]                VARCHAR (200) NULL,
    [DT_ROW_BEGIN]            DATETIME      NULL,
    [DT_ROW_END]              DATETIME      NULL,
    [ID_CYCLE]                INT           NULL,
    [IS_CURRENT]              INT           NULL,
    CONSTRAINT [pk_ID_FAMILY_STRUCTURE_DIM] PRIMARY KEY CLUSTERED ([ID_FAMILY_STRUCTURE_DIM] ASC)
);

