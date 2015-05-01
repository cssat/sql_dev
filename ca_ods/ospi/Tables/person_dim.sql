CREATE TABLE [ospi].[person_dim] (
    [researchID]        VARCHAR (10) NULL,
    [int_researchID]    INT          NOT NULL,
    [dob_yrmonth_date]  DATETIME     NULL,
    [dob_yrmonth]       INT          NULL,
    [Gender]            CHAR (10)    NULL,
    [FederalEthRaceID]  INT          NULL,
    [PrimaryLanguageID] INT          NULL,
    [HomeLanguageID]    INT          NULL,
    [fl_disability]     INT          NULL,
    [fl_gifted]         INT          NULL,
    [fl_bilingual]      INT          NULL,
    [BirthCountryCode]  VARCHAR (10) NULL,
    PRIMARY KEY CLUSTERED ([int_researchID] ASC)
);

