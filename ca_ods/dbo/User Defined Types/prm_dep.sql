CREATE TYPE [dbo].[prm_dep] AS TABLE (
    [bin_dep_cd] INT          NOT NULL,
    [match_code] DECIMAL (18) NOT NULL,
    PRIMARY KEY CLUSTERED ([bin_dep_cd] ASC, [match_code] ASC));

