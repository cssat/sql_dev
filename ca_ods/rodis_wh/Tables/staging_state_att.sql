CREATE TABLE [rodis_wh].[staging_state_att] (
    [id_state]   INT          NULL,
    [cd_state]   VARCHAR (50) NULL,
    [tx_state]   VARCHAR (50) NULL,
    [id_country] INT          NULL,
    [cd_country] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_state_att_cd_country]
    ON [rodis_wh].[staging_state_att]([cd_country] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_state_att_cd_state]
    ON [rodis_wh].[staging_state_att]([cd_state] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_state_att_id_state]
    ON [rodis_wh].[staging_state_att]([id_state] ASC);

