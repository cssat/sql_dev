CREATE TABLE [rodis_wh].[procedure_m2m_fact] (
    [id_procedure_m2m]                        INT          NOT NULL,
    [cd_procedure_m2m]                        VARCHAR (50) NOT NULL,
    [id_procedure]                            INT          NOT NULL,
    [id_procedure_order]                      INT          NOT NULL,
    [id_hospital_admission]                   INT          NOT NULL,
    [hospital_admission_id_payment_primary]   INT          NOT NULL,
    [hospital_admission_id_payment_secondary] INT          NOT NULL
);

