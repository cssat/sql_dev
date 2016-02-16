CREATE TABLE [rodis_wh].[staging_maternal_transfer_type_att] (
    [id_maternal_transfer_type] INT          NULL,
    [cd_maternal_transfer_type] VARCHAR (50) NULL,
    [tx_maternal_transfer_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_transfer_type_att_cd_maternal_transfer_type]
    ON [rodis_wh].[staging_maternal_transfer_type_att]([cd_maternal_transfer_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_transfer_type_att_id_maternal_transfer_type]
    ON [rodis_wh].[staging_maternal_transfer_type_att]([id_maternal_transfer_type] ASC);

