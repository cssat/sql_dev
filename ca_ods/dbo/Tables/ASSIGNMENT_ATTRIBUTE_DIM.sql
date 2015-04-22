CREATE TABLE [dbo].[ASSIGNMENT_ATTRIBUTE_DIM] (
    [ID_ASSIGNMENT_ATTRIBUTE_DIM] INT           NOT NULL,
    [CD_ASGN_CTGRY]               INT           NULL,
    [TX_ASGN_CTGRY]               VARCHAR (200) NULL,
    [CD_ASGN_ROLE]                INT           NULL,
    [TX_ASGN_ROLE]                VARCHAR (200) NULL,
    [CD_ASGN_RSPNS]               INT           NULL,
    [TX_ASGN_RSPNS]               VARCHAR (200) NULL,
    [CD_ASGN_TYPE]                INT           NULL,
    [TX_ASGN_TYPE]                VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                DATETIME      NULL,
    [DT_ROW_END]                  DATETIME      NULL,
    [ID_CYCLE]                    INT           NULL,
    [IS_CURRENT]                  INT           NULL,
    CONSTRAINT [PK_ID_ASSIGNMENT_ATTRIBUTE_DIM] PRIMARY KEY CLUSTERED ([ID_ASSIGNMENT_ATTRIBUTE_DIM] ASC)
);

