CREATE TABLE [rodis_wh].[diagnosis_order_att] (
    [id_diagnosis_order] INT          NOT NULL,
    [cd_diagnosis_order] VARCHAR (50) NOT NULL,
    [diagnosis_order]    TINYINT      NULL,
    CONSTRAINT [pk_diagnosis_order_att] PRIMARY KEY CLUSTERED ([id_diagnosis_order] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_diagnosis_order_att_cd_diagnosis_order]
    ON [rodis_wh].[diagnosis_order_att]([cd_diagnosis_order] ASC);

