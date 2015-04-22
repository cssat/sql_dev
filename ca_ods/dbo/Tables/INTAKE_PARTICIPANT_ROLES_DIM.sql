CREATE TABLE [dbo].[INTAKE_PARTICIPANT_ROLES_DIM] (
    [ID_INTAKE_PARTICIPANT_ROLES_DIM] INT           NOT NULL,
    [CD_ROLE1]                        INT           NULL,
    [TX_ROLE1]                        VARCHAR (200) NULL,
    [CD_ROLE2]                        INT           NULL,
    [TX_ROLE2]                        VARCHAR (200) NULL,
    [CD_ROLE3]                        INT           NULL,
    [TX_ROLE3]                        VARCHAR (200) NULL,
    [CD_ROLE4]                        INT           NULL,
    [TX_ROLE4]                        VARCHAR (200) NULL,
    [CD_ROLE5]                        INT           NULL,
    [TX_ROLE5]                        VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                    DATETIME      NULL,
    [DT_ROW_END]                      DATETIME      NULL,
    [ID_CYCLE]                        INT           NULL,
    [IS_CURRENT]                      INT           NULL,
    CONSTRAINT [pk_id_intake_participant_roles_dim] PRIMARY KEY CLUSTERED ([ID_INTAKE_PARTICIPANT_ROLES_DIM] ASC)
);

