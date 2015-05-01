CREATE TABLE [geog].[intervention_blocks_msrs] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [statefp]      VARCHAR (2)      NULL,
    [countyfp]     VARCHAR (3)      NULL,
    [statefp10]    VARCHAR (2)      NULL,
    [countyfp10]   VARCHAR (3)      NULL,
    [tractce10]    VARCHAR (6)      NULL,
    [blockce10]    VARCHAR (4)      NULL,
    [suffix1ce]    VARCHAR (1)      NULL,
    [geoid]        VARCHAR (16)     NULL,
    [name]         VARCHAR (11)     NULL,
    [mtfcc]        VARCHAR (5)      NULL,
    [ur10]         VARCHAR (1)      NULL,
    [uace10]       VARCHAR (5)      NULL,
    [funcstat]     VARCHAR (1)      NULL,
    [aland]        FLOAT (53)       NULL,
    [awater]       FLOAT (53)       NULL,
    [intptlat]     VARCHAR (11)     NULL,
    [intptlon]     VARCHAR (12)     NULL,
    CONSTRAINT [PK_intervention_blocks_msrs] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

