CREATE TABLE [rodis_wh].[diagnosis_att] (
    [id_diagnosis] INT          NOT NULL,
    [cd_diagnosis] VARCHAR (50) NOT NULL,
    [tx_diagnosis] VARCHAR (50) NULL,
    CONSTRAINT [pk_diagnosis_att] PRIMARY KEY CLUSTERED ([id_diagnosis] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_diagnosis_att_cd_diagnosis]
    ON [rodis_wh].[diagnosis_att]([cd_diagnosis] ASC);

