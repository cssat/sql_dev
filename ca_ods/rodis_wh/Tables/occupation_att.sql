CREATE TABLE [rodis_wh].[occupation_att] (
    [id_occupation] INT          NOT NULL,
    [cd_occupation] VARCHAR (50) NOT NULL,
    [tx_occupation] VARCHAR (50) NULL,
    CONSTRAINT [pk_occupation_att] PRIMARY KEY CLUSTERED ([id_occupation] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_occupation_att_cd_occupation]
    ON [rodis_wh].[occupation_att]([cd_occupation] ASC);

