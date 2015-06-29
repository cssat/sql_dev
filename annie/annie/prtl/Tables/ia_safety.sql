CREATE TABLE [prtl].[ia_safety]
(
    [cohort_begin_date] DATETIME NOT NULL, 
    [date_type] INT NOT NULL, 
    [qry_type] INT NOT NULL, 
    [bin_ihs_svc_cd] INT NOT NULL, 
    [cd_reporter_type] INT NOT NULL, 
    [filter_access_type] INT NOT NULL, 
    [filter_allegation] INT NOT NULL, 
    [filter_finding] INT NOT NULL, 
    [cd_sib_age_grp] INT NOT NULL, 
    [cd_race_census] INT NOT NULL, 
    [census_hispanic_latino_origin_cd] INT NOT NULL, 
    [county_cd] INT NOT NULL, 
    [init_ref] INT NOT NULL, 
    [init_fnd_ref] INT NOT NULL, 
    [cohort_ref_count] INT NOT NULL, 
    [cohort_fnd_ref_count] INT NOT NULL, 
    [case_founded_recurrence] INT NOT NULL, 
    [case_repeat_referral] INT NOT NULL, 
    [cnt_case] INT NOT NULL, 
    [nxt_ref_within_min_month] INT NOT NULL 
)
GO

CREATE NONCLUSTERED INDEX [idx_ia_safety] 
    ON [prtl].[ia_safety] ([cohort_ref_count], [nxt_ref_within_min_month], [cohort_begin_date])
GO

CREATE NONCLUSTERED INDEX [idx_ia_safety_param_sets_ia] 
    ON [prtl].[ia_safety] ([cd_reporter_type], [filter_access_type], [filter_allegation], [filter_finding])
GO

CREATE NONCLUSTERED INDEX [idx_ia_safety_param_sets_demog] 
    ON [prtl].[ia_safety] ([cd_sib_age_grp], [cd_race_census])
GO

CREATE NONCLUSTERED INDEX [idx_ia_safety_param_sets_geog] 
    ON [prtl].[ia_safety] ([county_cd])
GO
