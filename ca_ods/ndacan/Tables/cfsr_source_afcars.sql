﻿CREATE TABLE [ndacan].[cfsr_source_afcars] (
    [datayear]                 INT           NULL,
    [state]                    VARCHAR (25)  NULL,
    [st]                       VARCHAR (2)   NULL,
    [repdatyr]                 INT           NULL,
    [repdatmo]                 TINYINT       NULL,
    [recnumbr]                 VARCHAR (255) NULL,
    [dob]                      DATE          NULL,
    [pedrevdt]                 DATE          NULL,
    [sex]                      TINYINT       NULL,
    [raceeth]                  TINYINT       NULL,
    [totalrem]                 TINYINT       NULL,
    [rem1dt]                   DATE          NULL,
    [dlstfcdt]                 DATE          NULL,
    [latremdt]                 DATE          NULL,
    [remtrndt]                 DATE          NULL,
    [cursetdt]                 DATE          NULL,
    [tprdaddt]                 DATE          NULL,
    [tprmomdt]                 DATE          NULL,
    [dodfcdt]                  DATE          NULL,
    [numplep]                  TINYINT       NULL,
    [curplset]                 INT           NULL,
    [childid]                  INT           NULL,
    [dtreportbeg]              DATE          NULL,
    [dtreportend]              DATE          NULL,
    [dtreportendfinal]         DATE          NULL,
    [next6moreport]            DATE          NULL,
    [timebetweenreports]       SMALLINT      NULL,
    [dq_dropped]               TINYINT       NULL,
    [dq_idnomatchnext6mo]      TINYINT       NULL,
    [dq_missdob]               TINYINT       NULL,
    [dq_missdtlatremdt]        TINYINT       NULL,
    [dq_missnumplep]           TINYINT       NULL,
    [dq_dobgtlatremdt]         TINYINT       NULL,
    [dq_dobgtdodfcdt]          TINYINT       NULL,
    [dq_gt21dobtodtlatrem]     TINYINT       NULL,
    [dq_gt21dobtodtdisch]      TINYINT       NULL,
    [dq_gt21dtdischtodtlatrem] TINYINT       NULL,
    [dq_dodfcdteqletremdt]     TINYINT       NULL,
    [dq_dodfcdtltletremdt]     TINYINT       NULL,
    [dq_missdisreasn]          TINYINT       NULL,
    [dq_totalrem1]             TINYINT       NULL,
    [entryyr]                  INT           NULL,
    [exityr]                   INT           NULL,
    [agenmos]                  INT           NULL,
    [agenmosyrscat]            INT           NULL,
    [agenyears]                INT           NULL,
    [agenmosyrs]               INT           NULL,
    [agexmos]                  INT           NULL,
    [agexmosyrscat]            INT           NULL,
    [agexyrs]                  INT           NULL,
    [agexmosyrs]               INT           NULL,
    [disreasn1]                INT           NULL,
    [disreasn2]                INT           NULL,
    [tremcat]                  TINYINT       NULL
);



GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_pk_cfsr_source_afcars]
    ON [ndacan].[cfsr_source_afcars]([childid] ASC, [dtreportbeg] ASC, [latremdt] ASC, [dodfcdt] ASC);

