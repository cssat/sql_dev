CREATE TABLE [dbo].[ref_filter_los] (
    [bin_los_cd]    INT        NOT NULL,
    [bin_los_desc]  CHAR (200) NULL,
    [dur_days_from] INT        NULL,
    [dur_days_thru] INT        NULL,
    [lag]           INT        NULL,
    CONSTRAINT [PK_ref_filter_los] PRIMARY KEY CLUSTERED ([bin_los_cd] ASC)
);

