CREATE TABLE [dbo].[EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] (
    [ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] INT           NOT NULL,
    [CD_REASON_NOT_RECEIVED]                    INT           NULL,
    [TX_REASON_NOT_RECEIVED]                    VARCHAR (200) NULL,
    [CD_SCHOOL_DISTRICT]                        INT           NULL,
    [TX_SCHOOL_DISTRICT]                        VARCHAR (200) NULL,
    [CD_REFERRAL_TO]                            INT           NULL,
    [TX_REFERRAL_TO]                            VARCHAR (200) NULL,
    [DT_ROW_BEGIN]                              DATETIME      NULL,
    [DT_ROW_END]                                DATETIME      NULL,
    [ID_CYCLE]                                  INT           NULL,
    [IS_CURRENT]                                INT           NULL,
    CONSTRAINT [PK_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] PRIMARY KEY CLUSTERED ([ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] ASC)
);

