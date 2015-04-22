CREATE TYPE [dbo].[prm_ihs] AS TABLE (
    [bin_ihs_svc_cd] INT NOT NULL,
    [match_code]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([bin_ihs_svc_cd] ASC, [match_code] ASC));

