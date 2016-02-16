CREATE TABLE [rodis_wh].[education_dim] (
    [id_education] INT          NOT NULL,
    [cd_education] VARCHAR (50) NOT NULL,
    [tx_education] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_education_dim]
    ON [rodis_wh].[education_dim]([id_education] ASC);

