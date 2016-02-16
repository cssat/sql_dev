CREATE TABLE [rodis_wh].[birth_child_procedure_dim] (
    [id_birth_child_procedure]          INT          NOT NULL,
    [cd_birth_child_procedure]          VARCHAR (50) NOT NULL,
    [fl_surfactant_replacement_therapy] TINYINT      NULL,
    [fl_ventilation_after_delivery]     TINYINT      NULL,
    [fl_ventilation_gt_6hrs]            TINYINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_birth_child_procedure_dim]
    ON [rodis_wh].[birth_child_procedure_dim]([id_birth_child_procedure] ASC);

