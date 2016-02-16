CREATE TABLE [rodis_wh].[cause_of_death_order_att] (
    [id_cause_of_death_order] INT          NOT NULL,
    [cd_cause_of_death_order] VARCHAR (50) NOT NULL,
    [cause_of_death_order]    TINYINT      NULL,
    CONSTRAINT [pk_cause_of_death_order_att] PRIMARY KEY CLUSTERED ([id_cause_of_death_order] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_cause_of_death_order_att_cd_cause_of_death_order]
    ON [rodis_wh].[cause_of_death_order_att]([cd_cause_of_death_order] ASC);

