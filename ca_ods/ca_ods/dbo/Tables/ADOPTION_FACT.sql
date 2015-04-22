﻿CREATE TABLE [dbo].[ADOPTION_FACT] (
    [ID_ADOPTION_FACT]                   INT      NOT NULL,
    [ID_ELIG]                            INT      NULL,
    [ID_ELIG_REDET]                      INT      NULL,
    [ID_ADOPTION_STATUS_DIM]             INT      NULL,
    [ID_CALENDAR_DIM_COMPLETE]           INT      NULL,
    [ID_CALENDAR_DIM_EFFECTIVE_ELIGIBLE] INT      NULL,
    [ID_CALENDAR_DIM_TERMINATED]         INT      NULL,
    [ID_CASE_DIM]                        INT      NULL,
    [ID_PEOPLE_DIM_CHILD]                INT      NULL,
    [FL_CMPLT]                           INT      NULL,
    [FL_VOID]                            TINYINT  NULL,
    [DT_CMPLT]                           DATETIME NULL,
    [ID_PRSN_CHILD]                      INT      NULL,
    [ID_CASE]                            INT      NULL,
    CONSTRAINT [pk_ID_ADOPTION_FACT] PRIMARY KEY CLUSTERED ([ID_ADOPTION_FACT] ASC),
    CONSTRAINT [fk_af_ID_CASE_DIM] FOREIGN KEY ([ID_CASE_DIM]) REFERENCES [dbo].[CASE_DIM] ([ID_CASE_DIM]),
    CONSTRAINT [fk_af_ID_PEOPLE_DIM_CHILD] FOREIGN KEY ([ID_PEOPLE_DIM_CHILD]) REFERENCES [dbo].[PEOPLE_DIM] ([ID_PEOPLE_DIM]),
    CONSTRAINT [fk_ID_ADOPTION_STATUS_DIM] FOREIGN KEY ([ID_ADOPTION_STATUS_DIM]) REFERENCES [dbo].[ADOPTION_STATUS_DIM] ([ID_ADOPTION_STATUS_DIM]),
    CONSTRAINT [fk_ID_CALENDAR_DIM_COMPLETE] FOREIGN KEY ([ID_CALENDAR_DIM_COMPLETE]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_ID_CALENDAR_DIM_EFFECTIVE_ELIGIBLE] FOREIGN KEY ([ID_CALENDAR_DIM_EFFECTIVE_ELIGIBLE]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_ID_CALENDAR_DIM_TERMINATED] FOREIGN KEY ([ID_CALENDAR_DIM_TERMINATED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM])
);

