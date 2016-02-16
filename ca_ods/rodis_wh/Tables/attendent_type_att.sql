CREATE TABLE [rodis_wh].[attendent_type_att] (
    [id_attendent_type] INT          NOT NULL,
    [cd_attendent_type] VARCHAR (50) NOT NULL,
    [tx_attendent_type] VARCHAR (50) NULL,
    CONSTRAINT [pk_attendent_type_att] PRIMARY KEY CLUSTERED ([id_attendent_type] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_attendent_type_att_cd_attendent_type]
    ON [rodis_wh].[attendent_type_att]([cd_attendent_type] ASC);

