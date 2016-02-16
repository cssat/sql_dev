CREATE TABLE [rodis_wh].[staging_armed_forces_att] (
    [id_armed_forces] INT          NULL,
    [cd_armed_forces] VARCHAR (50) NULL,
    [tx_armed_forces] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_armed_forces_att_cd_armed_forces]
    ON [rodis_wh].[staging_armed_forces_att]([cd_armed_forces] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_armed_forces_att_id_armed_forces]
    ON [rodis_wh].[staging_armed_forces_att]([id_armed_forces] ASC);

