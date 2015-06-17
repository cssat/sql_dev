CREATE TABLE [prtl].[param_sets_demog]
(
	[demog_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_demog] PRIMARY KEY, 
    [age_grouping_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_age_grouping_cd] FOREIGN KEY REFERENCES [ref].[lookup_age_grouping]([age_grouping_cd]), 
	[dev_age_grouping_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_dev_age_grouping_cd] FOREIGN KEY REFERENCES [ref].[lookup_dev_age_grouping]([dev_age_grouping_cd]), 
    [cd_race_census] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_cd_race_census] FOREIGN KEY REFERENCES [ref].[lookup_ethnicity_census]([cd_race_census]), 
    [pk_gender] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_pk_gender] FOREIGN KEY REFERENCES [ref].[lookup_gender]([pk_gender]), 
    CONSTRAINT [idx_param_sets_demog] UNIQUE NONCLUSTERED (
        [age_grouping_cd], 
        [dev_age_grouping_cd], 
        [cd_race_census], 
        [pk_gender] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
