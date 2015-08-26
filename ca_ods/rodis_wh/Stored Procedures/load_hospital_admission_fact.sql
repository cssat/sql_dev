CREATE PROCEDURE [rodis_wh].[load_hospital_admission_fact]
AS
TRUNCATE TABLE rodis_wh.hospital_admission_fact

INSERT rodis_wh.hospital_admission_fact (
	id_hospital_admission_fact
	,cd_hospital_admission_fact
	,id_prsn_child
	,id_calendar_dim_admit
	,id_calendar_dim_discharge
	,am_hospital_charges
	,qt_length_of_stay_days
	,qt_of_admissions
	,id_hospital_admission
	,hospital_admission_id_payment_primary
	,hospital_admission_id_payment_secondary
	)
SELECT haf.id_hospital_admission_fact
	,haf.cd_hospital_admission_fact
	,haf.id_prsn_child
	,haf.id_calendar_dim_admit
	,haf.id_calendar_dim_discharge
	,haf.am_hospital_charges
	,haf.qt_length_of_stay_days
	,haf.qt_of_admissions
	,haf.id_hospital_admission
	,had.id_payment_primary [hospital_admission_id_payment_primary]
	,had.id_payment_secondary [hospital_admission_id_payment_secondary]
FROM rodis_wh.hospital_admission_fat haf
LEFT JOIN rodis_wh.hospital_admission_dim had ON had.id_hospital_admission = haf.id_hospital_admission

UPDATE STATISTICS rodis_wh.hospital_admission_fact
