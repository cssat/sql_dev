CREATE TABLE [rodis_wh].[facility_att] (
    [id_facility] INT           NOT NULL,
    [cd_facility] VARCHAR (50)  NOT NULL,
    [tx_facility] VARCHAR (100) NULL,
    CONSTRAINT [pk_facility_att] PRIMARY KEY CLUSTERED ([id_facility] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_facility_att_cd_facility]
    ON [rodis_wh].[facility_att]([cd_facility] ASC);

