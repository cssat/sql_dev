CREATE TABLE [rodis_wh].[death_fat] (
    [id_death_fact]          INT          NOT NULL,
    [cd_death_fact]          VARCHAR (50) NOT NULL,
    [id_prsn_child]          INT          NULL,
    [id_county_file_number]  VARCHAR (10) NULL,
    [id_calendar_dim_death]  INT          NULL,
    [id_calendar_dim_injury] INT          NULL,
    [id_death]               INT          NOT NULL,
    CONSTRAINT [pk_death_fat] PRIMARY KEY CLUSTERED ([id_death_fact] ASC),
    CONSTRAINT [fk_death_fat_id_death] FOREIGN KEY ([id_death]) REFERENCES [rodis_wh].[death_att] ([id_death])
);


GO
CREATE NONCLUSTERED INDEX [idx_death_fat_id_death]
    ON [rodis_wh].[death_fat]([id_death] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_death_fat_cd_death_fact]
    ON [rodis_wh].[death_fat]([cd_death_fact] ASC);

