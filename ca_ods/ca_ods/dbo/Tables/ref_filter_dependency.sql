CREATE TABLE [dbo].[ref_filter_dependency] (
    [bin_dep_cd]      INT        NOT NULL,
    [bin_dep_desc]    CHAR (200) NULL,
    [diff_days_from]  INT        NULL,
    [diff_days_thru]  INT        NULL,
    [fl_dep_exist]    TINYINT    NULL,
    [lag]             INT        NULL,
    [min_filter_date] DATETIME   NULL,
    CONSTRAINT [PK_ref_filter_dependency] PRIMARY KEY CLUSTERED ([bin_dep_cd] ASC)
);

