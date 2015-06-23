CREATE TABLE [prtl].[param_sets_demog]
(
	[demog_param_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_sets_demog] PRIMARY KEY, 
    [age_grouping_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_age_grouping_cd] FOREIGN KEY REFERENCES [ref].[lookup_age_grouping]([age_grouping_cd]), 
    [age_census_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_age_census_cd] FOREIGN KEY REFERENCES [ref].[lookup_age_census]([age_census_cd]), 
	[age_dev_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_age_dev_cd] FOREIGN KEY REFERENCES [ref].[lookup_age_dev]([age_dev_cd]), 
    [age_sib_group_cd] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_age_sib_group_cd] FOREIGN KEY REFERENCES [ref].[lookup_age_sib_group]([age_sib_group_cd]), 
    [cd_race_census] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_cd_race_census] FOREIGN KEY REFERENCES [ref].[lookup_ethnicity_census]([cd_race_census]), 
    [pk_gender] INT NOT NULL 
        CONSTRAINT [fk_param_sets_demog_pk_gender] FOREIGN KEY REFERENCES [ref].[lookup_gender]([pk_gender]), 
    CONSTRAINT [idx_param_sets_demog] UNIQUE NONCLUSTERED (
        [age_grouping_cd], 
        [age_census_cd], 
        [age_dev_cd], 
        [age_sib_group_cd], 
        [cd_race_census], 
        [pk_gender] 
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE NONCLUSTERED INDEX [idx_param_sets_demog_age_grouping_cd] ON [prtl].[param_sets_demog] (
    [age_grouping_cd], 
    [cd_race_census], 
    [pk_gender] 
)
WHERE [age_census_cd] = 0 AND [age_dev_cd] = 0 AND [age_sib_group_cd] = 0
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [idx_param_sets_demog_age_census_cd] ON [prtl].[param_sets_demog] (
    [age_census_cd], 
    [cd_race_census], 
    [pk_gender] 
)
WHERE [age_grouping_cd] = 0 AND [age_dev_cd] = 0 AND [age_sib_group_cd] = 0
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [idx_param_sets_demog_age_dev_cd] ON [prtl].[param_sets_demog] (
    [age_dev_cd], 
    [cd_race_census], 
    [pk_gender] 
)
WHERE [age_grouping_cd] = 0 AND [age_census_cd] = 0 AND [age_sib_group_cd] = 0
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

CREATE NONCLUSTERED INDEX [idx_param_sets_demog_age_sib_group_cd] ON [prtl].[param_sets_demog] (
    [age_sib_group_cd], 
    [cd_race_census], 
    [pk_gender] 
)
WHERE [age_grouping_cd] = 0 AND [age_census_cd] = 0 AND [age_dev_cd] = 0
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
