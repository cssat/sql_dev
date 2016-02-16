CREATE TABLE [rodis_wh].[staging_cause_of_death_m2m_fat] (
    [id_cause_of_death_m2m]   INT          NULL,
    [cd_cause_of_death_m2m]   VARCHAR (50) NULL,
    [id_cause_of_death]       INT          NULL,
    [cd_cause_of_death]       VARCHAR (50) NULL,
    [id_cause_of_death_order] INT          NULL,
    [cd_cause_of_death_order] VARCHAR (50) NULL,
    [id_death]                INT          NULL,
    [cd_death]                VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_m2m_fat_cd_death]
    ON [rodis_wh].[staging_cause_of_death_m2m_fat]([cd_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_m2m_fat_cd_cause_of_death_order]
    ON [rodis_wh].[staging_cause_of_death_m2m_fat]([cd_cause_of_death_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_m2m_fat_cd_cause_of_death]
    ON [rodis_wh].[staging_cause_of_death_m2m_fat]([cd_cause_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_m2m_fat_cd_cause_of_death_order_m2m]
    ON [rodis_wh].[staging_cause_of_death_m2m_fat]([cd_cause_of_death_m2m] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_m2m_fat_id_cause_of_death_order_m2m]
    ON [rodis_wh].[staging_cause_of_death_m2m_fat]([id_cause_of_death_m2m] ASC);

