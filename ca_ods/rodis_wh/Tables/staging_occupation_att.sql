CREATE TABLE [rodis_wh].[staging_occupation_att] (
    [id_occupation] INT          NULL,
    [cd_occupation] VARCHAR (50) NULL,
    [tx_occupation] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_occupation_att_cd_occupation]
    ON [rodis_wh].[staging_occupation_att]([cd_occupation] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_occupation_att_id_occupation]
    ON [rodis_wh].[staging_occupation_att]([id_occupation] ASC);

