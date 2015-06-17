CREATE TABLE [prtl].[param_sets_geog]
(
	[geog_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_geog] PRIMARY KEY, 
    [cd_county] INT NOT NULL 
        CONSTRAINT [fk_param_sets_geog_cd_county] FOREIGN KEY REFERENCES [ref].[lookup_county]([cd_county]), 
    [cd_region_three] INT NOT NULL 
        CONSTRAINT [fk_param_sets_geog_cd_region_three] FOREIGN KEY REFERENCES [ref].[lookup_region_three]([cd_region_three]), 
    [cd_region_six] INT NOT NULL 
        CONSTRAINT [fk_param_sets_geog_cd_region_six] FOREIGN KEY REFERENCES [ref].[lookup_region_six]([cd_region_six]), 
    CONSTRAINT [idx_param_sets_geog] UNIQUE NONCLUSTERED (
        [cd_county], 
        [cd_region_three], 
        [cd_region_six] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
