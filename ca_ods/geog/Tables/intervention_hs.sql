CREATE TABLE [geog].[intervention_hs] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [hs_zone]      VARCHAR (254)    NULL,
    CONSTRAINT [PK_intervention_hs] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

