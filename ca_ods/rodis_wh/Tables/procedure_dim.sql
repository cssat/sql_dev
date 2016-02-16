CREATE TABLE [rodis_wh].[procedure_dim] (
    [id_procedure] INT          NOT NULL,
    [cd_procedure] VARCHAR (50) NOT NULL,
    [tx_procedure] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_procedure_dim]
    ON [rodis_wh].[procedure_dim]([id_procedure] ASC);

