CREATE TABLE [dbo].[ref_lookup_max_date] (
    [id]             INT            NOT NULL,
    [procedure_name] NVARCHAR (200) NULL,
    [max_date_all]   DATETIME       NULL,
    [max_date_any]   DATETIME       NULL,
    [max_date_qtr]   DATETIME       NULL,
    [max_date_yr]    DATETIME       NULL,
    [min_date_any]   DATETIME       NULL,
    [is_current]     INT            NULL,
    CONSTRAINT [PK_ref_lookup_max_date] PRIMARY KEY CLUSTERED ([id] ASC)
);

