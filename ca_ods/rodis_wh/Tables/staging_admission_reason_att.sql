CREATE TABLE [rodis_wh].[staging_admission_reason_att] (
    [id_admission_reason] INT          NULL,
    [cd_admission_reason] VARCHAR (50) NULL,
    [tx_admission_reason] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_admission_reason_att_cd_admission_reason]
    ON [rodis_wh].[staging_admission_reason_att]([cd_admission_reason] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_admission_reason_att_id_admission_reason]
    ON [rodis_wh].[staging_admission_reason_att]([id_admission_reason] ASC);

