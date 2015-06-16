CREATE TABLE [prtl].[param_sets_demog]
(
	[demog_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_demog] PRIMARY KEY, 
    [cd_age_grouping] INT NOT NULL, 
	[cd_dev_age_grouping] INT NOT NULL, 
    [cd_race_census] INT NOT NULL, 
    [pk_gender] INT NOT NULL, 
    CONSTRAINT [idx_param_sets_demog] UNIQUE NONCLUSTERED (
        [cd_age_grouping], 
        [cd_dev_age_grouping], 
        [cd_race_census], 
        [pk_gender] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
