CREATE TABLE [rodis_wh].[child_sex_att] (
    [id_child_sex] INT          NOT NULL,
    [cd_child_sex] VARCHAR (50) NOT NULL,
    [tx_child_sex] VARCHAR (50) NULL,
    CONSTRAINT [pk_child_sex_att] PRIMARY KEY CLUSTERED ([id_child_sex] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_child_sex_att_cd_child_sex]
    ON [rodis_wh].[child_sex_att]([cd_child_sex] ASC);

