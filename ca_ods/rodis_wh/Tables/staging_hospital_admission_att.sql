CREATE TABLE [rodis_wh].[staging_hospital_admission_att] (
    [id_hospital_admission]  INT          NULL,
    [cd_hospital_admission]  VARCHAR (50) NULL,
    [cd_child_admit_zip]     INT          NULL,
    [qt_length_of_stay_days] SMALLINT     NULL,
    [rank_of_admission]      TINYINT      NULL,
    [id_admission_source]    INT          NULL,
    [cd_admission_source]    VARCHAR (50) NULL,
    [id_admission_reason]    INT          NULL,
    [cd_admission_reason]    VARCHAR (50) NULL,
    [id_facility]            INT          NULL,
    [cd_facility]            VARCHAR (50) NULL,
    [id_discharge_status]    INT          NULL,
    [cd_discharge_status]    VARCHAR (50) NULL,
    [id_ecode]               INT          NULL,
    [cd_ecode]               VARCHAR (50) NULL,
    [id_payment_primary]     INT          NULL,
    [cd_payment_primary]     VARCHAR (50) NULL,
    [id_payment_secondary]   INT          NULL,
    [cd_payment_secondary]   VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_payment_secondary]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_payment_secondary] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_payment_primary]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_payment_primary] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_ecode]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_ecode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_discharge_status]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_discharge_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_facility]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_facility] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_admission_reason]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_admission_reason] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_admission_source]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_admission_source] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_cd_hospital_admission]
    ON [rodis_wh].[staging_hospital_admission_att]([cd_hospital_admission] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_hospital_admission_att_id_hospital_admission]
    ON [rodis_wh].[staging_hospital_admission_att]([id_hospital_admission] ASC);

