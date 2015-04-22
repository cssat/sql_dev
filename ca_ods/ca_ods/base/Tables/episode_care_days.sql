CREATE TABLE [base].[episode_care_days] (
    [fiscal_yr]       INT      NOT NULL,
    [years_in_care]   INT      NOT NULL,
    [age_yrs_removal] INT      NOT NULL,
    [age_yrs_exit]    INT      NOT NULL,
    [cd_race]         INT      NOT NULL,
    [county_cd]       INT      NOT NULL,
    [exclude_7day]    SMALLINT NOT NULL,
    [exclude_nondcfs] SMALLINT NOT NULL,
    [care_days]       INT      NULL,
    CONSTRAINT [PK_episode_care_days_mobility] PRIMARY KEY CLUSTERED ([fiscal_yr] ASC, [years_in_care] ASC, [age_yrs_removal] ASC, [age_yrs_exit] ASC, [cd_race] ASC, [county_cd] ASC, [exclude_7day] ASC, [exclude_nondcfs] ASC)
);

