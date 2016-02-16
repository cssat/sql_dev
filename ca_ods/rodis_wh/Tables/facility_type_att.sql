CREATE TABLE [rodis_wh].[facility_type_att] (
    [id_facility_type] INT          NOT NULL,
    [cd_facility_type] VARCHAR (50) NOT NULL,
    [tx_facility_type] VARCHAR (50) NULL,
    CONSTRAINT [pk_facility_type_att] PRIMARY KEY CLUSTERED ([id_facility_type] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_facility_type_att_cd_facility_type]
    ON [rodis_wh].[facility_type_att]([cd_facility_type] ASC);

