CREATE TABLE [rodis_wh].[staging_place_of_death_att] (
    [id_place_of_death]      INT          NULL,
    [cd_place_of_death]      VARCHAR (50) NULL,
    [tx_place_of_death]      VARCHAR (50) NULL,
    [id_place_of_death_type] INT          NULL,
    [cd_place_of_death_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_place_of_death_att_cd_place_of_death_type]
    ON [rodis_wh].[staging_place_of_death_att]([cd_place_of_death_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_place_of_death_att_cd_place_of_death]
    ON [rodis_wh].[staging_place_of_death_att]([cd_place_of_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_place_of_death_att_id_place_of_death]
    ON [rodis_wh].[staging_place_of_death_att]([id_place_of_death] ASC);

