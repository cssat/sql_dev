CREATE TABLE [ref].[age_dim]
(
	[age_month] INT NOT NULL PRIMARY KEY, 
    [age_year] INT NULL, 
    [census_child_group_cd] INT NULL, 
    [census_child_group_tx] VARCHAR(200) NULL, 
    [census_20_group_cd] INT NULL, 
    [census_20_group_tx] VARCHAR(200) NULL, 
    [custom_group_cd] INT NULL, 
    [custom_group_tx] VARCHAR(200) NULL, 
    [developmental_age_cd] INT NULL, 
    [developmental_age_tx] VARCHAR(200) NULL, 
    [school_age_cd] INT NULL, 
    [school_age_tx] VARCHAR(200) NULL, 
    [cdc_age_cd] INT NULL, 
    [cdc_age_tx] VARCHAR(200) NULL, 
    [cdc_census_mix_age_cd] INT NULL, 
    [cdc_census_mix_age_tx] VARCHAR(200) NULL
)
