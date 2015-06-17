CREATE TABLE [ref].[filter_nbr_placement]
(
    [bin_placement_cd] INT NOT NULL PRIMARY KEY, 
    [bin_placement_desc] VARCHAR(50) NOT NULL, 
    [nbr_placement_from] INT NULL, 
    [nbr_placement_thru] INT NULL
)
