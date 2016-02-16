CREATE TABLE [rodis_wh].[staging_cause_of_death_order_att] (
    [id_cause_of_death_order] INT          NULL,
    [cd_cause_of_death_order] VARCHAR (50) NULL,
    [cause_of_death_order]    TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_order_att_cd_cause_of_death_order]
    ON [rodis_wh].[staging_cause_of_death_order_att]([cd_cause_of_death_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_cause_of_death_order_att_id_cause_of_death_order]
    ON [rodis_wh].[staging_cause_of_death_order_att]([id_cause_of_death_order] ASC);

