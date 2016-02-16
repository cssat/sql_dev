CREATE TABLE [rodis_wh].[hospital_admission_dim] (
    [id_hospital_admission]  INT           NOT NULL,
    [cd_hospital_admission]  VARCHAR (50)  NOT NULL,
    [cd_child_admit_zip]     INT           NULL,
    [qt_length_of_stay_days] SMALLINT      NULL,
    [rank_of_admission]      TINYINT       NULL,
    [id_admission_source]    INT           NOT NULL,
    [cd_admission_source]    VARCHAR (50)  NOT NULL,
    [tx_admission_source]    VARCHAR (50)  NULL,
    [id_admission_reason]    INT           NOT NULL,
    [cd_admission_reason]    VARCHAR (50)  NOT NULL,
    [tx_admission_reason]    VARCHAR (50)  NULL,
    [id_facility]            INT           NOT NULL,
    [cd_facility]            VARCHAR (50)  NOT NULL,
    [tx_facility]            VARCHAR (100) NULL,
    [id_discharge_status]    INT           NOT NULL,
    [cd_discharge_status]    VARCHAR (50)  NOT NULL,
    [tx_discharge_status]    VARCHAR (50)  NULL,
    [id_ecode]               INT           NOT NULL,
    [cd_ecode]               VARCHAR (50)  NOT NULL,
    [tx_ecode]               VARCHAR (50)  NULL,
    [id_payment_primary]     INT           NOT NULL,
    [id_payment_secondary]   INT           NOT NULL,
    [bc_uni]                 VARCHAR (50)  NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_dim_bc_uni]
    ON [rodis_wh].[hospital_admission_dim]([bc_uni] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_dim]
    ON [rodis_wh].[hospital_admission_dim]([id_hospital_admission] ASC)
    INCLUDE([id_payment_primary], [id_payment_secondary]);

