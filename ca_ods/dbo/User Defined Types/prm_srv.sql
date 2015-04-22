CREATE TYPE [dbo].[prm_srv] AS TABLE (
    [cd_subctgry_poc_frc] INT          NOT NULL,
    [match_code]          DECIMAL (18) NOT NULL,
    PRIMARY KEY CLUSTERED ([cd_subctgry_poc_frc] ASC, [match_code] ASC));

