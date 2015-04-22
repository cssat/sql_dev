CREATE TABLE [dbo].[PEOPLE_DIM] (
    [ID_PEOPLE_DIM]                    INT           NOT NULL,
    [ID_PRSN]                          INT           NULL,
    [ID_ACES]                          INT           NULL,
    [ID_WORKER_DIM_SSI_SSA_UPDATE]     INT           NULL,
    [TX_BRAAM_RACE]                    VARCHAR (200) NULL,
    [CD_CMBN_ETHN]                     INT           NULL,
    [TX_CMBN_ETHN]                     VARCHAR (200) NULL,
    [CD_CTZN]                          INT           NULL,
    [TX_CTZN]                          VARCHAR (200) NULL,
    [CD_GNDR]                          CHAR (1)      NULL,
    [TX_GNDR]                          VARCHAR (200) NULL,
    [CD_HSPNC]                         CHAR (1)      NULL,
    [TX_HSPNC]                         VARCHAR (200) NULL,
    [CD_INDN]                          INT           NULL,
    [TX_INDN]                          VARCHAR (200) NULL,
    [CD_INDN2]                         INT           NULL,
    [TX_INDN2]                         VARCHAR (200) NULL,
    [CD_LICWAC]                        INT           NULL,
    [TX_LICWAC]                        VARCHAR (200) NULL,
    [CD_LNG_PRFR]                      INT           NULL,
    [TX_LNG_PRFR]                      VARCHAR (200) NULL,
    [CD_LNG_SECONDARY]                 INT           NULL,
    [TX_LNG_SECONDARY]                 VARCHAR (200) NULL,
    [CD_LTD_ENGLISH]                   INT           NULL,
    [TX_LTD_ENGLISH]                   VARCHAR (200) NULL,
    [CD_MRTL_STAT]                     INT           NULL,
    [TX_MRTL_STAT]                     VARCHAR (200) NULL,
    [TX_MULTIRACE]                     VARCHAR (250) NULL,
    [CD_PRNTL_RLTNSHP]                 INT           NULL,
    [TX_PRNTL_RLTNSHP]                 VARCHAR (200) NULL,
    [CD_RACE]                          INT           NULL,
    [TX_RACE]                          VARCHAR (200) NULL,
    [CD_RACE_FIVE]                     INT           NULL,
    [TX_RACE_FIVE]                     VARCHAR (200) NULL,
    [CD_RACE_FOUR]                     INT           NULL,
    [TX_RACE_FOUR]                     VARCHAR (200) NULL,
    [CD_RACE_THREE]                    INT           NULL,
    [TX_RACE_THREE]                    VARCHAR (200) NULL,
    [CD_RACE_TWO]                      INT           NULL,
    [TX_RACE_TWO]                      VARCHAR (200) NULL,
    [CD_RLGN]                          INT           NULL,
    [TX_RLGN]                          VARCHAR (200) NULL,
    [CD_SSI_SSA_STATUS]                INT           NULL,
    [TX_SSI_SSA_STATUS]                VARCHAR (200) NULL,
    [CD_STATE_RSDNT]                   CHAR (1)      NULL,
    [TX_STATE_RSDNT]                   VARCHAR (200) NULL,
    [FL_ADOPTION_MATCH]                CHAR (1)      NULL,
    [FL_DANGER_TO_WORKER]              CHAR (1)      NULL,
    [FL_DECEASED]                      CHAR (1)      NULL,
    [FL_DT_BIRTH_ESTIMATED]            CHAR (1)      NULL,
    [FL_EMOTION_DSTRBD]                CHAR (1)      NULL,
    [FL_ICW_INVOLVEMENT]               CHAR (1)      NULL,
    [FL_MNTAL_RETARDATN]               CHAR (1)      NULL,
    [FL_OTHR_SPC_CARE]                 CHAR (1)      NULL,
    [FL_PHYS_DISABLED]                 CHAR (1)      NULL,
    [FL_PRSN_MALTREATER]               CHAR (1)      NULL,
    [FL_SEX_AGGRESIVE_YOUTH]           CHAR (1)      NULL,
    [FL_TEEN_PARENT]                   CHAR (1)      NULL,
    [FL_VIS_HEARING_IMPR]              CHAR (1)      NULL,
    [DT_BIRTH]                         DATETIME      NULL,
    [DT_DEATH]                         DATETIME      NULL,
    [DT_LICWAC_DETERMINATION]          DATETIME      NULL,
    [MULTI_RACE_MASK]                  INT           NULL,
    [DT_ROW_BEGIN]                     DATETIME      NULL,
    [DT_ROW_END]                       DATETIME      NULL,
    [ID_CYCLE]                         INT           NULL,
    [IS_CURRENT]                       INT           NULL,
    [FL_DELETED]                       CHAR (1)      NULL,
    [FL_EXPUNGED]                      CHAR (1)      NULL,
    [FL_PHYSICAL_AGGRSVE_YOUTH]        CHAR (1)      NULL,
    [CD_REG_SEX_OFFENDER_LEVEL]        INT           NULL,
    [TX_REG_SEX_OFFENDER_LEVEL]        VARCHAR (200) NULL,
    [CD_SEXUAL_BEHAVIOR]               INT           NULL,
    [TX_SEXUAL_BEHAVIOR]               VARCHAR (200) NULL,
    [CD_RISKY_BEHAVIOR]                INT           NULL,
    [TX_RISKY_BEHAVIOR]                VARCHAR (200) NULL,
    [FL_LITIGATION_HOLD]               CHAR (1)      NULL,
    [FL_PUBLIC_DISCLOSURE]             CHAR (1)      NULL,
    [ID_PRSN_MOM]                      INT           NULL,
    [ID_PRSN_DAD]                      INT           NULL,
    [ID_PEOPLE_DIM_MOM]                INT           NULL,
    [ID_PEOPLE_DIM_DAD]                INT           NULL,
    [FL_PATERNITY_STATUS_KNOWN]        CHAR (1)      NULL,
    [CD_MULTI_RACE_ETHNICITY]          INT           NULL,
    [TX_MULTI_RACE_ETHNICITY]          VARCHAR (200) NULL,
    [cd_race_census]                   INT           NULL,
    [tx_race_census]                   VARCHAR (200) NULL,
    [census_Hispanic_Latino_Origin_cd] INT           NULL,
    CONSTRAINT [pk_ID_PEOPLE_DIM] PRIMARY KEY CLUSTERED ([ID_PEOPLE_DIM] ASC),
    CONSTRAINT [fk_PEOPLE_DIM_ID_WORKER_DIM_SSI_SSA_UPDATE] FOREIGN KEY ([ID_WORKER_DIM_SSI_SSA_UPDATE]) REFERENCES [dbo].[WORKER_DIM] ([ID_WORKER_DIM])
);


GO
CREATE NONCLUSTERED INDEX [idx_dt_birth]
    ON [dbo].[PEOPLE_DIM]([DT_BIRTH] ASC)
    INCLUDE([ID_PRSN], [CD_MRTL_STAT], [TX_MRTL_STAT]);


GO
CREATE NONCLUSTERED INDEX [idx_id_prsn]
    ON [dbo].[PEOPLE_DIM]([ID_PRSN] ASC, [CD_GNDR] ASC, [IS_CURRENT] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_id_people_dim_mom]
    ON [dbo].[PEOPLE_DIM]([ID_PEOPLE_DIM_MOM] ASC)
    INCLUDE([ID_PEOPLE_DIM], [ID_PRSN], [ID_PRSN_MOM]);


GO
CREATE NONCLUSTERED INDEX [idx_id_people_dim_dad]
    ON [dbo].[PEOPLE_DIM]([ID_PEOPLE_DIM_DAD] ASC)
    INCLUDE([ID_PEOPLE_DIM], [ID_PRSN], [ID_PRSN_DAD]);

