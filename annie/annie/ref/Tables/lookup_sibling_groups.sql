CREATE TABLE [ref].[lookup_sibling_groups]
(
    [bin_sibling_group_size] INT NOT NULL 
        CONSTRAINT [pk_lookup_sibling_groups] PRIMARY KEY, 
    [nbr_sibling_desc] VARCHAR(50) NOT NULL
)
