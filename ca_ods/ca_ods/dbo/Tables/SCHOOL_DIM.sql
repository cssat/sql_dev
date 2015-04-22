CREATE TABLE [dbo].[SCHOOL_DIM] (
    [ID_SCHOOL_DIM]    INT           NOT NULL,
    [ID_SCHL]          INT           NULL,
    [ID_SCHL_CODE]     INT           NULL,
    [CD_SCHL_DISTRICT] INT           NULL,
    [TX_SCHL_DISTRICT] VARCHAR (200) NULL,
    [CD_SCHL_LEVEL]    CHAR (2)      NULL,
    [TX_SCHL_LEVEL]    VARCHAR (200) NULL,
    [FL_LEVEL_ELEM]    CHAR (1)      NULL,
    [FL_LEVEL_HIGH]    CHAR (1)      NULL,
    [FL_LEVEL_MIDDLE]  CHAR (1)      NULL,
    [NM_SCHL]          VARCHAR (200) NULL,
    [DT_ROW_BEGIN]     DATETIME      NULL,
    [DT_ROW_END]       DATETIME      NULL,
    [ID_CYCLE]         INT           NULL,
    [IS_CURRENT]       INT           NULL,
    CONSTRAINT [PK_ID_SCHOOL_DIM] PRIMARY KEY CLUSTERED ([ID_SCHOOL_DIM] ASC)
);

