CREATE TABLE [prtl].[ooh_int_hash_key] (
    [parameter_id]   INT           NOT NULL,
    [parameter_name] VARCHAR (100) NULL,
    [formula]        VARCHAR (100) NULL,
    [multiplier]     DECIMAL (22)  NULL,
    CONSTRAINT [PK_ooh_int_hash_key] PRIMARY KEY CLUSTERED ([parameter_id] ASC)
);

