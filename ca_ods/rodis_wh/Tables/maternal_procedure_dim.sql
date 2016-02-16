CREATE TABLE [rodis_wh].[maternal_procedure_dim] (
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
    [cd_csection]                INT          NOT NULL,
    [tx_csection]                VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_maternal_procdedure_dim]
    ON [rodis_wh].[maternal_procedure_dim]([id_maternal_procedure] ASC);

