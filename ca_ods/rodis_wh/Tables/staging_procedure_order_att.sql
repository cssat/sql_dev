CREATE TABLE [rodis_wh].[staging_procedure_order_att] (
    [id_procedure_order] INT          NULL,
    [cd_procedure_order] VARCHAR (50) NULL,
    [procedure_order]    VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_order_att_cd_procedure_order]
    ON [rodis_wh].[staging_procedure_order_att]([cd_procedure_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_procedure_order_att_id_procedure_order]
    ON [rodis_wh].[staging_procedure_order_att]([id_procedure_order] ASC);

