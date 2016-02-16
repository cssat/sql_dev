CREATE TABLE [rodis_wh].[diagnosis_m2m_fact] (
    [id_diagnosis_m2m]                        INT          NOT NULL,
    [cd_diagnosis_m2m]                        VARCHAR (50) NOT NULL,
    [id_diagnosis]                            INT          NOT NULL,
    [id_diagnosis_order]                      INT          NOT NULL,
    [id_hospital_admission]                   INT          NOT NULL,
    [hospital_admission_id_payment_primary]   INT          NOT NULL,
    [hospital_admission_id_payment_secondary] INT          NOT NULL
);

