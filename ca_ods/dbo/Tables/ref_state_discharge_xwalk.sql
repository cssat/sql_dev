CREATE TABLE [dbo].[ref_state_discharge_xwalk] (
    [cd_dsch_rsn]                 INT           NOT NULL,
    [tx_dsch_rsn]                 VARCHAR (200) NULL,
    [state_discharge_reason_code] INT           NULL,
    [cd_discharge_type]           INT           NULL,
    [discharge_type]              VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([cd_dsch_rsn] ASC)
);

