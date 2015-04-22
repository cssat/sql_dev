CREATE TYPE [dbo].[prm_los] AS TABLE (
    [bin_los_cd] INT NOT NULL,
    [match_code] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([bin_los_cd] ASC, [match_code] ASC));

