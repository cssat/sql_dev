CREATE TABLE [rodis_wh].[fetal_or_infant_death_att] (
    [id_fetal_or_infant_death] INT          NOT NULL,
    [cd_fetal_or_infant_death] VARCHAR (50) NOT NULL,
    [tx_fetal_or_infant_death] VARCHAR (50) NULL,
    CONSTRAINT [pk_fetal_or_infant_death_att] PRIMARY KEY CLUSTERED ([id_fetal_or_infant_death] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_fetal_or_infant_death_att_cd_fetal_or_infant_death]
    ON [rodis_wh].[fetal_or_infant_death_att]([cd_fetal_or_infant_death] ASC);

