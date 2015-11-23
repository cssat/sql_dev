CREATE TABLE [prtl].[param_match_demog]
(
    [demog_match_key] INT NOT NULL IDENTITY(1,1) 
        CONSTRAINT [pk_param_match_demog] PRIMARY KEY, 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_param_match_demog_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [age_grouping_cd] INT NOT NULL, 
    [age_census_cd] INT NOT NULL, 
    [age_dev_cd] INT NOT NULL, 
    [age_sib_group_cd] INT NOT NULL, 
    [cd_race_census] INT NOT NULL, 
    [pk_gender] INT NOT NULL
)
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog] ON [prtl].[param_match_demog] (
    [demog_param_key]
    )
    INCLUDE ([age_grouping_cd], [age_census_cd], [age_dev_cd], [age_sib_group_cd], [cd_race_census], [pk_gender])
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog_age_grouping_cd] ON [prtl].[param_match_demog] (
    [demog_param_key], 
    [age_grouping_cd], 
    [cd_race_census], 
    [pk_gender]
    )
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog_age_census_cd] ON [prtl].[param_match_demog] (
    [demog_param_key], 
    [age_census_cd], 
    [cd_race_census], 
    [pk_gender]
    )
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog_age_dev_cd] ON [prtl].[param_match_demog] (
    [demog_param_key], 
    [age_dev_cd], 
    [cd_race_census], 
    [pk_gender]
    )
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog_age_sib_group_cd] ON [prtl].[param_match_demog] (
    [demog_param_key], 
    [age_sib_group_cd], 
    [cd_race_census], 
    [pk_gender]
    )
GO

CREATE NONCLUSTERED INDEX [idx_param_match_demog_ia_safety] ON [prtl].[param_match_demog] (
    [demog_param_key], 
    [age_sib_group_cd], 
    [cd_race_census] 
    )
GO
