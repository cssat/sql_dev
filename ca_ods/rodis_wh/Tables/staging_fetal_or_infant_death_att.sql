CREATE TABLE [rodis_wh].[staging_fetal_or_infant_death_att] (
    [id_fetal_or_infant_death] INT          NULL,
    [cd_fetal_or_infant_death] VARCHAR (50) NULL,
    [tx_fetal_or_infant_death] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_fetal_or_infant_death_att_cd_fetal_or_infant_death]
    ON [rodis_wh].[staging_fetal_or_infant_death_att]([cd_fetal_or_infant_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_fetal_or_infant_death_att_id_fetal_or_infant_death]
    ON [rodis_wh].[staging_fetal_or_infant_death_att]([id_fetal_or_infant_death] ASC);

