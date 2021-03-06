﻿CREATE TABLE [dbo].[CASE_NOTE_FACT] (
    [ID_CASE_NOTE_FACT]           INT           NOT NULL,
    [ID_CAN_ACTIVITIES]           INT           NULL,
    [ID_CAN_EVENT]                INT           NULL,
    [ID_EPSD]                     INT           NULL,
    [ID_CALENDAR_DIM_OCCURRED]    INT           NULL,
    [ID_CALENDAR_DIM_PRIOR_VISIT] INT           NULL,
    [ID_CASE_DIM]                 INT           NULL,
    [ID_CASE_NOTE_TYPE_DIM]       INT           NULL,
    [ID_LEGAL_STATUS_DIM]         INT           NULL,
    [ID_LOCATION_DIM]             INT           NULL,
    [ID_PEOPLE_DIM]               INT           NULL,
    [ID_WORKER_DIM]               INT           NULL,
    [CD_LOCATION]                 INT           NULL,
    [TX_LOCATION]                 VARCHAR (200) NULL,
    [FL_VISIT_ACTUAL]             INT           NULL,
    [FL_VISIT_ANY]                INT           NULL,
    [QT_PRIOR_FULL_MONTH_VISITS]  INT           NULL,
    [QT_PRIOR_VISITS]             INT           NULL,
    [FL_EXPUNGED]                 CHAR (1)      NULL,
    [ID_PRSN]                     INT           NULL,
    [ID_CASE]                     INT           NULL,
    CONSTRAINT [PK_ID_CASE_NOTE_FACT] PRIMARY KEY CLUSTERED ([ID_CASE_NOTE_FACT] ASC),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_CALENDAR_DIM_OCCURRED] FOREIGN KEY ([ID_CALENDAR_DIM_OCCURRED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_CALENDAR_DIM_PRIOR_VISIT] FOREIGN KEY ([ID_CALENDAR_DIM_PRIOR_VISIT]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_CASE_DIM] FOREIGN KEY ([ID_CASE_DIM]) REFERENCES [dbo].[CASE_DIM] ([ID_CASE_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_CASE_NOTE_TYPE_DIM] FOREIGN KEY ([ID_CASE_NOTE_TYPE_DIM]) REFERENCES [dbo].[CASE_NOTE_TYPE_DIM] ([ID_CASE_NOTE_TYPE_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_LEGAL_STATUS_DIM] FOREIGN KEY ([ID_LEGAL_STATUS_DIM]) REFERENCES [dbo].[LEGAL_STATUS_DIM] ([ID_LEGAL_STATUS_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_LOCATION_DIM] FOREIGN KEY ([ID_LOCATION_DIM]) REFERENCES [dbo].[LOCATION_DIM] ([ID_LOCATION_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_PEOPLE_DIM] FOREIGN KEY ([ID_PEOPLE_DIM]) REFERENCES [dbo].[PEOPLE_DIM] ([ID_PEOPLE_DIM]),
    CONSTRAINT [fk_CASE_NOTE_FACT_ID_WORKER_DIM] FOREIGN KEY ([ID_WORKER_DIM]) REFERENCES [dbo].[WORKER_DIM] ([ID_WORKER_DIM])
);

