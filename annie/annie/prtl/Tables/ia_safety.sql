CREATE TABLE [prtl].[ia_safety]
(
    [cohort_begin_date] DATE NOT NULL, 
    [date_type] INT NOT NULL, 
    [qry_type] INT NOT NULL, 
    [ia_param_key] INT NOT NULL
        CONSTRAINT [fk_ia_safety_ia_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_ia]([ia_param_key]), 
    [demog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ia_safety_demog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_demog]([demog_param_key]), 
    [geog_param_key] INT NOT NULL 
        CONSTRAINT [fk_ia_safety_geog_param_key] FOREIGN KEY REFERENCES [prtl].[param_sets_geog]([geog_param_key]), 
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
    ON [prtl].[ia_safety] ([ia_param_key], [demog_param_key], [geog_param_key])
    INCLUDE ([init_ref], [init_fnd_ref], [case_founded_recurrence], [nxt_ref_within_min_month])
GO
