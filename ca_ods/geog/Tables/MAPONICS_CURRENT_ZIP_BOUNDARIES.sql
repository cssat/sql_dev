CREATE TABLE [geog].[MAPONICS_CURRENT_ZIP_BOUNDARIES] (
    [OBJECTID]   INT              IDENTITY (1, 1) NOT NULL,
    [Shape]      [sys].[geometry] NULL,
    [ZIP]        NVARCHAR (5)     NULL,
    [NAME]       NVARCHAR (40)    NULL,
    [ZIPTYPE]    NVARCHAR (20)    NULL,
    [STATE]      NVARCHAR (2)     NULL,
    [STATEFIPS]  NVARCHAR (2)     NULL,
    [COUNTYFIPS] NVARCHAR (5)     NULL,
    [COUNTYNAME] NVARCHAR (60)    NULL,
    [S3DZIP]     NVARCHAR (3)     NULL,
    [LAT]        NUMERIC (23, 15) NULL,
    [LON]        NUMERIC (23, 15) NULL,
    [EMPTYCOL]   NVARCHAR (5)     NULL,
    [TOTRESCNT]  INT              NULL,
    [MFDU]       INT              NULL,
    [SFDU]       INT              NULL,
    [BOXCNT]     INT              NULL,
    [BIZCNT]     INT              NULL,
    [RELVER]     NVARCHAR (8)     NULL,
    [COLOR]      INT              NULL,
    PRIMARY KEY CLUSTERED ([OBJECTID] ASC)
);



GO
CREATE SPATIAL INDEX [FDO_Shape]
    ON [geog].[MAPONICS_CURRENT_ZIP_BOUNDARIES] ([Shape])
    USING GEOMETRY_GRID
    WITH  (
            BOUNDING_BOX = (XMAX = 400, XMIN = -400, YMAX = 90, YMIN = -90),
            GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM)
          );

