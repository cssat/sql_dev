CREATE TABLE [rodis_wh].[staging_hospital_admission_fat] (
    [id_hospital_admission_fact] INT          NULL,
    [cd_hospital_admission_fact] VARCHAR (50) NULL,
    [id_prsn_child]              INT          NULL,
    [id_calendar_dim_admit]      INT          NULL,
    [id_calendar_dim_discharge]  INT          NULL,
    [am_hospital_charges]        FLOAT (53)   NULL,
    [qt_length_of_stay_days]     INT          NULL,
    [qt_of_admissions]           INT          NULL,
    [id_hospital_admission]      INT          NULL,
    [cd_hospital_admission]      VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_fat_cd_hospital_admission]
    ON [rodis_wh].[staging_hospital_admission_fat]([cd_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_fat_cd_hospital_admission_fact]
    ON [rodis_wh].[staging_hospital_admission_fat]([cd_hospital_admission_fact] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_fat_id_hospital_admission_fact]
    ON [rodis_wh].[staging_hospital_admission_fat]([id_hospital_admission_fact] ASC);

