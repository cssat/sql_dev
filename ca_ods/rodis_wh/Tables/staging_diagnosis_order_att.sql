CREATE TABLE [rodis_wh].[staging_diagnosis_order_att] (
    [id_diagnosis_order] INT          NULL,
    [cd_diagnosis_order] VARCHAR (50) NULL,
    [diagnosis_order]    VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_order_att_cd_diagnosis_order]
    ON [rodis_wh].[staging_diagnosis_order_att]([cd_diagnosis_order] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_diagnosis_order_att_id_diagnosis_order]
    ON [rodis_wh].[staging_diagnosis_order_att]([id_diagnosis_order] ASC);

