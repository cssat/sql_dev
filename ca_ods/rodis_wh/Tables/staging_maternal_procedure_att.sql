CREATE TABLE [rodis_wh].[staging_maternal_procedure_att] (
    [id_maternal_procedure]      INT          NULL,
    [cd_maternal_procedure]      VARCHAR (50) NULL,
    [fl_hysterectomy]            TINYINT      NULL,
    [fl_induced]                 TINYINT      NULL,
    [fl_any_obstetric_procedure] TINYINT      NULL,
    [fl_forcep_use]              TINYINT      NULL,
    [fl_steroids_given]          TINYINT      NULL,
    [fl_labor_stimulation]       TINYINT      NULL,
    [fl_tocolysis_meds]          TINYINT      NULL,
    [fl_transfusion]             TINYINT      NULL,
    [fl_vacuum_failed]           VARCHAR (1)  NULL,
    [fl_vacuum_used]             TINYINT      NULL,
    [id_csection]                INT          NULL,
    [cd_csection]                VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_procedure_att_cd_csection]
    ON [rodis_wh].[staging_maternal_procedure_att]([cd_csection] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_procedure_att_cd_maternal_procedure]
    ON [rodis_wh].[staging_maternal_procedure_att]([cd_maternal_procedure] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_staging_maternal_procedure_att_id_maternal_procedure]
    ON [rodis_wh].[staging_maternal_procedure_att]([id_maternal_procedure] ASC);

