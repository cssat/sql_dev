CREATE TABLE [rodis_wh].[city_att] (
    [id_city]   INT           NOT NULL,
    [cd_city]   VARCHAR (50)  NOT NULL,
    [tx_city]   VARCHAR (100) NULL,
    [id_county] INT           NOT NULL,
    CONSTRAINT [pk_city_att] PRIMARY KEY CLUSTERED ([id_city] ASC),
    CONSTRAINT [fk_city_att_id_county] FOREIGN KEY ([id_county]) REFERENCES [rodis_wh].[county_att] ([id_county])
);


GO
CREATE NONCLUSTERED INDEX [idx_city_att_id_county]
    ON [rodis_wh].[city_att]([id_county] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_city_att_cd_city]
    ON [rodis_wh].[city_att]([cd_city] ASC);

