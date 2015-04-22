CREATE TABLE [dbo].[ref_lookup_county] (
    [county_cd]       INT           NOT NULL,
    [county_desc]     VARCHAR (200) NULL,
    [cd_region]       INT           NULL,
    [old_region_cd]   INT           NULL,
    [old_region_desc] VARCHAR (200) NULL,
    [countyfips]      INT           NULL,
    CONSTRAINT [PK_ref_lookup_county] PRIMARY KEY CLUSTERED ([county_cd] ASC)
);

