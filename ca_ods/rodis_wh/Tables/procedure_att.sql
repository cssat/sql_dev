CREATE TABLE [rodis_wh].[procedure_att] (
    [id_procedure] INT          NOT NULL,
    [cd_procedure] VARCHAR (50) NOT NULL,
    [tx_procedure] VARCHAR (50) NULL,
    CONSTRAINT [pk_procedure_att] PRIMARY KEY CLUSTERED ([id_procedure] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_procedure_att_cd_procedure]
    ON [rodis_wh].[procedure_att]([cd_procedure] ASC);

