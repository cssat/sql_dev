CREATE TABLE [prtl].[param_match_geog]
(
    [geog_match_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_match_geog] PRIMARY KEY, 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_param_match_geog_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
    [cd_county] INT NOT NULL, 
    [cd_region_three] INT NOT NULL, 
    [cd_region_six] INT NOT NULL
)
GO

CREATE NONCLUSTERED INDEX [idx_param_match_geog] 
    ON [prtl].[param_match_geog] ([geog_param_key])
    INCLUDE ([cd_county], [cd_region_three], [cd_region_six])
GO
