CREATE TYPE [dbo].[risk_table] AS TABLE (
    [id_prsn_child]    INT           NULL,
    [outcome_cd]       INT           NULL,
    [outcome]          VARCHAR (100) NULL,
    [dur_days]         INT           NULL,
    [param_id]         BIGINT        NULL,
    [fl_risk]          INT           NULL,
    [fl_rightcensor]   INT           NULL,
    [fl_competingrisk] INT           NULL);

