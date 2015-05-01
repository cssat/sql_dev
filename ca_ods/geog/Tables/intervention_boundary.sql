CREATE TABLE [geog].[intervention_boundary] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [id]           NUMERIC (6)      NULL,
    CONSTRAINT [PK_intervention_boundary] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

