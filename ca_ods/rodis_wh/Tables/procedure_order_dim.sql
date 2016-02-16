CREATE TABLE [rodis_wh].[procedure_order_dim] (
    [id_procedure_order] INT          NOT NULL,
    [cd_procedure_order] VARCHAR (50) NOT NULL,
    [procedure_order]    TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_order]
    ON [rodis_wh].[procedure_order_dim]([id_procedure_order] ASC);

