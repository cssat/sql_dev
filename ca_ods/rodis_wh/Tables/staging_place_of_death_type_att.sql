CREATE TABLE [rodis_wh].[staging_place_of_death_type_att] (
    [id_place_of_death_type] INT          NULL,
    [cd_place_of_death_type] VARCHAR (50) NULL,
    [tx_place_of_death_type] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_place_of_death_type_att_cd_place_of_death_type]
    ON [rodis_wh].[staging_place_of_death_type_att]([cd_place_of_death_type] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_place_of_death_type_att_id_place_of_death_type]
    ON [rodis_wh].[staging_place_of_death_type_att]([id_place_of_death_type] ASC);

