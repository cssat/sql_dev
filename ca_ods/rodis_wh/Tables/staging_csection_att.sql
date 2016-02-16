CREATE TABLE [rodis_wh].[staging_csection_att] (
    [id_csection] INT          NULL,
    [cd_csection] VARCHAR (50) NULL,
    [tx_csection] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_csection_att_cd_csection]
    ON [rodis_wh].[staging_csection_att]([cd_csection] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_csection_att_id_csection]
    ON [rodis_wh].[staging_csection_att]([id_csection] ASC);

