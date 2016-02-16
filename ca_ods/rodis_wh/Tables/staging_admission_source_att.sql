CREATE TABLE [rodis_wh].[staging_admission_source_att] (
    [id_admission_source] INT          NULL,
    [cd_admission_source] VARCHAR (50) NULL,
    [tx_admission_source] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_admission_source_att_cd_admission_source]
    ON [rodis_wh].[staging_admission_source_att]([cd_admission_source] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_admission_source_att_id_admission_source]
    ON [rodis_wh].[staging_admission_source_att]([id_admission_source] ASC);

