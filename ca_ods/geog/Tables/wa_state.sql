CREATE TABLE [geog].[wa_state] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [JURID]      BIGINT           NULL,
    [JURTY]      BIGINT           NULL,
    [JURLBL]     NVARCHAR (255)   NULL,
    [JURNM]      NVARCHAR (255)   NULL,
    [JURDSG]     BIGINT           NULL,
    [JURFIPSDSG] BIGINT           NULL,
    [JURVACFLG]  NVARCHAR (255)   NULL,
    [EDITDT]     DATE             NULL,
    [EDITSTAT]   SMALLINT         NULL,
    [EDITNM]     NVARCHAR (255)   NULL,
    [AREA]       FLOAT (53)       NULL,
    [LEN]        FLOAT (53)       NULL,
    [geom]       [sys].[geometry] NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [enforce_srid_geometry_state] CHECK ([geom].[STSrid]=(2927))
);

