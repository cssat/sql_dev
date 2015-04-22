CREATE TABLE [prtl].[placement_care_days_mobility] (
    [fiscal_yr]       INT      NOT NULL,
    [years_in_care]   INT      NOT NULL,
    [age_yrs_removal] INT      NOT NULL,
    [age_yrs_exit]    INT      NOT NULL,
    [cd_race]         INT      NOT NULL,
    [county_cd]       INT      NOT NULL,
    [exclude_7day]    SMALLINT NOT NULL,
    [exclude_trh]     SMALLINT NOT NULL,
    [exclude_nondcfs] SMALLINT NOT NULL,
    [care_days]       INT      NULL,
    [placement_moves] INT      NULL,
    [kin_cnt]         INT      NULL,
    [foster_cnt]      INT      NULL,
    [group_cnt]       INT      NULL,
    CONSTRAINT [PK_placement_care_days_mobility] PRIMARY KEY CLUSTERED ([fiscal_yr] ASC, [years_in_care] ASC, [age_yrs_removal] ASC, [age_yrs_exit] ASC, [cd_race] ASC, [county_cd] ASC, [exclude_7day] ASC, [exclude_trh] ASC, [exclude_nondcfs] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_placement_care_days_age_race_county_exclusions_inc_3]
    ON [prtl].[placement_care_days_mobility]([age_yrs_removal] ASC, [age_yrs_exit] ASC, [cd_race] ASC, [county_cd] ASC, [exclude_7day] ASC, [exclude_trh] ASC)
    INCLUDE([fiscal_yr], [care_days], [placement_moves]);

