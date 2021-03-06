﻿CREATE TABLE [ospi].[ospi_0910] (
    [researchID]                            VARCHAR (7)  NOT NULL,
    [SchoolYear]                            FLOAT (53)   NULL,
    [DistrictCode]                          INT          NOT NULL,
    [ResidentDistrictCode]                  INT          NOT NULL,
    [SchoolCode]                            INT          NOT NULL,
    [LocationID]                            VARCHAR (4)  NULL,
    [PrimarySchoolFlag]                     VARCHAR (1)  NULL,
    [MonthYearOfBirth]                      VARCHAR (7)  NULL,
    [Gender]                                VARCHAR (1)  NULL,
    [GradeLevel]                            VARCHAR (2)  NULL,
    [DateEnrolledinDistrict]                DATETIME     NOT NULL,
    [DateExitedDistrict]                    DATETIME     NULL,
    [DateEnrolledinSchool]                  DATETIME     NOT NULL,
    [DateExitedSchool]                      DATETIME     NULL,
    [WithdrawalCode]                        VARCHAR (2)  NULL,
    [WithdrawalType]                        VARCHAR (80) NULL,
    [BirthCountryCode]                      VARCHAR (3)  NULL,
    [BirthCountry]                          VARCHAR (78) NULL,
    [ZipCode]                               VARCHAR (10) NULL,
    [FederalEthRaceRollupCode]              FLOAT (53)   NULL,
    [FederalEthRaceRollupName]              VARCHAR (38) NULL,
    [PrimaryLanguageCode]                   FLOAT (53)   NULL,
    [PrimaryLanguage]                       VARCHAR (22) NULL,
    [LanguageSpokenatHomeCode]              FLOAT (53)   NULL,
    [LanguageSpokenatHome]                  VARCHAR (22) NULL,
    [GradReqYear]                           FLOAT (53)   NULL,
    [ExpectedGradYear]                      FLOAT (53)   NULL,
    [CumulativeGPA]                         FLOAT (53)   NULL,
    [CumulativeCreditsAttempted]            FLOAT (53)   NULL,
    [CumulativeCreditsEarned]               FLOAT (53)   NULL,
    [NumDaysPresent]                        FLOAT (53)   NULL,
    [NumUnexcusedAbsences]                  FLOAT (53)   NULL,
    [DisabilityFlag]                        VARCHAR (1)  NULL,
    [ApprvdPrivateSchoolAttendPartTimeFlag] VARCHAR (1)  NULL,
    [HomeBasedAttendPartTimeFlag]           VARCHAR (1)  NULL,
    [F1VisaForeignExchgFlag]                VARCHAR (1)  NULL,
    [FreeReducedLunchFlag]                  VARCHAR (1)  NULL,
    [HomelessFlag]                          VARCHAR (1)  NULL,
    [FosterCareFlag]                        VARCHAR (1)  NULL,
    [v504Flag]                              VARCHAR (1)  NULL,
    [GiftedFlag]                            VARCHAR (1)  NULL,
    [MigrantFlag]                           VARCHAR (1)  NULL,
    [BilingualFlag]                         VARCHAR (1)  NULL,
    [SpecialEdFlag]                         VARCHAR (1)  NULL,
    [SubmitDate]                            VARCHAR (10) NULL,
    [ExtractDate]                           DATETIME     NULL,
    [int_ResearchID]                        INT          DEFAULT ((0)) NOT NULL,
    [EnrollmentStatus]                      CHAR (2)     NOT NULL,
    [row_num_desc]                          INT          NULL,
    [row_num_asc]                           INT          NULL,
    CONSTRAINT [pk_CEDARS2010_StndEnr_RID_asOf20120326] PRIMARY KEY CLUSTERED ([int_ResearchID] ASC, [DistrictCode] ASC, [SchoolCode] ASC, [DateEnrolledinSchool] ASC)
);

