CREATE TABLE [rodis_wh].[staging_county_att] (
    [id_county] INT          NULL,
    [cd_county] VARCHAR (50) NULL,
    [tx_county] VARCHAR (50) NULL,
    [id_state]  INT          NULL,
    [cd_state]  VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_county_att_cd_state]
    ON [rodis_wh].[staging_county_att]([cd_state] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_county_att_cd_county]
    ON [rodis_wh].[staging_county_att]([cd_county] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_county_att_id_county]
    ON [rodis_wh].[staging_county_att]([id_county] ASC);

