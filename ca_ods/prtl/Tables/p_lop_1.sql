CREATE TABLE [prtl].[p_lop_1] (
    [state_fiscal_year] DATETIME      NOT NULL,
    [filtername]        VARCHAR (255) NULL,
    [filtercode]        INT           NOT NULL,
    [dur_days]          INT           NOT NULL,
    [num]               INT           NULL,
    [n_i]               FLOAT (53)    NULL,
    [q_i]               INT           NULL,
    [s_i]               FLOAT (53)    NULL,
    [1-s]               FLOAT (53)    NULL,
    CONSTRAINT [PK_cfsr_permanency_reunification_within1yr_reentry] PRIMARY KEY CLUSTERED ([state_fiscal_year] ASC, [filtercode] ASC, [dur_days] ASC)
);

