CREATE TABLE [dbo].[ref_filter_access_type] (
    [cd_access_type]     INT           NOT NULL,
    [tx_access_type]     VARCHAR (200) NULL,
    [fl_name]            VARCHAR (100) NULL,
    [cd_multiplier]      DECIMAL (18)  NULL,
    [filter_access_type] INT           NOT NULL,
    [min_filter_date] DATETIME NULL, 
    CONSTRAINT [PK_ref_filter_access_type] PRIMARY KEY CLUSTERED ([cd_access_type] ASC)
);

