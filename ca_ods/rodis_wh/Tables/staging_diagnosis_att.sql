CREATE TABLE [rodis_wh].[staging_diagnosis_att] (
    [id_diagnosis] INT          NULL,
    [cd_diagnosis] VARCHAR (50) NULL,
    [tx_diagnosis] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_att_cd_diagnosis]
    ON [rodis_wh].[staging_diagnosis_att]([cd_diagnosis] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_att_id_diagnosis]
    ON [rodis_wh].[staging_diagnosis_att]([id_diagnosis] ASC);

