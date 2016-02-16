CREATE TABLE [rodis_wh].[place_of_death_att] (
    [id_place_of_death]      INT          NOT NULL,
    [cd_place_of_death]      VARCHAR (50) NOT NULL,
    [tx_place_of_death]      VARCHAR (50) NULL,
    [id_place_of_death_type] INT          NOT NULL,
    CONSTRAINT [pk_place_of_death_att] PRIMARY KEY CLUSTERED ([id_place_of_death] ASC),
    CONSTRAINT [fk_place_of_death_att_id_place_of_death_type] FOREIGN KEY ([id_place_of_death_type]) REFERENCES [rodis_wh].[place_of_death_type_att] ([id_place_of_death_type])
);


GO
CREATE NONCLUSTERED INDEX [idx_place_of_death_att_id_place_of_death_type]
    ON [rodis_wh].[place_of_death_att]([id_place_of_death_type] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_place_of_death_att_cd_place_of_death]
    ON [rodis_wh].[place_of_death_att]([cd_place_of_death] ASC);

