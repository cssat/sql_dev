CREATE TABLE [rodis_wh].[staging_certifier_type_att] (
    [id_certifier_type] INT          NULL,
    [cd_certifier_type] VARCHAR (50) NULL,
    [tx_certifier_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_certifier_type_att_cd_certifier_type]
    ON [rodis_wh].[staging_certifier_type_att]([cd_certifier_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_certifier_type_att_id_certifier_type]
    ON [rodis_wh].[staging_certifier_type_att]([id_certifier_type] ASC);

