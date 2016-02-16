CREATE TABLE [rodis_wh].[cause_of_death_att] (
    [id_cause_of_death] INT          NOT NULL,
    [cd_cause_of_death] VARCHAR (50) NOT NULL,
    [tx_cause_of_death] VARCHAR (50) NULL,
    CONSTRAINT [pk_cause_of_death_att] PRIMARY KEY CLUSTERED ([id_cause_of_death] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_cause_of_death_att_cd_cause_of_death]
    ON [rodis_wh].[cause_of_death_att]([cd_cause_of_death] ASC);

