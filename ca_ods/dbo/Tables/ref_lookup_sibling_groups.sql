CREATE TABLE [dbo].[ref_lookup_sibling_groups] (
    [nbr_siblings]       INT          NOT NULL,
    [sibling_group_name] VARCHAR (50) NULL,
    CONSTRAINT [PK_ref_lookup_sibling_groups] PRIMARY KEY CLUSTERED ([nbr_siblings] ASC)
);

