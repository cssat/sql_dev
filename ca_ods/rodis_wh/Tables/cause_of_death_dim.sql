CREATE TABLE [rodis_wh].[cause_of_death_dim] (
    [id_cause_of_death] INT          NOT NULL,
    [cd_cause_of_death] VARCHAR (50) NOT NULL,
    [tx_cause_of_death] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_cause_of_death_dim]
    ON [rodis_wh].[cause_of_death_dim]([id_cause_of_death] ASC);

