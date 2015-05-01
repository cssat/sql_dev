CREATE TABLE [geog].[wa_counties] (
    [ID]       INT              IDENTITY (1, 1) NOT NULL,
    [STATEFP]  NVARCHAR (255)   NULL,
    [COUNTYFP] NVARCHAR (255)   NULL,
    [COUNTYNS] NVARCHAR (255)   NULL,
    [CNTYIDFP] NVARCHAR (255)   NULL,
    [NAME]     NVARCHAR (255)   NULL,
    [NAMELSAD] NVARCHAR (255)   NULL,
    [LSAD]     NVARCHAR (255)   NULL,
    [CLASSFP]  NVARCHAR (255)   NULL,
    [MTFCC]    NVARCHAR (255)   NULL,
    [CSAFP]    NVARCHAR (255)   NULL,
    [CBSAFP]   NVARCHAR (255)   NULL,
    [METDIVFP] NVARCHAR (255)   NULL,
    [FUNCSTAT] NVARCHAR (255)   NULL,
    [ALAND]    BIGINT           NULL,
    [AWATER]   BIGINT           NULL,
    [INTPTLAT] NVARCHAR (255)   NULL,
    [INTPTLON] NVARCHAR (255)   NULL,
    [geom]     [sys].[geometry] NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [enforce_srid_geometry_tl_2009_53_county] CHECK ([geom].[STSrid]=(4269))
);

