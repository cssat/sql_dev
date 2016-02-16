CREATE TABLE [rodis_wh].[wh_column] (
    [wh_column_id]      INT           NOT NULL,
    [wh_column_name]    VARCHAR (100) NOT NULL,
    [wh_column_type_id] INT           NOT NULL,
    [wh_table_id]       INT           NOT NULL,
    [wh_data_type_id]   INT           NOT NULL,
    [data_length]       INT           NOT NULL,
    [max_length]        BIT           NOT NULL,
    [ordinal]           INT           NOT NULL,
    CONSTRAINT [pk_wh_column] PRIMARY KEY CLUSTERED ([wh_column_id] ASC),
    CONSTRAINT [fk_wh_column_wh_column_type_id] FOREIGN KEY ([wh_column_type_id]) REFERENCES [rodis_wh].[wh_column_type] ([wh_column_type_id]),
    CONSTRAINT [fk_wh_column_wh_data_type_id] FOREIGN KEY ([wh_data_type_id]) REFERENCES [rodis_wh].[wh_data_type] ([wh_data_type_id]),
    CONSTRAINT [fk_wh_column_wh_table_id] FOREIGN KEY ([wh_table_id]) REFERENCES [rodis_wh].[wh_table] ([wh_table_id])
);


GO

CREATE NONCLUSTERED INDEX [idx_wh_column_wh_table_id] ON [rodis_wh].[wh_column](
    [wh_table_id], 
    [wh_column_type_id]
)
GO
