﻿CREATE TABLE [dbo].[IL_NYTD_QUESTIONS_FACT] (
    [ID_IL_NYTD_QUESTIONS_FACT]          INT      NOT NULL,
    [ID_IL_NYTD_QUESTIONS]               INT      NULL,
    [ID_INDEPENDENT_LIVING_FACT]         INT      NULL,
    [ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] INT      NULL,
    [ID_CALENDAR_DIM_SURVEY_COMPLETED]   INT      NULL,
    [DT_SURVEY_COMPLETED]                DATETIME NULL,
    PRIMARY KEY CLUSTERED ([ID_IL_NYTD_QUESTIONS_FACT] ASC),
    CONSTRAINT [fk_IL_NYTD_QUESTIONS_FACT_ID_CALENDAR_DIM_SURVEY_COMPLETED] FOREIGN KEY ([ID_CALENDAR_DIM_SURVEY_COMPLETED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_IL_NYTD_QUESTIONS_FACT_ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] FOREIGN KEY ([ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM]) REFERENCES [dbo].[IL_NYTD_QUESTIONS_ATTRIBUTE_DIM] ([ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM]),
    CONSTRAINT [fk_IL_NYTD_QUESTIONS_FACT_ID_INDEPENDENT_LIVING_FACT] FOREIGN KEY ([ID_INDEPENDENT_LIVING_FACT]) REFERENCES [dbo].[INDEPENDENT_LIVING_FACT] ([ID_INDEPENDENT_LIVING_FACT])
);

