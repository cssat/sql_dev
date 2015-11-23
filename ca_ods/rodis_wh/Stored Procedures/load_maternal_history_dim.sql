CREATE PROCEDURE [rodis_wh].[load_maternal_history_dim]
AS
TRUNCATE TABLE rodis_wh.maternal_history_dim

INSERT rodis_wh.maternal_history_dim (
	id_maternal_history
	,cd_maternal_history
	,qt_prior_fetal_geq_20wks
	,qt_prior_fetal_lt_20wks
	,qt_months_at_residence
	,qt_years_at_residence
	,qt_induced_termination_of_pregnancy
	,qt_born_child_now_dead
	,qt_born_child_now_living
	,dt_last_pregnancy_year
	,dt_last_birth_year
	,qt_parity
	,fl_previous_csection
	,fl_previous_preterm_infant
	,qt_prior_csections
	,fl_prior_poor_pregnancy_outcome
	,dt_last_pregnancy_month
	,dt_last_birth_month
	,id_fetal_or_infant_death
	,cd_fetal_or_infant_death
	,tx_fetal_or_infant_death
	)
SELECT mh.id_maternal_history
	,mh.cd_maternal_history
	,mh.qt_prior_fetal_geq_20wks
	,mh.qt_prior_fetal_lt_20wks
	,mh.qt_months_at_residence
	,mh.qt_years_at_residence
	,mh.qt_induced_termination_of_pregnancy
	,mh.qt_born_child_now_dead
	,mh.qt_born_child_now_living
	,mh.dt_last_pregnancy_year
	,mh.dt_last_birth_year
	,mh.qt_parity
	,mh.fl_previous_csection
	,mh.fl_previous_preterm_infant
	,mh.qt_prior_csections
	,mh.fl_prior_poor_pregnancy_outcome
	,mh.dt_last_pregnancy_month
	,mh.dt_last_birth_month
	,mh.id_fetal_or_infant_death
	,fid.cd_fetal_or_infant_death
	,fid.tx_fetal_or_infant_death
FROM rodis_wh.maternal_history_att mh
LEFT JOIN rodis_wh.fetal_or_infant_death_att fid ON fid.id_fetal_or_infant_death = mh.id_fetal_or_infant_death

UPDATE STATISTICS rodis_wh.maternal_history_dim
