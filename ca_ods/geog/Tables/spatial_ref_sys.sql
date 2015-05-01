CREATE TABLE [geog].[spatial_ref_sys] (
    [srid]      INT            NOT NULL,
    [auth_name] VARCHAR (256)  NULL,
    [auth_srid] INT            NULL,
    [srtext]    VARCHAR (2048) NULL,
    [proj4text] VARCHAR (2048) NULL,
    CONSTRAINT [pk_spatial_ref_sys] PRIMARY KEY CLUSTERED ([srid] ASC)
);

