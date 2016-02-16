CREATE TABLE [rodis_wh].[maternal_history_dim] (
    [id_maternal_history]                 INT          NOT NULL,
    [cd_maternal_history]                 VARCHAR (50) NOT NULL,
    [qt_prior_fetal_geq_20wks]            TINYINT      NULL,
    [qt_prior_fetal_lt_20wks]             TINYINT      NULL,
    [qt_months_at_residence]              SMALLINT     NULL,
    [qt_years_at_residence]               TINYINT      NULL,
    [qt_induced_termination_of_pregnancy] TINYINT      NULL,
    [qt_born_child_now_dead]              TINYINT      NULL,
    [qt_born_child_now_living]            TINYINT      NULL,
    [dt_last_pregnancy_year]              SMALLINT     NULL,
    [dt_last_birth_year]                  SMALLINT     NULL,
    [qt_parity]                           TINYINT      NULL,
    [fl_previous_csection]                TINYINT      NULL,
    [fl_previous_preterm_infant]          TINYINT      NULL,
    [qt_prior_csections]                  TINYINT      NULL,
    [fl_prior_poor_pregnancy_outcome]     TINYINT      NULL,
    [dt_last_pregnancy_month]             TINYINT      NULL,
    [dt_last_birth_month]                 TINYINT      NULL,
    [id_fetal_or_infant_death]            INT          NOT NULL,
    [cd_fetal_or_infant_death]            VARCHAR (50) NOT NULL,
    [tx_fetal_or_infant_death]            VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_maternal_history_dim]
    ON [rodis_wh].[maternal_history_dim]([id_maternal_history] ASC);

