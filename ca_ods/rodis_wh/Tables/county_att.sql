CREATE TABLE [rodis_wh].[county_att] (
    [id_county] INT          NOT NULL,
    [cd_county] VARCHAR (50) NOT NULL,
    [tx_county] VARCHAR (50) NULL,
    [id_state]  INT          NOT NULL,
    CONSTRAINT [pk_county_att] PRIMARY KEY CLUSTERED ([id_county] ASC),
    CONSTRAINT [fk_county_att_id_state] FOREIGN KEY ([id_state]) REFERENCES [rodis_wh].[state_att] ([id_state])
);


GO
CREATE NONCLUSTERED INDEX [idx_county_att_id_state]
    ON [rodis_wh].[county_att]([id_state] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_county_att_cd_county]
    ON [rodis_wh].[county_att]([cd_county] ASC);

