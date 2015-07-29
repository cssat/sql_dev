CREATE TABLE [rodis_wh].[wh_table]
(
    [wh_table_id] INT NOT NULL 
        CONSTRAINT [pk_wh_table] PRIMARY KEY, 
    [wh_table_name] VARCHAR(100) NOT NULL, 
    [wh_table_type_id] INT NULL 
        CONSTRAINT [fk_wh_table_wh_table_type_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_table_type]([wh_table_type_id])
)
