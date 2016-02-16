CREATE TABLE [rodis_wh].[diagnosis_order_dim] (
    [id_diagnosis_order] INT          NOT NULL,
    [cd_diagnosis_order] VARCHAR (50) NOT NULL,
    [diagnosis_order]    TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_diagnosis_order_dim]
    ON [rodis_wh].[diagnosis_order_dim]([id_diagnosis_order] ASC);

