CREATE TABLE [rodis_wh].[wh_entity_key] (
    [entity_key]   INT          NOT NULL,
    [wh_column_id] INT          NOT NULL,
    [source_key]   VARCHAR (50) NOT NULL,
    CONSTRAINT [pk_wh_entity_keys] PRIMARY KEY CLUSTERED ([entity_key] ASC, [wh_column_id] ASC, [source_key] ASC),
    CONSTRAINT [fk_wh_entity_keys_wh_column_id] FOREIGN KEY ([wh_column_id]) REFERENCES [rodis_wh].[wh_column] ([wh_column_id])
);


GO


GO


GO
