CREATE PROCEDURE [rodis_wh].[load_birth_administration_dim]
AS
TRUNCATE TABLE rodis_wh.birth_administration_dim

INSERT rodis_wh.birth_administration_dim (
	id_birth_administration
	,cd_birth_administration
	,fl_icu_maternal_admit
	,fl_infant_transfer
	,fl_nicu_child_admit
	,fl_or_maternal_admit
	,fl_malformation
	,dt_prenatal_care_start
	,fl_urban_tract
	,fl_prenatal_wic_benefits
	,dt_hour_birth_child
	,qt_latitude
	,qt_longitude
	,id_certifier_type
	,cd_certifier_type
	,tx_certifier_type
	,id_maternal_transfer_type
	,cd_maternal_transfer_type
	,tx_maternal_transfer_type
	,id_child_sex
	,cd_child_sex
	,tx_child_sex
	,id_facility_type
	,cd_facility_type
	,tx_facility_type
	,id_birth_familial_child
	,id_birth_familial_maternal
	,id_birth_familial_paternal
	,id_hospital_admission_child
	,id_hospital_admission_maternal
	,id_birth_child_condition
	,id_birth_child_procedure
	,id_maternal_behavior
	,id_maternal_condition
	,id_maternal_history
	,id_maternal_procedure
	)
SELECT ba.id_birth_administration
	,ba.cd_birth_administration
	,ba.fl_icu_maternal_admit
	,ba.fl_infant_transfer
	,ba.fl_nicu_child_admit
	,ba.fl_or_maternal_admit
	,ba.fl_malformation
	,ba.dt_prenatal_care_start
	,ba.fl_urban_tract
	,ba.fl_prenatal_wic_benefits
	,ba.dt_hour_birth_child
	,ba.qt_latitude
	,ba.qt_longitude
	,ba.id_certifier_type
	,ct.cd_certifier_type
	,ct.tx_certifier_type
	,ba.id_maternal_transfer_type
	,mt.cd_maternal_transfer_type
	,mt.tx_maternal_transfer_type
	,ba.id_child_sex
	,cs.cd_child_sex
	,cs.tx_child_sex
	,ba.id_facility_type
	,ft.cd_facility_type
	,ft.tx_facility_type
	,ba.id_birth_familial_child
	,ba.id_birth_familial_maternal
	,ba.id_birth_familial_paternal
	,ba.id_hospital_admission_child
	,ba.id_hospital_admission_maternal
	,ba.id_birth_child_condition
	,ba.id_birth_child_procedure
	,ba.id_maternal_behavior
	,ba.id_maternal_condition
	,ba.id_maternal_history
	,ba.id_maternal_procedure
FROM rodis_wh.birth_administration_att ba
LEFT JOIN rodis_wh.certifier_type_att ct ON ct.id_certifier_type = ba.id_certifier_type
LEFT JOIN rodis_wh.maternal_transfer_type_att mt ON mt.id_maternal_transfer_type = ba.id_maternal_transfer_type
LEFT JOIN rodis_wh.child_sex_att cs ON cs.id_child_sex = ba.id_child_sex
LEFT JOIN rodis_wh.facility_type_att ft ON ft.id_facility_type = ba.id_facility_type

UPDATE STATISTICS rodis_wh.birth_administration_dim
