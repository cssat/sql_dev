CREATE TABLE [rodis_wh].[wh_entity_keys]
(
    [entity_key] BIGINT NOT NULL , 
    [wh_column_id] INT NOT NULL 
        CONSTRAINT [fk_wh_entity_keys_wh_column_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_column]([wh_column_id]), 
    [source_key] VARCHAR(50) NOT NULL, 
    CONSTRAINT [pk_wh_entity_keys] PRIMARY KEY ([entity_key], [wh_column_id], [source_key])
)
GO

CREATE NONCLUSTERED INDEX [idx_wh_entity_keys] ON [rodis_wh].[wh_entity_keys](
    [entity_key], 
    [wh_column_id]
)
GO

CREATE NONCLUSTERED INDEX [idx_wh_entity_keys_source_key] ON [rodis_wh].[wh_entity_keys](
    [source_key], 
    [wh_column_id]
)
INCLUDE ([entity_key])
GO
