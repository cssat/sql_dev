CREATE TABLE [rodis_wh].[staging_race_census_att] (
    [id_race_census] INT          NULL,
    [cd_race_census] VARCHAR (50) NULL,
    [tx_race_census] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_race_census_att_cd_race_census]
    ON [rodis_wh].[staging_race_census_att]([cd_race_census] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_race_census_att_id_race_census]
    ON [rodis_wh].[staging_race_census_att]([id_race_census] ASC);

