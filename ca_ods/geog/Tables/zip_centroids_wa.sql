CREATE TABLE [geog].[zip_centroids_wa] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [ZIP]        NVARCHAR (255)   NULL,
    [NAME]       NVARCHAR (255)   NULL,
    [ZIPTYPE]    NVARCHAR (255)   NULL,
    [STATE]      NVARCHAR (255)   NULL,
    [STATEFIPS]  NVARCHAR (255)   NULL,
    [COUNTYFIPS] NVARCHAR (255)   NULL,
    [COUNTYNAME] NVARCHAR (255)   NULL,
    [S3DZIP]     NVARCHAR (255)   NULL,
    [LAT]        FLOAT (53)       NULL,
    [LON]        FLOAT (53)       NULL,
    [ENCZIP]     NVARCHAR (255)   NULL,
    [TOTRESCNT]  BIGINT           NULL,
    [MFDU]       BIGINT           NULL,
    [SFDU]       BIGINT           NULL,
    [BOXCNT]     BIGINT           NULL,
    [BIZCNT]     BIGINT           NULL,
    [RELVER]     NVARCHAR (255)   NULL,
    [geom]       [sys].[geometry] NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [enforce_srid_geometry_ZIP_Centroids_WA] CHECK ([geom].[STSrid]=(4326))
);

