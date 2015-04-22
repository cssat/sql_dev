CREATE TABLE [dbo].[CASE_PARTICIPANT_STATUS_DIM] (
    [ID_CASE_PARTICIPANT_STATUS_DIM] INT          NOT NULL,
    [ID_CASE]                        INT          NULL,
    [ID_PRSN]                        INT          NULL,
    [ID_CASE_DIM]                    INT          NULL,
    [ID_PEOPLE_DIM]                  INT          NULL,
    [CD_PARTICIPANT_STATUS]          CHAR (1)     NULL,
    [TX_PARTICIPANT_STATUS]          VARCHAR (50) NULL,
    [CD_PARTICIPANT_STATUS_REASON]   INT          NULL,
    [TX_PARTICIPANT_STATUS_REASON]   VARCHAR (50) NULL,
    [DT_ROW_BEGIN]                   DATETIME     NULL,
    [DT_ROW_END]                     DATETIME     NULL,
    [ID_CYCLE]                       INT          NULL,
    [IS_CURRENT]                     INT          NULL,
    CONSTRAINT [PK_CASE_PARTICIPANT_STATUS_DIM] PRIMARY KEY CLUSTERED ([ID_CASE_PARTICIPANT_STATUS_DIM] ASC)
);

