CREATE TABLE [dbo].[ref_lookup_plcmnt] (
    [cd_plcm_setng] INT           NOT NULL,
    [tx_plcm_setng] VARCHAR (200) NULL,
    CONSTRAINT [PK_ref_lookup_plcmnt] PRIMARY KEY CLUSTERED ([cd_plcm_setng] ASC)
);

