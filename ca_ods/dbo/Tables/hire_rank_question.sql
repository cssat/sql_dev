CREATE TABLE [dbo].[hire_rank_question] (
    [id_episode]   BIGINT        NOT NULL,
    [id_plcmnt]    BIGINT        NOT NULL,
    [entry_date]   DATETIME      NOT NULL,
    [exit_date]    DATETIME      NULL,
    [cd_epsd_type] INT           NULL,
    [tx_epsd_type] VARCHAR (200) NULL,
    CONSTRAINT [PK_hire_rank_question] PRIMARY KEY CLUSTERED ([id_episode] ASC, [id_plcmnt] ASC)
);

