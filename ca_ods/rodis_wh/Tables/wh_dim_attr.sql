CREATE TABLE [rodis_wh].[wh_dim_attr]
(
    [wh_dim_attr_id] INT NOT NULL 
        CONSTRAINT [pk_wh_dim_attr] PRIMARY KEY, 
    [wh_dimension_id] INT NOT NULL 
        CONSTRAINT [fk_wh_dim_attr_wh_dimension_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_dimension]([wh_dimension_id]), 
    [wh_attribute_table_id] INT NOT NULL 
        CONSTRAINT [fk_wh_dim_attr_wh_attribute_table_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_table]([wh_table_id])
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_wh_dim_attr] ON [rodis_wh].[wh_dim_attr] (
    [wh_dimension_id], 
    [wh_attribute_table_id]
)
GO
