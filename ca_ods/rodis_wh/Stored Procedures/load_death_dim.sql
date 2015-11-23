CREATE PROCEDURE [rodis_wh].[load_death_dim]
AS
TRUNCATE TABLE rodis_wh.death_dim

INSERT rodis_wh.death_dim (
	id_death
	,cd_death
	,fl_autopsy
	,fl_citizen
	,fl_city_limits_death
	,fl_coroner_referred
	,fl_smoked
	,dt_death_dtg
	,dt_injury_dtg
	,id_armed_forces
	,cd_armed_forces
	,tx_armed_forces
	,id_attendent_type
	,cd_attendent_type
	,tx_attendent_type
	,id_place_of_death
	,cd_place_of_death
	,tx_place_of_death
	,id_place_of_death_type
	,cd_place_of_death_type
	,tx_place_of_death_type
	,id_marital_status
	,cd_marital_status
	,tx_marital_status
	,id_ucode
	,cd_ucode
	,tx_ucode
	,id_city_of_death
	,id_city_of_injury
	,id_city_of_residence_at_death
	,id_education
	,id_birth_administration
	,id_hospital_admission_last
	)
SELECT d.id_death
	,d.cd_death
	,d.fl_autopsy
	,d.fl_citizen
	,d.fl_city_limits_death
	,d.fl_coroner_referred
	,d.fl_smoked
	,d.dt_death_dtg
	,d.dt_injury_dtg
	,d.id_armed_forces
	,af.cd_armed_forces
	,af.tx_armed_forces
	,d.id_attendent_type
	,att.cd_attendent_type
	,att.tx_attendent_type
	,d.id_place_of_death
	,pd.cd_place_of_death
	,pd.tx_place_of_death
	,pd.id_place_of_death_type
	,pdt.cd_place_of_death_type
	,pdt.tx_place_of_death_type
	,d.id_marital_status
	,ms.cd_marital_status
	,ms.tx_marital_status
	,d.id_ucode
	,u.cd_ucode
	,u.tx_ucode
	,d.id_city_of_death
	,d.id_city_of_injury
	,d.id_city_of_residence_at_death
	,d.id_education
	,d.id_birth_administration
	,d.id_hospital_admission_last
FROM rodis_wh.death_att d
LEFT JOIN rodis_wh.armed_forces_att af ON af.id_armed_forces = d.id_armed_forces
LEFT JOIN rodis_wh.attendent_type_att att ON att.id_attendent_type = d.id_attendent_type
LEFT JOIN rodis_wh.place_of_death_att pd ON pd.id_place_of_death = d.id_place_of_death
LEFT JOIN rodis_wh.place_of_death_type_att pdt ON pdt.id_place_of_death_type = pd.id_place_of_death_type
LEFT JOIN rodis_wh.marital_status_att ms ON ms.id_marital_status = d.id_marital_status
LEFT JOIN rodis_wh.ucode_att u ON u.id_ucode = d.id_ucode

UPDATE STATISTICS rodis_wh.death_dim
