CREATE TABLE [base].[procedure_flow] (
    [ikey]          INT           IDENTITY (1, 1) NOT NULL,
    [execute_order] INT           NULL,
    [procedure_nm]  VARCHAR (500) NULL,
    [last_run_date] DATETIME      NULL
);

