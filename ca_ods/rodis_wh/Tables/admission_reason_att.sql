CREATE TABLE [rodis_wh].[admission_reason_att] (
    [id_admission_reason] INT          NOT NULL,
    [cd_admission_reason] VARCHAR (50) NOT NULL,
    [tx_admission_reason] VARCHAR (50) NULL,
    CONSTRAINT [pk_admission_reason_att] PRIMARY KEY CLUSTERED ([id_admission_reason] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_admission_reason_att_cd_admission_reason]
    ON [rodis_wh].[admission_reason_att]([cd_admission_reason] ASC);

