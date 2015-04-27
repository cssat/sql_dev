﻿CREATE TABLE [dbo].[PROVIDER_DIM] (
    [ID_PROVIDER_DIM]                          INT           NOT NULL,
    [ID_BSNS]                                  INT           NULL,
    [ID_PRVD_ORG]                              INT           NULL,
    [ID_SSPS]                                  INT           NULL,
    [ID_CALENDAR_DIM_CREATED]                  INT           NULL,
    [CD_MAIL_CITY]                             INT           NULL,
    [TX_MAIL_CITY]                             VARCHAR (100) NULL,
    [TX_MAIL_COUNTY]                           VARCHAR (200) NULL,
    [TX_MAIL_STATE]                            VARCHAR (2)   NULL,
    [TX_MAIL_ZIP]                              VARCHAR (9)   NULL,
    [CD_PHYS_CITY]                             INT           NULL,
    [TX_PHYS_CITY]                             VARCHAR (100) NULL,
    [TX_PHYS_COUNTY]                           VARCHAR (200) NULL,
    [TX_PHYS_STATE]                            VARCHAR (2)   NULL,
    [TX_PHYS_ZIP]                              VARCHAR (9)   NULL,
    [CD_PROVIDER_TYPE]                         INT           NULL,
    [TX_PROVIDER_TYPE]                         VARCHAR (200) NULL,
    [CD_REGION]                                INT           NULL,
    [TX_REGION]                                VARCHAR (200) NULL,
    [CD_SSPS_STATUS]                           INT           NULL,
    [TX_SSPS_STATUS]                           VARCHAR (200) NULL,
    [CD_STAT]                                  CHAR (1)      NULL,
    [CD_TRIBAL_AFLTN]                          INT           NULL,
    [TX_TRIBAL_AFLTN]                          VARCHAR (200) NULL,
    [FL_24_HOUR_CARE]                          CHAR (1)      NULL,
    [FL_ABUSES_ANIMALS]                        CHAR (1)      NULL,
    [FL_ADA_NEEDS]                             CHAR (1)      NULL,
    [FL_ADJUDICATED_CRIMINAL]                  CHAR (1)      NULL,
    [FL_AFFILIATED_WITH_GANGS]                 CHAR (1)      NULL,
    [FL_AUTISTIC]                              CHAR (1)      NULL,
    [FL_BEFORE_AFTER_SCHOOL_ONLY]              CHAR (1)      NULL,
    [FL_DEVELOPMENTAL_DELAY]                   CHAR (1)      NULL,
    [FL_DIABETIC]                              CHAR (1)      NULL,
    [FL_DIAGNOSED_MENTAL_HEALTH_CONDITION]     CHAR (1)      NULL,
    [FL_DIAGNOSED_WITH_FETAL_ALCOHOL_SYNDROME] CHAR (1)      NULL,
    [FL_DRUG_AFFECTED]                         CHAR (1)      NULL,
    [FL_EATING_DISORDER]                       CHAR (1)      NULL,
    [FL_ENCOPRETIC]                            CHAR (1)      NULL,
    [FL_ENURESIS]                              CHAR (1)      NULL,
    [FL_EVENING]                               CHAR (1)      NULL,
    [FL_FEMALE]                                CHAR (1)      NULL,
    [FL_FIRE_SETTER]                           CHAR (1)      NULL,
    [FL_HEARING_IMPAIRED]                      CHAR (1)      NULL,
    [FL_HIV_POSITIVE]                          CHAR (1)      NULL,
    [FL_IV_DRUG_USER]                          CHAR (1)      NULL,
    [FL_IVE_TRIBAL_AGREEMENT]                  CHAR (1)      NULL,
    [FL_IVE_TRIBAL_AGRMT_IN_PLC]               CHAR (1)      NULL,
    [FL_LEARNING_DISABILITIES]                 CHAR (1)      NULL,
    [FL_LIFE_SKILLS_TRAINING]                  CHAR (1)      NULL,
    [FL_MALE]                                  CHAR (1)      NULL,
    [FL_MASTURBATES_IN_PUBLIC]                 CHAR (1)      NULL,
    [FL_MEDICALLY_FRAGILE]                     CHAR (1)      NULL,
    [FL_NAA_ACCREDITED]                        CHAR (1)      NULL,
    [FL_NAEYC_ACCREDITED]                      CHAR (1)      NULL,
    [FL_NAFCC_ACCREDITED]                      CHAR (1)      NULL,
    [FL_OPEN]                                  CHAR (1)      NULL,
    [FL_PARENT_AGENCY]                         CHAR (1)      NULL,
    [FL_PHYSICALLY_AGGRESSIVE_YOUTH]           CHAR (1)      NULL,
    [FL_PHYSICALLY_ASSAULTIVE_YOUTH_PAY]       CHAR (1)      NULL,
    [FL_PROPERTY_DESTRUCTION]                  CHAR (1)      NULL,
    [FL_PSYCHIATRIC_HOSPITALIZATION_HISTORY]   CHAR (1)      NULL,
    [FL_RELATIVE_CAREGIVER]                    CHAR (1)      NULL,
    [FL_REQUIRES_MEDICATION]                   CHAR (1)      NULL,
    [FL_REQUIRES_SPECIAL_DIET]                 CHAR (1)      NULL,
    [FL_RESIDENTIAL_TREATMENT_HISTORY]         CHAR (1)      NULL,
    [FL_RUNAWAY_HISTORY]                       CHAR (1)      NULL,
    [FL_SELF_ABUSIVE]                          CHAR (1)      NULL,
    [FL_SEXUALLY_ABUSED]                       CHAR (1)      NULL,
    [FL_SEXUALLY_ACTIVE]                       CHAR (1)      NULL,
    [FL_SEXUALLY_AGGRESSIVE_YOUTH]             CHAR (1)      NULL,
    [FL_SEXUALLY_AGGRESSIVE_YOUTH_SAY]         CHAR (1)      NULL,
    [FL_SEXUALLY_REACTIVE]                     CHAR (1)      NULL,
    [FL_SIBLING_GROUP]                         CHAR (1)      NULL,
    [FL_SIGNIFICANT_ASTHMA_OR_ALLERGIES]       CHAR (1)      NULL,
    [FL_SPECIAL_NEEDS_CHILDREN]                CHAR (1)      NULL,
    [FL_SPECIALIZED_MEDICAL_CERTIFICATION]     CHAR (1)      NULL,
    [FL_SUICIDAL_THREAT_ATTEMPT]               CHAR (1)      NULL,
    [FL_TREATMENT_FOSTER_HOME_TRAINING]        CHAR (1)      NULL,
    [FL_TUTORING]                              CHAR (1)      NULL,
    [FL_VISUALLY_IMPAIRED]                     CHAR (1)      NULL,
    [FL_WEEKEND_CARE]                          CHAR (1)      NULL,
    [DT_ADDR_LAST_VERIFIED]                    DATETIME      NULL,
    [DT_IVE_TRIBAL_AGREEMENT_EFFECTIVE]        DATETIME      NULL,
    [DT_ROW_BEGIN]                             DATETIME      NULL,
    [DT_ROW_END]                               DATETIME      NULL,
    [ID_CYCLE]                                 INT           NULL,
    [IS_CURRENT]                               INT           NULL,
    [CD_MAIL_COUNTY]                           INT           NULL,
    [CD_PHYS_COUNTY]                           INT           NULL,
    [phys_zip_5]                               VARCHAR (5)   NULL,
    CONSTRAINT [PK_ID_PROVIDER_DIM] PRIMARY KEY CLUSTERED ([ID_PROVIDER_DIM] ASC),
    CONSTRAINT [fk_PROVIDER_DIM_ID_CALENDAR_DIM_CREATED] FOREIGN KEY ([ID_CALENDAR_DIM_CREATED]) REFERENCES [dbo].[CALENDAR_DIM] ([ID_CALENDAR_DIM])
);


GO
CREATE NONCLUSTERED INDEX [idx_ID_PRVD_ORG]
    ON [dbo].[PROVIDER_DIM]([ID_PRVD_ORG] ASC, [DT_ROW_BEGIN] ASC, [DT_ROW_END] ASC);
