﻿CREATE TABLE [dbo].[RGAP_AGREEMENT_FACT] (
    [ID_RGAP_AGREEMENT_FACT]          INT NOT NULL,
    [ID_RGAP_AGREEMENT]               INT NULL,
    [ID_ORIG_RGAP_AGREEMENT]          INT NULL,
    [ID_CASE_DIM]                     INT NULL,
    [ID_PEOPLE_DIM]                   INT NULL,
    [ID_PROVIDER_DIM]                 INT NULL,
    [ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] INT NULL,
    [ID_CALENDAR_DIM_RGAP_EFFECTIVE]  INT NULL,
    [ID_CALENDAR_DIM_RGAP_END]        INT NULL,
    [ID_WORKER_DIM_RESPONSIBLE]       INT NULL,
    [ID_CASE]                         INT NULL,
    [ID_PRSN]                         INT NULL,
    [ID_PRVD_ORG]                     INT NULL,
    CONSTRAINT [PK_ID_v] PRIMARY KEY CLUSTERED ([ID_RGAP_AGREEMENT_FACT] ASC),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_CALENDAR_DIM_RGAP_EFFECTIVE] FOREIGN KEY ([ID_CALENDAR_DIM_RGAP_EFFECTIVE]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_CALENDAR_DIM_RGAP_END] FOREIGN KEY ([ID_CALENDAR_DIM_RGAP_END]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_CASE_DIM] FOREIGN KEY ([ID_CASE_DIM]) REFERENCES [dbo].[CASE_DIM] ([ID_CASE_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_PEOPLE_DIM] FOREIGN KEY ([ID_PEOPLE_DIM]) REFERENCES [dbo].[PEOPLE_DIM] ([ID_PEOPLE_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_PROVIDER_DIM] FOREIGN KEY ([ID_PROVIDER_DIM]) REFERENCES [dbo].[PROVIDER_DIM] ([ID_PROVIDER_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] FOREIGN KEY ([ID_RGAP_AGREEMENT_ATTRIBUTE_DIM]) REFERENCES [dbo].[RGAP_AGREEMENT_ATTRIBUTE_DIM] ([ID_RGAP_AGREEMENT_ATTRIBUTE_DIM]),
    CONSTRAINT [fk_RGAP_AGREEMENT_FACT_ID_WORKER_DIM_RESPONSIBLE] FOREIGN KEY ([ID_WORKER_DIM_RESPONSIBLE]) REFERENCES [dbo].[WORKER_DIM] ([ID_WORKER_DIM])
);

