CREATE TABLE [rodis_wh].[staging_ucode_att] (
    [id_ucode] INT          NULL,
    [cd_ucode] VARCHAR (50) NULL,
    [tx_ucode] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ucode_att_cd_ucode]
    ON [rodis_wh].[staging_ucode_att]([cd_ucode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_ucode_att_id_ucode]
    ON [rodis_wh].[staging_ucode_att]([id_ucode] ASC);

