CREATE TABLE [geog].[intervention_zip_msrs] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [zip]          VARCHAR (5)      NULL,
    [name]         VARCHAR (40)     NULL,
    [ziptype]      VARCHAR (20)     NULL,
    [state]        VARCHAR (2)      NULL,
    [statefips]    VARCHAR (2)      NULL,
    [countyfips]   VARCHAR (5)      NULL,
    [countyname]   VARCHAR (60)     NULL,
    [s3dzip]       VARCHAR (3)      NULL,
    [lat]          NUMERIC (19, 15) NULL,
    [lon]          NUMERIC (19, 15) NULL,
    [emptycol]     VARCHAR (5)      NULL,
    [totrescnt]    FLOAT (53)       NULL,
    [mfdu]         FLOAT (53)       NULL,
    [sfdu]         FLOAT (53)       NULL,
    [boxcnt]       FLOAT (53)       NULL,
    [bizcnt]       FLOAT (53)       NULL,
    [relver]       VARCHAR (8)      NULL,
    [color]        FLOAT (53)       NULL,
    CONSTRAINT [PK_intervention_zip_msrs] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

