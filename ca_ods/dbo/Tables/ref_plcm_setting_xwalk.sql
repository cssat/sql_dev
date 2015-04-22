CREATE TABLE [dbo].[ref_plcm_setting_xwalk] (
    [cd_plcm_setng]      INT           NOT NULL,
    [tx_plcm_setng]      VARCHAR (200) NULL,
    [berk_tx_plcm_setng] VARCHAR (200) NULL,
    [berk_cd_plcm_setng] INT           NULL,
    PRIMARY KEY CLUSTERED ([cd_plcm_setng] ASC)
);

