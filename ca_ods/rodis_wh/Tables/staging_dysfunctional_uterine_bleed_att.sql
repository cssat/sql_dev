CREATE TABLE [rodis_wh].[staging_dysfunctional_uterine_bleed_att] (
    [id_dysfunctional_uterine_bleed] INT          NULL,
    [cd_dysfunctional_uterine_bleed] VARCHAR (50) NULL,
    [tx_dysfunctional_uterine_bleed] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_dysfunctional_uterine_bleed_att_cd_dysfunctional_uterine_bleed]
    ON [rodis_wh].[staging_dysfunctional_uterine_bleed_att]([cd_dysfunctional_uterine_bleed] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_dysfunctional_uterine_bleed_att_id_dysfunctional_uterine_bleed]
    ON [rodis_wh].[staging_dysfunctional_uterine_bleed_att]([id_dysfunctional_uterine_bleed] ASC);

