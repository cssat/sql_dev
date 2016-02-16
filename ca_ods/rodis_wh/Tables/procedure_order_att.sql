CREATE TABLE [rodis_wh].[procedure_order_att] (
    [id_procedure_order] INT          NOT NULL,
    [cd_procedure_order] VARCHAR (50) NOT NULL,
    [procedure_order]    TINYINT      NULL,
    CONSTRAINT [pk_procedure_order_att] PRIMARY KEY CLUSTERED ([id_procedure_order] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_procedure_order_att_cd_procedure_order]
    ON [rodis_wh].[procedure_order_att]([cd_procedure_order] ASC);

