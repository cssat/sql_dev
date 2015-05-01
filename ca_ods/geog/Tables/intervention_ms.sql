CREATE TABLE [geog].[intervention_ms] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [ms_zone]      VARCHAR (254)    NULL,
    CONSTRAINT [PK_intervention_ms] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

