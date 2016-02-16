CREATE TABLE [rodis_wh].[dysfunctional_uterine_bleed_att] (
    [id_dysfunctional_uterine_bleed] INT          NOT NULL,
    [cd_dysfunctional_uterine_bleed] VARCHAR (50) NOT NULL,
    [tx_dysfunctional_uterine_bleed] VARCHAR (50) NULL,
    CONSTRAINT [pk_dysfunctional_uterine_bleed_att] PRIMARY KEY CLUSTERED ([id_dysfunctional_uterine_bleed] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_dysfunctional_uterine_bleed_att_cd_dysfunctional_uterine_bleed]
    ON [rodis_wh].[dysfunctional_uterine_bleed_att]([cd_dysfunctional_uterine_bleed] ASC);

