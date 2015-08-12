CREATE TABLE [rodis_wh].[wh_table_type]
(
    [wh_table_type_id] INT NOT NULL 
        CONSTRAINT [pk_wh_table_type] PRIMARY KEY, 
    [wh_table_type] VARCHAR(50) NOT NULL, 
    [table_name_ending] VARCHAR(10) NOT NULL
)
