CREATE TABLE [ospi].[ospi_person] (
    [ResearchID]     NVARCHAR (14) NULL,
    [FileSource]     NVARCHAR (2)  NULL,
    [racecat]        NVARCHAR (32) NULL,
    [LEP]            NVARCHAR (2)  NULL,
    [brth_dte]       DATETIME      NULL,
    [sex]            NVARCHAR (2)  NULL,
    [frst_dte]       DATETIME      NULL,
    [FirstAge]       SMALLINT      NULL,
    [int_ResearchID] INT           DEFAULT ((0)) NOT NULL
);

