CREATE PROCEDURE [rodis_wh].[load_hospital_admission_dim]
AS
TRUNCATE TABLE rodis_wh.hospital_admission_dim

INSERT rodis_wh.hospital_admission_dim (
	id_hospital_admission
	,cd_hospital_admission
	,cd_child_admit_zip
	,qt_length_of_stay_days
	,rank_of_admission
	,id_admission_source
	,cd_admission_source
	,tx_admission_source
	,id_admission_reason
	,cd_admission_reason
	,tx_admission_reason
	,id_facility
	,cd_facility
	,tx_facility
	,id_discharge_status
	,cd_discharge_status
	,tx_discharge_status
	,id_ecode
	,cd_ecode
	,tx_ecode
	,id_payment_primary
	,id_payment_secondary
	)
SELECT ha.id_hospital_admission
	,ha.cd_hospital_admission
	,ha.cd_child_admit_zip
	,ha.qt_length_of_stay_days
	,ha.rank_of_admission
	,ha.id_admission_source
	,s.cd_admission_source
	,s.tx_admission_source
	,ha.id_admission_reason
	,r.cd_admission_reason
	,r.tx_admission_reason
	,ha.id_facility
	,f.cd_facility
	,f.tx_facility
	,ha.id_discharge_status
	,d.cd_discharge_status
	,d.tx_discharge_status
	,ha.id_ecode
	,e.cd_ecode
	,e.tx_ecode
	,ha.id_payment_primary
	,ha.id_payment_secondary
FROM rodis_wh.hospital_admission_att ha
LEFT JOIN rodis_wh.admission_source_att s ON s.id_admission_source = ha.id_admission_source
LEFT JOIN rodis_wh.admission_reason_att r ON r.id_admission_reason = ha.id_admission_reason
LEFT JOIN rodis_wh.facility_att f ON f.id_facility = ha.id_facility
LEFT JOIN rodis_wh.discharge_status_att d ON d.id_discharge_status = ha.id_discharge_status
LEFT JOIN rodis_wh.ecode_att e ON  e.id_ecode = ha.id_ecode

UPDATE STATISTICS rodis_wh.hospital_admission_dim
