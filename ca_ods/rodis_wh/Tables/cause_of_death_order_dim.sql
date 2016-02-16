CREATE TABLE [rodis_wh].[cause_of_death_order_dim] (
    [id_cause_of_death_order] INT          NOT NULL,
    [cd_cause_of_death_order] VARCHAR (50) NOT NULL,
    [cause_of_death_order]    TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_cause_of_death_order_dim]
    ON [rodis_wh].[cause_of_death_order_dim]([id_cause_of_death_order] ASC);

