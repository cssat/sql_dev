CREATE TABLE [rodis_wh].[diagnosis_dim] (
    [id_diagnosis] INT          NOT NULL,
    [cd_diagnosis] VARCHAR (50) NOT NULL,
    [tx_diagnosis] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_diagnosis_dim]
    ON [rodis_wh].[diagnosis_dim]([id_diagnosis] ASC);

