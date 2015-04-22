CREATE TABLE [dbo].[ref_federal_discharge_reason_xwalk] (
    [state_discharge_reason_code]   INT           NOT NULL,
    [state_discharge_reason]        VARCHAR (255) NULL,
    [federal_discharge_reason_code] INT           NULL,
    [federal_category_label]        VARCHAR (255) NULL
);

