CREATE TABLE [rodis_wh].[admission_source_att] (
    [id_admission_source] INT          NOT NULL,
    [cd_admission_source] VARCHAR (50) NOT NULL,
    [tx_admission_source] VARCHAR (50) NULL,
    CONSTRAINT [pk_admission_source_att] PRIMARY KEY CLUSTERED ([id_admission_source] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_admission_source_att_cd_admission_source]
    ON [rodis_wh].[admission_source_att]([cd_admission_source] ASC);

