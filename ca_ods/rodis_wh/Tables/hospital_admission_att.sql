CREATE TABLE [rodis_wh].[hospital_admission_att] (
    [id_hospital_admission]  INT          NOT NULL,
    [cd_hospital_admission]  VARCHAR (50) NOT NULL,
    [cd_child_admit_zip]     INT          NULL,
    [qt_length_of_stay_days] SMALLINT     NULL,
    [rank_of_admission]      TINYINT      NULL,
    [id_admission_source]    INT          NOT NULL,
    [id_admission_reason]    INT          NOT NULL,
    [id_facility]            INT          NOT NULL,
    [id_discharge_status]    INT          NOT NULL,
    [id_ecode]               INT          NOT NULL,
    [id_payment_primary]     INT          NOT NULL,
    [id_payment_secondary]   INT          NOT NULL,
    CONSTRAINT [pk_hospital_admission_att] PRIMARY KEY CLUSTERED ([id_hospital_admission] ASC),
    CONSTRAINT [fk_hospital_admission_att_id_admission_reason] FOREIGN KEY ([id_admission_reason]) REFERENCES [rodis_wh].[admission_reason_att] ([id_admission_reason]),
    CONSTRAINT [fk_hospital_admission_att_id_admission_source] FOREIGN KEY ([id_admission_source]) REFERENCES [rodis_wh].[admission_source_att] ([id_admission_source]),
    CONSTRAINT [fk_hospital_admission_att_id_discharge_status] FOREIGN KEY ([id_discharge_status]) REFERENCES [rodis_wh].[discharge_status_att] ([id_discharge_status]),
    CONSTRAINT [fk_hospital_admission_att_id_ecode] FOREIGN KEY ([id_ecode]) REFERENCES [rodis_wh].[ecode_att] ([id_ecode]),
    CONSTRAINT [fk_hospital_admission_att_id_facility] FOREIGN KEY ([id_facility]) REFERENCES [rodis_wh].[facility_att] ([id_facility]),
    CONSTRAINT [fk_hospital_admission_att_id_payment_primary] FOREIGN KEY ([id_payment_primary]) REFERENCES [rodis_wh].[payment_att] ([id_payment]),
    CONSTRAINT [fk_hospital_admission_att_id_payment_secondary] FOREIGN KEY ([id_payment_secondary]) REFERENCES [rodis_wh].[payment_att] ([id_payment])
);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_payment_secondary]
    ON [rodis_wh].[hospital_admission_att]([id_payment_secondary] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_payment_primary]
    ON [rodis_wh].[hospital_admission_att]([id_payment_primary] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_ecode]
    ON [rodis_wh].[hospital_admission_att]([id_ecode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_discharge_status]
    ON [rodis_wh].[hospital_admission_att]([id_discharge_status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_facility]
    ON [rodis_wh].[hospital_admission_att]([id_facility] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_admission_reason]
    ON [rodis_wh].[hospital_admission_att]([id_admission_reason] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_hospital_admission_att_id_admission_source]
    ON [rodis_wh].[hospital_admission_att]([id_admission_source] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_hospital_admission_att_cd_hospital_admission]
    ON [rodis_wh].[hospital_admission_att]([cd_hospital_admission] ASC);

