CREATE TABLE [geog].[intervention_es] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [es_zone]      VARCHAR (254)    NULL,
    CONSTRAINT [PK_intervention_es] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

