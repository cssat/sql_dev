CREATE TYPE [dbo].[prm_plc] AS TABLE (
    [bin_placement_cd] INT NOT NULL,
    [match_code]       INT NOT NULL,
    PRIMARY KEY CLUSTERED ([bin_placement_cd] ASC, [match_code] ASC));

