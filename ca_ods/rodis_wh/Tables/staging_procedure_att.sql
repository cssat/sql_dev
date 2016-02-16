CREATE TABLE [rodis_wh].[staging_procedure_att] (
    [id_procedure] INT          NULL,
    [cd_procedure] VARCHAR (50) NULL,
    [tx_procedure] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_att_cd_procedure]
    ON [rodis_wh].[staging_procedure_att]([cd_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_att_id_procedure]
    ON [rodis_wh].[staging_procedure_att]([id_procedure] ASC);

