CREATE TABLE [rodis_wh].[state_att] (
    [id_state]   INT          NOT NULL,
    [cd_state]   VARCHAR (50) NOT NULL,
    [tx_state]   VARCHAR (50) NULL,
    [id_country] INT          NOT NULL,
    CONSTRAINT [pk_state_att] PRIMARY KEY CLUSTERED ([id_state] ASC),
    CONSTRAINT [fk_state_att_id_country] FOREIGN KEY ([id_country]) REFERENCES [rodis_wh].[country_att] ([id_country])
);


GO
CREATE NONCLUSTERED INDEX [idx_state_att_id_country]
    ON [rodis_wh].[state_att]([id_country] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_state_att_cd_state]
    ON [rodis_wh].[state_att]([cd_state] ASC);

