CREATE TABLE [geog].[wa_zcta_500] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [STATEFP00]  NVARCHAR (255)   NULL,
    [ZCTA5CE00]  NVARCHAR (255)   NULL,
    [GEOID00]    NVARCHAR (255)   NULL,
    [CLASSFP00]  NVARCHAR (255)   NULL,
    [MTFCC00]    NVARCHAR (255)   NULL,
    [FUNCSTAT00] NVARCHAR (255)   NULL,
    [ALAND00]    BIGINT           NULL,
    [AWATER00]   BIGINT           NULL,
    [INTPTLAT00] NVARCHAR (255)   NULL,
    [INTPTLON00] NVARCHAR (255)   NULL,
    [PARTFLG00]  NVARCHAR (255)   NULL,
    [geom]       [sys].[geometry] NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [enforce_srid_geometry_tl_2010_53_zcta500] CHECK ([geom].[STSrid]=(4269))
);

