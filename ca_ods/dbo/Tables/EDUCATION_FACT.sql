﻿CREATE TABLE [dbo].[EDUCATION_FACT] (
    [ID_EDUCATION_FACT]                INT          NOT NULL,
    [ID_EDUC]                          INT          NULL,
    [ID_EDUC_MAIN]                     INT          NULL,
    [ID_SCHOOL_HISTORY]                INT          NULL,
    [ID_STUDENT]                       VARCHAR (10) NULL,
    [ID_CALENDAR_DIM_CREATED]          INT          NULL,
    [ID_CALENDAR_DIM_EARNED_DIPLOMA]   INT          NULL,
    [ID_CALENDAR_DIM_ENROLLED]         INT          NULL,
    [ID_CALENDAR_DIM_ENROLLMENT_END]   INT          NULL,
    [ID_EDUCATION_DIM]                 INT          NULL,
    [ID_LOCATION_DIM_CASE]             INT          NULL,
    [ID_LOCATION_DIM_CHILD]            INT          NULL,
    [ID_PEOPLE_DIM_CHILD]              INT          NULL,
    [ID_SCHOOL_DIM]                    INT          NULL,
    [ID_WORKER_DIM_CASE]               INT          NULL,
    [ID_WORKER_DIM_CHILD]              INT          NULL,
    [TX_SCHOOL_YEAR]                   VARCHAR (15) NULL,
    [FL_ENROLLED_FULL_TIME]            INT          NULL,
    [FL_NO_SPECIAL_NEED]               INT          NULL,
    [FL_NO_SPECIAL_PROVIDED]           INT          NULL,
    [FL_OTHER]                         INT          NULL,
    [FL_PRIMARY_SCHOOL]                INT          NULL,
    [FL_RECEIVING_SPECIAL]             INT          NULL,
    [FL_SEVERE_BEHAVIORAL_ISSUES]      INT          NULL,
    [FL_SPECIAL_HISTORY]               INT          NULL,
    [FL_SPECIAL_PROVIDED]              INT          NULL,
    [CHILD_AGE]                        INT          NULL,
    [FL_EXPUNGED]                      CHAR (1)     NULL,
    [ID_PRSN_CHILD]                    INT          NULL,
    [ID_CALENDAR_DIM_ANTICIPATED_GRAD] INT          NULL,
    PRIMARY KEY CLUSTERED ([ID_EDUCATION_FACT] ASC),
    CONSTRAINT [fk_EDUCATION_FACT_ID_CALENDAR_DIM_CREATED] FOREIGN KEY ([ID_CALENDAR_DIM_CREATED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_CALENDAR_DIM_EARNED_DIPLOMA] FOREIGN KEY ([ID_CALENDAR_DIM_EARNED_DIPLOMA]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_CALENDAR_DIM_ENROLLED] FOREIGN KEY ([ID_CALENDAR_DIM_ENROLLED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_CALENDAR_DIM_ENROLLMENT_END] FOREIGN KEY ([ID_CALENDAR_DIM_ENROLLMENT_END]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_EDUCATION_DIM] FOREIGN KEY ([ID_EDUCATION_DIM]) REFERENCES [dbo].[EDUCATION_DIM] ([ID_EDUCATION_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_LOCATION_DIM_CASE] FOREIGN KEY ([ID_LOCATION_DIM_CASE]) REFERENCES [dbo].[LOCATION_DIM] ([ID_LOCATION_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_LOCATION_DIM_CHILD] FOREIGN KEY ([ID_LOCATION_DIM_CHILD]) REFERENCES [dbo].[LOCATION_DIM] ([ID_LOCATION_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_PEOPLE_DIM_CHILD] FOREIGN KEY ([ID_PEOPLE_DIM_CHILD]) REFERENCES [dbo].[PEOPLE_DIM] ([ID_PEOPLE_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_SCHOOL_DIM] FOREIGN KEY ([ID_SCHOOL_DIM]) REFERENCES [dbo].[SCHOOL_DIM] ([ID_SCHOOL_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_WORKER_DIM_CASE] FOREIGN KEY ([ID_WORKER_DIM_CASE]) REFERENCES [dbo].[WORKER_DIM] ([ID_WORKER_DIM]),
    CONSTRAINT [fk_EDUCATION_FACT_ID_WORKER_DIM_CHILD] FOREIGN KEY ([ID_WORKER_DIM_CHILD]) REFERENCES [dbo].[WORKER_DIM] ([ID_WORKER_DIM])
);

