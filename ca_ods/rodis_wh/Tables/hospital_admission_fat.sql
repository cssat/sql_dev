CREATE TABLE [rodis_wh].[hospital_admission_fat] (
    [id_hospital_admission_fact] INT          NOT NULL,
    [cd_hospital_admission_fact] VARCHAR (50) NOT NULL,
    [id_prsn_child]              INT          NULL,
    [id_calendar_dim_admit]      INT          NULL,
    [id_calendar_dim_discharge]  INT          NULL,
    [am_hospital_charges]        FLOAT (53)   NULL,
    [qt_length_of_stay_days]     INT          NULL,
    [qt_of_admissions]           INT          NULL,
    [id_hospital_admission]      INT          NOT NULL,
    CONSTRAINT [pk_hospital_admission_fat] PRIMARY KEY CLUSTERED ([id_hospital_admission_fact] ASC),
    CONSTRAINT [fk_hospital_admission_fat_id_hospital_admission] FOREIGN KEY ([id_hospital_admission]) REFERENCES [rodis_wh].[hospital_admission_att] ([id_hospital_admission])
);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_fat_id_hospital_admission]
    ON [rodis_wh].[hospital_admission_fat]([id_hospital_admission] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_hospital_admission_fat_cd_hospital_admission_fact]
    ON [rodis_wh].[hospital_admission_fat]([cd_hospital_admission_fact] ASC);

