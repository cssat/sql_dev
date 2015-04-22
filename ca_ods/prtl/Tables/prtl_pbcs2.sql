CREATE TABLE [prtl].[prtl_pbcs2] (
    [cohort_begin_date]                DATETIME NOT NULL,
    [date_type]                        INT      NOT NULL,
    [qry_type]                         INT      NOT NULL,
    [int_match_param_key]              BIGINT   NOT NULL,
    [cd_sib_age_grp]                   INT      NOT NULL,
    [cd_race_census]                   INT      NOT NULL,
    [census_hispanic_latino_origin_cd] INT      NOT NULL,
    [county_cd]                        INT      NOT NULL,
    [filter_access_type]               INT      NOT NULL,
    [filter_allegation]                INT      NOT NULL,
    [filter_finding]                   INT      NOT NULL,
    [cd_reporter_type]                 INT      NOT NULL,
    [bin_ihs_svc_cd]                   INT      NOT NULL,
    [initref]                          INT      NOT NULL,
    [initfndref]                       INT      NOT NULL,
    [cohortrefcount]                   INT      NOT NULL,
    [cohortfndrefcount]                INT      NOT NULL,
    [case_founded_recurrence]          INT      NOT NULL,
    [case_repeat_referral]             INT      NOT NULL,
    [cnt_case]                         INT      NOT NULL,
    [nxt_ref_within_min_month]         INT      NOT NULL,
    CONSTRAINT [PK_prtl_pbcs2_1] PRIMARY KEY CLUSTERED ([cohort_begin_date] ASC, [date_type] ASC, [qry_type] ASC, [int_match_param_key] ASC, [filter_access_type] ASC, [filter_allegation] ASC, [filter_finding] ASC, [cd_reporter_type] ASC, [bin_ihs_svc_cd] ASC, [initref] ASC, [initfndref] ASC, [case_founded_recurrence] ASC, [nxt_ref_within_min_month] ASC),
    CONSTRAINT [prtl_pbcs2_cd_race_FK] FOREIGN KEY ([cd_race_census]) REFERENCES [dbo].[ref_lookup_ethnicity_census] ([cd_race_census]),
    CONSTRAINT [prtl_pbcs2_cd_reporter_type_FK] FOREIGN KEY ([cd_reporter_type]) REFERENCES [dbo].[ref_filter_reporter_type] ([cd_reporter_type]),
    CONSTRAINT [prtl_pbcs2_cd_sib_age_grpr_FK] FOREIGN KEY ([cd_sib_age_grp]) REFERENCES [dbo].[ref_lookup_sib_age_grp] ([cd_sib_age_grp]),
    CONSTRAINT [prtl_pbcs2_county_cd_FK] FOREIGN KEY ([county_cd]) REFERENCES [dbo].[ref_lookup_county] ([county_cd]),
    CONSTRAINT [prtl_pbcs2_origin_cd_FK] FOREIGN KEY ([census_hispanic_latino_origin_cd]) REFERENCES [dbo].[ref_lookup_hispanic_latino_census] ([census_hispanic_latino_origin_cd])
);


GO
CREATE NONCLUSTERED INDEX [idx_s2]
    ON [prtl].[prtl_pbcs2]([cd_sib_age_grp] ASC, [filter_finding] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_reporter_type_cohortrefcount]
    ON [prtl].[prtl_pbcs2]([cd_reporter_type] ASC, [cohortrefcount] ASC)
    INCLUDE([cohort_begin_date], [qry_type], [int_match_param_key], [filter_access_type], [filter_allegation], [filter_finding], [cnt_case]);


GO
CREATE NONCLUSTERED INDEX [idx_nxt_ref_within_min_month]
    ON [prtl].[prtl_pbcs2]([nxt_ref_within_min_month] ASC, [cohort_begin_date] ASC, [int_match_param_key] ASC, [cohortrefcount] ASC);

