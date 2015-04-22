﻿CREATE TABLE [dbo].[EDUCATION_RECORDS_REQUEST_REFERRAL_FACT] (
    [ID_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT] INT      NOT NULL,
    [ID_REQUEST]                                 INT      NULL,
    [ID_REFERRAL]                                INT      NULL,
    [ID_EDUCATION_FACT]                          INT      NULL,
    [ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM]  INT      NULL,
    [ID_CALENDAR_DIM_REQUESTED]                  INT      NULL,
    [ID_CALENDAR_DIM_RECEIVED]                   INT      NULL,
    [ID_CALENDAR_DIM_REFERRAL]                   INT      NULL,
    [DT_REQUESTED]                               DATETIME NULL,
    [DT_RECEIVED]                                DATETIME NULL,
    [DT_REFERRAL]                                DATETIME NULL,
    [FL_EXPUNGED]                                CHAR (1) NULL,
    [ID_EDUC]                                    INT      NULL,
    PRIMARY KEY CLUSTERED ([ID_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT] ASC),
    CONSTRAINT [fk_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT_ID_CALENDAR_DIM_RECEIVED] FOREIGN KEY ([ID_CALENDAR_DIM_RECEIVED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT_ID_CALENDAR_DIM_REFERRAL] FOREIGN KEY ([ID_CALENDAR_DIM_REFERRAL]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT_ID_CALENDAR_DIM_REQUESTED] FOREIGN KEY ([ID_CALENDAR_DIM_REQUESTED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT_ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] FOREIGN KEY ([ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM]) REFERENCES [dbo].[EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] ([ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM])
);

