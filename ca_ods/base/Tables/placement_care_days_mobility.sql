CREATE TABLE [base].[placement_care_days_mobility] (
    [fiscal_yr]       INT NOT NULL,
    [age_yrs_removal] INT NOT NULL,
    [age_yrs_exit]    INT NOT NULL,
    [county_cd]       INT NOT NULL,
    [cd_race]         INT NOT NULL,
    [years_in_care]   INT NOT NULL,
    [exclude_7day]    INT NOT NULL,
    [exclude_trh]     INT NOT NULL,
    [exclude_nondcfs] INT NOT NULL,
    [care_days]       INT NULL,
    [placement_moves] INT NULL,
    [kin_cnt]         INT NULL,
    [foster_cnt]      INT NULL,
    [group_cnt]       INT NULL,
    CONSTRAINT [PK_placement_care_days_mobility] PRIMARY KEY CLUSTERED ([fiscal_yr] ASC, [age_yrs_removal] ASC, [age_yrs_exit] ASC, [county_cd] ASC, [cd_race] ASC, [years_in_care] ASC, [exclude_7day] ASC, [exclude_trh] ASC, [exclude_nondcfs] ASC)
);

