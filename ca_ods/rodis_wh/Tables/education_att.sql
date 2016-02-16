CREATE TABLE [rodis_wh].[education_att] (
    [id_education] INT          NOT NULL,
    [cd_education] VARCHAR (50) NOT NULL,
    [tx_education] VARCHAR (50) NULL,
    CONSTRAINT [pk_education_att] PRIMARY KEY CLUSTERED ([id_education] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_education_att_cd_education]
    ON [rodis_wh].[education_att]([cd_education] ASC);

