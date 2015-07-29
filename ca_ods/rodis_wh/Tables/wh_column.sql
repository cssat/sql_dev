CREATE TABLE [rodis_wh].[wh_column]
(
    [wh_column_id] INT NOT NULL 
        CONSTRAINT [pk_wh_column] PRIMARY KEY, 
    [wh_column_name] VARCHAR(100) NOT NULL, 
    [wh_column_type_id] INT NULL 
        CONSTRAINT [fk_wh_column_wh_column_type_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_column_type]([wh_column_type_id]), 
    [wh_table_id] INT NULL 
        CONSTRAINT [fk_wh_column_wh_table_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_table]([wh_table_id])
)
GO

CREATE NONCLUSTERED INDEX [idx_wh_column_wh_table_id] ON [rodis_wh].[wh_column](
    [wh_table_id], 
    [wh_column_type_id]
)
GO
