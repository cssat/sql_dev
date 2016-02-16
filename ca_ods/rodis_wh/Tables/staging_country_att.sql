CREATE TABLE [rodis_wh].[staging_country_att] (
    [id_country] INT          NULL,
    [cd_country] VARCHAR (50) NULL,
    [tx_country] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_country_att_cd_country]
    ON [rodis_wh].[staging_country_att]([cd_country] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_country_att_id_country]
    ON [rodis_wh].[staging_country_att]([id_country] ASC);

