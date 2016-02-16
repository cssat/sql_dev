CREATE TABLE [rodis_wh].[hospital_admission_fact] (
    [id_hospital_admission_fact]              INT          NOT NULL,
    [cd_hospital_admission_fact]              VARCHAR (50) NOT NULL,
    [id_prsn_child]                           INT          NULL,
    [id_calendar_dim_admit]                   INT          NULL,
    [id_calendar_dim_discharge]               INT          NULL,
    [am_hospital_charges]                     FLOAT (53)   NULL,
    [qt_length_of_stay_days]                  INT          NULL,
    [qt_of_admissions]                        INT          NULL,
    [id_hospital_admission]                   INT          NOT NULL,
    [hospital_admission_id_payment_primary]   INT          NOT NULL,
    [hospital_admission_id_payment_secondary] INT          NOT NULL,
    [bc_uni]                                  VARCHAR (50) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_fact_bc_uni]
    ON [rodis_wh].[hospital_admission_fact]([bc_uni] ASC);

