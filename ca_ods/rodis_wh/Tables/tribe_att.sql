CREATE TABLE [rodis_wh].[tribe_att] (
    [id_tribe] INT          NOT NULL,
    [cd_tribe] VARCHAR (50) NOT NULL,
    [tx_tribe] VARCHAR (50) NULL,
    CONSTRAINT [pk_tribe_att] PRIMARY KEY CLUSTERED ([id_tribe] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_tribe_att_cd_tribe]
    ON [rodis_wh].[tribe_att]([cd_tribe] ASC);

