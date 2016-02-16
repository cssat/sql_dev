CREATE TABLE [rodis_wh].[place_of_death_type_att] (
    [id_place_of_death_type] INT          NOT NULL,
    [cd_place_of_death_type] VARCHAR (50) NOT NULL,
    [tx_place_of_death_type] VARCHAR (50) NULL,
    CONSTRAINT [pk_place_of_death_type_att] PRIMARY KEY CLUSTERED ([id_place_of_death_type] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_place_of_death_type_att_cd_place_of_death_type]
    ON [rodis_wh].[place_of_death_type_att]([cd_place_of_death_type] ASC);

