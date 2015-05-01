CREATE TABLE [ospi].[ospi_events] (
    [Placement_type] NVARCHAR (4)  NULL,
    [ResearchID]     NVARCHAR (14) NULL,
    [PlaceID]        NVARCHAR (24) NULL,
    [miss]           NVARCHAR (2)  NULL,
    [mtch]           NVARCHAR (6)  NULL,
    [temp_flag]      NVARCHAR (2)  NULL,
    [disp]           SMALLINT      NULL,
    [fosterkeep]     SMALLINT      NULL,
    [strt_dte]       DATETIME      NOT NULL,
    [end_dte]        DATETIME      NOT NULL,
    [int_researchID] INT           NOT NULL
);

