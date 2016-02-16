CREATE TABLE [rodis_wh].[staging_birth_child_procedure_att] (
    [id_birth_child_procedure]          INT          NULL,
    [cd_birth_child_procedure]          VARCHAR (50) NULL,
    [fl_surfactant_replacement_therapy] TINYINT      NULL,
    [fl_ventilation_after_delivery]     TINYINT      NULL,
    [fl_ventilation_gt_6hrs]            TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_child_procedure_att_cd_birth_child_procedure]
    ON [rodis_wh].[staging_birth_child_procedure_att]([cd_birth_child_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_birth_child_procedure_att_id_birth_child_procedure]
    ON [rodis_wh].[staging_birth_child_procedure_att]([id_birth_child_procedure] ASC);

