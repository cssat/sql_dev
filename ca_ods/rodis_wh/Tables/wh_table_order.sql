CREATE TABLE [rodis_wh].[wh_table_order]
(
    [wh_table_order_id] INT NOT NULL 
        CONSTRAINT [pk_wh_table_order] PRIMARY KEY, 
    [wh_package_id] INT NOT NULL 
        CONSTRAINT [fk_wh_table_order_wh_package_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_package]([wh_package_id]), 
    [wh_table_id] INT NOT NULL 
        CONSTRAINT [fk_wh_table_order_wh_table_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_table]([wh_table_id]), 
    [step_number] TINYINT NOT NULL
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_wh_table_order] ON [rodis_wh].[wh_table_order]( 
    [wh_package_id], 
    [wh_table_id]
)
GO
