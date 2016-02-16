CREATE TABLE [rodis_wh].[staging_death_fat] (
    [id_death_fact]          INT          NULL,
    [cd_death_fact]          VARCHAR (50) NULL,
    [id_prsn_child]          INT          NULL,
    [id_county_file_number]  VARCHAR (10) NULL,
    [id_calendar_dim_death]  INT          NULL,
    [id_calendar_dim_injury] INT          NULL,
    [id_death]               INT          NULL,
    [cd_death]               VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_fat_cd_death]
    ON [rodis_wh].[staging_death_fat]([cd_death] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_fat_cd_death_fact]
    ON [rodis_wh].[staging_death_fat]([cd_death_fact] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_death_fat_id_death_fact]
    ON [rodis_wh].[staging_death_fat]([id_death_fact] ASC);

