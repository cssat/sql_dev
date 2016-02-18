CREATE TABLE [prtl].[ooh_outcomes_cache] (
    [qry_type]                     TINYINT        NOT NULL,
    [date_type]                    TINYINT        NOT NULL,
    [cohort_entry_date]            DATE           NOT NULL,
    [age_grouping_cd]              TINYINT        NOT NULL,
    [pk_gender]                    TINYINT        NOT NULL,
    [cd_race_census]               TINYINT        NOT NULL,
    [initial_cd_placement_setting] TINYINT        NOT NULL,
    [longest_cd_placement_setting] TINYINT        NOT NULL,
    [cd_county]                    TINYINT        NOT NULL,
    [bin_dependency_cd]            TINYINT        NOT NULL,
    [bin_los_cd]                   TINYINT        NOT NULL,
    [bin_placement_cd]             TINYINT        NOT NULL,
    [bin_ihs_service_cd]           TINYINT        NOT NULL,
    [cd_reporter_type]             TINYINT        NOT NULL,
    [cd_access_type]               TINYINT        NOT NULL,
    [cd_allegation]                TINYINT        NOT NULL,
    [cd_finding]                   TINYINT        NOT NULL,
    [cd_discharge_type]            TINYINT        NOT NULL,
    [month]                        TINYINT        NOT NULL,
    [discharge_count]              INT            NOT NULL,
    [cohort_count]                 INT            NOT NULL,
    [rate]                         DECIMAL (9, 2) NULL
);


GO

CREATE NONCLUSTERED INDEX [idx_ooh_outcomes_cache]
    ON [prtl].[ooh_outcomes_cache]([age_grouping_cd] ASC, [pk_gender] ASC, [cd_race_census] ASC, [initial_cd_placement_setting] ASC, [longest_cd_placement_setting] ASC, [cd_county] ASC, [bin_dependency_cd] ASC, [bin_los_cd] ASC, [bin_placement_cd] ASC, [bin_ihs_service_cd] ASC, [cd_reporter_type] ASC, [cd_access_type] ASC, [cd_allegation] ASC, [cd_finding] ASC, [date_type] ASC, [cohort_entry_date] ASC)
    INCLUDE([qry_type], [cd_discharge_type], [month], [rate]);


GO
