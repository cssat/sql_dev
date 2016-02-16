CREATE TABLE [rodis_wh].[staging_kotelchuck_index_att] (
    [id_kotelchuck_index] INT          NULL,
    [cd_kotelchuck_index] VARCHAR (50) NULL,
    [tx_kotelchuck_index] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_kotelchuck_index_att_cd_kotelchuck_index]
    ON [rodis_wh].[staging_kotelchuck_index_att]([cd_kotelchuck_index] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_kotelchuck_index_att_id_kotelchuck_index]
    ON [rodis_wh].[staging_kotelchuck_index_att]([id_kotelchuck_index] ASC);

