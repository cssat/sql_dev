CREATE TABLE [geog].[school_districts] (
    [ogr_fid]      INT              IDENTITY (1, 1) NOT NULL,
    [ogr_geometry] [sys].[geometry] NULL,
    [statefp]      VARCHAR (2)      NULL,
    [unsdlea]      VARCHAR (5)      NULL,
    [geoid]        VARCHAR (7)      NULL,
    [name]         VARCHAR (100)    NULL,
    [lsad]         VARCHAR (2)      NULL,
    [lograde]      VARCHAR (2)      NULL,
    [higrade]      VARCHAR (2)      NULL,
    [mtfcc]        VARCHAR (5)      NULL,
    [sdtyp]        VARCHAR (1)      NULL,
    [funcstat]     VARCHAR (1)      NULL,
    [aland]        FLOAT (53)       NULL,
    [awater]       FLOAT (53)       NULL,
    [intptlat]     VARCHAR (11)     NULL,
    [intptlon]     VARCHAR (12)     NULL,
    CONSTRAINT [PK_school_districts] PRIMARY KEY CLUSTERED ([ogr_fid] ASC)
);

