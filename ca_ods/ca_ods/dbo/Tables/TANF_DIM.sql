CREATE TABLE [dbo].[TANF_DIM] (
    [ID_TANF_DIM]                   INT           NOT NULL,
    [CD_APPLICATION_CHILD_UNDER_18] CHAR (1)      NULL,
    [TX_APPLICATION_CHILD_UNDER_18] VARCHAR (200) NULL,
    [CD_ELIGIBILITY_DECISION]       INT           NULL,
    [TX_ELIGIBILITY_DECISION]       VARCHAR (200) NULL,
    [CD_EMERGENCY_ASSISTANCE_EXIST] CHAR (1)      NULL,
    [TX_EMERGENCY_ASSISTANCE_EXIST] VARCHAR (200) NULL,
    [CD_TANF_STAT]                  CHAR (1)      NULL,
    [TX_TANF_STAT]                  VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                  DATETIME      NULL,
    [DT_ROW_END]                    DATETIME      NULL,
    [ID_CYCLE]                      INT           NULL,
    [IS_CURRENT]                    INT           NULL,
    PRIMARY KEY CLUSTERED ([ID_TANF_DIM] ASC)
);

