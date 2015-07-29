CREATE TABLE [rodis_wh].[wh_reference]
(
    [wh_reference_id] INT NOT NULL 
        CONSTRAINT [pk_wh_reference] PRIMARY KEY, 
    [pr_wh_column_id] INT NOT NULL 
        CONSTRAINT [fk_wh_reference_pr_wh_column_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_column]([wh_column_id]), 
    [ref_wh_column_id] INT NOT NULL 
        CONSTRAINT [fk_wh_reference_ref_wh_column_id] FOREIGN KEY REFERENCES [rodis_wh].[wh_column]([wh_column_id]), 
    [ref_role] VARCHAR(50) NULL
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [idx_wh_reference] ON [rodis_wh].[wh_reference] (
    [pr_wh_column_id], 
    [ref_wh_column_id], 
    [ref_role]
)
