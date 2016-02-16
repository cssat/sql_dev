CREATE TABLE [rodis_wh].[kotelchuck_index_att] (
    [id_kotelchuck_index] INT          NOT NULL,
    [cd_kotelchuck_index] VARCHAR (50) NOT NULL,
    [tx_kotelchuck_index] VARCHAR (50) NULL,
    CONSTRAINT [pk_kotelchuck_index_att] PRIMARY KEY CLUSTERED ([id_kotelchuck_index] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_kotelchuck_index_att_cd_kotelchuck_index]
    ON [rodis_wh].[kotelchuck_index_att]([cd_kotelchuck_index] ASC);

