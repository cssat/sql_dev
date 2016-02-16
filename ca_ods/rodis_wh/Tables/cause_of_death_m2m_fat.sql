CREATE TABLE [rodis_wh].[cause_of_death_m2m_fat] (
    [id_cause_of_death_m2m]   INT          NOT NULL,
    [cd_cause_of_death_m2m]   VARCHAR (50) NOT NULL,
    [id_cause_of_death]       INT          NOT NULL,
    [id_cause_of_death_order] INT          NOT NULL,
    [id_death]                INT          NOT NULL,
    CONSTRAINT [pk_cause_of_death_m2m_fat] PRIMARY KEY CLUSTERED ([id_cause_of_death_m2m] ASC),
    CONSTRAINT [fk_cause_of_death_m2m_fat_id_cause_of_death] FOREIGN KEY ([id_cause_of_death]) REFERENCES [rodis_wh].[cause_of_death_att] ([id_cause_of_death]),
    CONSTRAINT [fk_cause_of_death_m2m_fat_id_cause_of_death_order] FOREIGN KEY ([id_cause_of_death_order]) REFERENCES [rodis_wh].[cause_of_death_order_att] ([id_cause_of_death_order]),
    CONSTRAINT [fk_cause_of_death_m2m_fat_id_death] FOREIGN KEY ([id_death]) REFERENCES [rodis_wh].[death_att] ([id_death])
);


GO
CREATE NONCLUSTERED INDEX [idx_cause_of_death_m2m_fat_id_death]
    ON [rodis_wh].[cause_of_death_m2m_fat]([id_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_cause_of_death_m2m_fat_id_cause_of_death_order]
    ON [rodis_wh].[cause_of_death_m2m_fat]([id_cause_of_death_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_cause_of_death_m2m_fat_id_cause_of_death]
    ON [rodis_wh].[cause_of_death_m2m_fat]([id_cause_of_death] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_cause_of_death_m2m_fat_cd_cause_of_death_m2m]
    ON [rodis_wh].[cause_of_death_m2m_fat]([cd_cause_of_death_m2m] ASC);

