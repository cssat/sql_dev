CREATE TABLE [rodis_wh].[location_dim] (
    [id_city]    INT           NOT NULL,
    [cd_city]    VARCHAR (50)  NOT NULL,
    [tx_city]    VARCHAR (100) NULL,
    [id_county]  INT           NOT NULL,
    [cd_county]  VARCHAR (50)  NOT NULL,
    [tx_county]  VARCHAR (50)  NULL,
    [id_state]   INT           NOT NULL,
    [cd_state]   VARCHAR (50)  NOT NULL,
    [tx_state]   VARCHAR (50)  NULL,
    [id_country] INT           NOT NULL,
    [cd_country] VARCHAR (50)  NOT NULL,
    [tx_country] VARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_location_dim]
    ON [rodis_wh].[location_dim]([id_city] ASC);

