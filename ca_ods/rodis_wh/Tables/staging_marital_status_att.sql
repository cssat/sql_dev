CREATE TABLE [rodis_wh].[staging_marital_status_att] (
    [id_marital_status] INT          NULL,
    [cd_marital_status] VARCHAR (50) NULL,
    [tx_marital_status] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_marital_status_att_cd_marital_status]
    ON [rodis_wh].[staging_marital_status_att]([cd_marital_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_marital_status_att_id_marital_status]
    ON [rodis_wh].[staging_marital_status_att]([id_marital_status] ASC);

