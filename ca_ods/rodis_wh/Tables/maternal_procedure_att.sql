CREATE TABLE [rodis_wh].[maternal_procedure_att] (
    [id_maternal_procedure]      INT          NOT NULL,
    [cd_maternal_procedure]      VARCHAR (50) NOT NULL,
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
    [id_csection]                INT          NOT NULL,
    CONSTRAINT [pk_maternal_procedure_att] PRIMARY KEY CLUSTERED ([id_maternal_procedure] ASC),
    CONSTRAINT [fk_maternal_procedure_att_id_csection] FOREIGN KEY ([id_csection]) REFERENCES [rodis_wh].[csection_att] ([id_csection])
);


GO
CREATE NONCLUSTERED INDEX [idx_maternal_procedure_att_id_csection]
    ON [rodis_wh].[maternal_procedure_att]([id_csection] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_maternal_procedure_att_cd_maternal_procedure]
    ON [rodis_wh].[maternal_procedure_att]([cd_maternal_procedure] ASC);

