CREATE TABLE [rodis_wh].[staging_city_att] (
    [id_city]   INT           NULL,
    [cd_city]   VARCHAR (50)  NULL,
    [tx_city]   VARCHAR (100) NULL,
    [id_county] INT           NULL,
    [cd_county] VARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_city_att_cd_county]
    ON [rodis_wh].[staging_city_att]([cd_county] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_city_att_cd_city]
    ON [rodis_wh].[staging_city_att]([cd_city] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_city_att_id_city]
    ON [rodis_wh].[staging_city_att]([id_city] ASC);

