CREATE TABLE [dbo].[param_sets_geog]
(
	[geog_param_key] INT NOT NULL PRIMARY KEY, 
    [cd_county] INT NOT NULL, 
    [cd_region_3] INT NOT NULL, 
    [cd_region_6] INT NOT NULL
)
