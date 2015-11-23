CREATE PROCEDURE [rodis_wh].[load_maternal_behavior_dim]
AS
TRUNCATE TABLE rodis_wh.maternal_behavior_dim

INSERT rodis_wh.maternal_behavior_dim (
	id_maternal_behavior
	,cd_maternal_behavior
	,fl_married
	,fl_breast_feeding
	,qt_cigs_tri1
	,qt_cigs_tri2
	,qt_cigs_tri3
	,qt_cigs_prior
	,qt_alcoholic_drinks
	,fl_drank_during_pregnancy
	,qt_cigs
	,qt_prenatal_visits
	,fl_smoked_during_pregnancy
	,fl_birth_injury
	,fl_chlamydia
	,id_kotelchuck_index
	,cd_kotelchuck_index
	,tx_kotelchuck_index
	)
SELECT mb.id_maternal_behavior
	,mb.cd_maternal_behavior
	,mb.fl_married
	,mb.fl_breast_feeding
	,mb.qt_cigs_tri1
	,mb.qt_cigs_tri2
	,mb.qt_cigs_tri3
	,mb.qt_cigs_prior
	,mb.qt_alcoholic_drinks
	,mb.fl_drank_during_pregnancy
	,mb.qt_cigs
	,mb.qt_prenatal_visits
	,mb.fl_smoked_during_pregnancy
	,mb.fl_birth_injury
	,mb.fl_chlamydia
	,mb.id_kotelchuck_index
	,ki.cd_kotelchuck_index
	,ki.tx_kotelchuck_index
FROM rodis_wh.maternal_behavior_att mb
LEFT JOIN rodis_wh.kotelchuck_index_att ki ON ki.id_kotelchuck_index = mb.id_kotelchuck_index

UPDATE STATISTICS rodis_wh.maternal_behavior_dim
