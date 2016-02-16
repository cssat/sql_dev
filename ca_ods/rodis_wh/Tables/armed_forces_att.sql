CREATE TABLE [rodis_wh].[armed_forces_att] (
    [id_armed_forces] INT          NOT NULL,
    [cd_armed_forces] VARCHAR (50) NOT NULL,
    [tx_armed_forces] VARCHAR (50) NULL,
    CONSTRAINT [pk_armed_forces_att] PRIMARY KEY CLUSTERED ([id_armed_forces] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_armed_forces_att_cd_armed_forces]
    ON [rodis_wh].[armed_forces_att]([cd_armed_forces] ASC);

