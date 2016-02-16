CREATE TABLE [rodis_wh].[staging_cause_of_death_att] (
    [id_cause_of_death] INT          NULL,
    [cd_cause_of_death] VARCHAR (50) NULL,
    [tx_cause_of_death] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_att_cd_cause_of_death]
    ON [rodis_wh].[staging_cause_of_death_att]([cd_cause_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_att_id_cause_of_death]
    ON [rodis_wh].[staging_cause_of_death_att]([id_cause_of_death] ASC);

