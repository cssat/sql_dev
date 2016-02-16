CREATE TABLE [rodis_wh].[staging_tribe_att] (
    [id_tribe] INT          NULL,
    [cd_tribe] VARCHAR (50) NULL,
    [tx_tribe] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_tribe_att_cd_tribe]
    ON [rodis_wh].[staging_tribe_att]([cd_tribe] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_tribe_att_id_tribe]
    ON [rodis_wh].[staging_tribe_att]([id_tribe] ASC);

