CREATE TABLE [rodis_wh].[race_census_att] (
    [id_race_census] INT          NOT NULL,
    [cd_race_census] VARCHAR (50) NOT NULL,
    [tx_race_census] VARCHAR (50) NULL,
    CONSTRAINT [pk_race_census_att] PRIMARY KEY CLUSTERED ([id_race_census] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_race_census_att_cd_race_census]
    ON [rodis_wh].[race_census_att]([cd_race_census] ASC);

