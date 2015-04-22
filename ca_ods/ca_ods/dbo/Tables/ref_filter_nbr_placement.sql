CREATE TABLE [dbo].[ref_filter_nbr_placement] (
    [bin_placement_cd]   INT           NOT NULL,
    [bin_placement_desc] VARCHAR (200) NULL,
    [nbr_placement_from] INT           NULL,
    [nbr_placement_thru] INT           NULL,
    CONSTRAINT [PK_ref_filter_nbr_placement] PRIMARY KEY CLUSTERED ([bin_placement_cd] ASC)
);

