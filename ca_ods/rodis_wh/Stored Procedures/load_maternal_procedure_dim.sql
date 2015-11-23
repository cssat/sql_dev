CREATE PROCEDURE [rodis_wh].[load_maternal_procedure_dim]
AS
TRUNCATE TABLE rodis_wh.maternal_procedure_dim

INSERT rodis_wh.maternal_procedure_dim (
	id_maternal_procedure
	,cd_maternal_procedure
	,fl_hysterectomy
	,fl_induced
	,fl_any_obstetric_procedure
	,fl_forcep_use
	,fl_steroids_given
	,fl_labor_stimulation
	,fl_tocolysis_meds
	,fl_transfusion
	,fl_vacuum_failed
	,fl_vacuum_used
	,id_csection
	,cd_csection
	,tx_csection
	)
SELECT mp.id_maternal_procedure
	,mp.cd_maternal_procedure
	,mp.fl_hysterectomy
	,mp.fl_induced
	,mp.fl_any_obstetric_procedure
	,mp.fl_forcep_use
	,mp.fl_steroids_given
	,mp.fl_labor_stimulation
	,mp.fl_tocolysis_meds
	,mp.fl_transfusion
	,mp.fl_vacuum_failed
	,mp.fl_vacuum_used
	,mp.id_csection
	,cs.cd_csection
	,cs.tx_csection
FROM rodis_wh.maternal_procedure_att mp
LEFT JOIN rodis_wh.csection_att cs ON cs.id_csection = mp.id_csection

UPDATE STATISTICS rodis_wh.maternal_procedure_dim
