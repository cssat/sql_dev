CREATE TABLE [prtl].[param_sets_demog]
(
	[demog_param_key] INT NOT NULL PRIMARY KEY, 
    [cd_age_grouping] INT NOT NULL, 
	[cd_dev_age_grouping] INT NOT NULL, 
    [cd_race] INT NOT NULL, 
    [pk_gender] INT NOT NULL 
)
