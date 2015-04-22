CREATE TYPE [dbo].[prm_rpt] AS TABLE (
    [cd_reporter_type] INT NOT NULL,
    [match_code]       INT NOT NULL,
    PRIMARY KEY CLUSTERED ([cd_reporter_type] ASC, [match_code] ASC));

