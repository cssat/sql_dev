﻿CREATE TABLE [geog].[SABS_1314_WASHINGTON_ASSIGNED] (
    [OBJECTID]   INT              IDENTITY (1, 1) NOT NULL,
    [Shape]      [sys].[geometry] NULL,
    [SrcName]    NVARCHAR (100)   NULL,
    [ncessch]    NVARCHAR (254)   NULL,
    [schnam]     NVARCHAR (254)   NULL,
    [leaid]      NVARCHAR (7)     NULL,
    [updateDate] DATETIME2 (7)    NULL,
    [gslo]       NVARCHAR (2)     NULL,
    [gshi]       NVARCHAR (2)     NULL,
    [defacto]    NVARCHAR (3)     NULL,
    [stAbbrev]   NVARCHAR (2)     NULL,
    [sLevel]     NVARCHAR (1)     NULL,
    [openEnroll] NVARCHAR (1)     NULL,
    [MultiBdy]   NVARCHAR (1)     NULL,
    [Shape_Leng] NUMERIC (38, 8)  NULL,
    PRIMARY KEY CLUSTERED ([OBJECTID] ASC)
);



GO
CREATE SPATIAL INDEX [FDO_Shape]
    ON [geog].[SABS_1314_WASHINGTON_ASSIGNED] ([Shape])
    USING GEOMETRY_GRID
    WITH  (
            BOUNDING_BOX = (XMAX = 16901100, XMIN = -16901100, YMAX = 15298100, YMIN = -6972200),
            GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM)
          );
