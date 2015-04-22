CREATE TABLE [prtl].[p_los_2] (
    [state_fiscal_year] DATETIME      NOT NULL,
    [filtername]        VARCHAR (255) NULL,
    [filtercode]        INT           NOT NULL,
    [dur_days]          INT           NOT NULL,
    [num]               FLOAT (53)    NULL,
    [n_i]               FLOAT (53)    NULL,
    [q_i]               FLOAT (53)    NULL,
    [s_i]               FLOAT (53)    NULL,
    [1-s]               FLOAT (53)    NOT NULL,
    CONSTRAINT [PK_cfsr_permanency_outcome_legallyfree] PRIMARY KEY CLUSTERED ([state_fiscal_year] ASC, [filtercode] ASC, [dur_days] ASC)
);

