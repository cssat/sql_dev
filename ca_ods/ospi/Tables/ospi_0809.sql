﻿CREATE TABLE [ospi].[ospi_0809] (
    [int_ResearchID]                                  INT            NOT NULL,
    [dob]                                             VARCHAR (50)   NULL,
    [DistrictCode]                                    INT            NOT NULL,
    [SchoolCode]                                      INT            NOT NULL,
    [ResidentDistrictCode]                            INT            NULL,
    [CollectionPeriodName]                            VARCHAR (50)   NULL,
    [SchoolYear]                                      VARCHAR (50)   NULL,
    [CollectionPeriod]                                INT            NULL,
    [ServingDistrict]                                 INT            NULL,
    [Gender]                                          CHAR (1)       NULL,
    [ZipCode]                                         INT            NULL,
    [ZipCodeExt]                                      INT            NULL,
    [GradeLevel]                                      CHAR (10)      NULL,
    [Language]                                        INT            NULL,
    [RaceEthnicity]                                   INT            NULL,
    [Disability]                                      INT            NULL,
    [GPA]                                             DECIMAL (9, 2) NULL,
    [ExpectedGradYear]                                INT            NULL,
    [ResidentDistrict]                                INT            NULL,
    [LAPReading]                                      SMALLINT       NULL,
    [LAPMath]                                         SMALLINT       NULL,
    [TASReading]                                      SMALLINT       NULL,
    [TASMath]                                         SMALLINT       NULL,
    [Migrant]                                         SMALLINT       NULL,
    [Section504]                                      VARCHAR (10)   NULL,
    [Grant21stCentury]                                SMALLINT       NULL,
    [HomeLess]                                        SMALLINT       NULL,
    [Gifted]                                          SMALLINT       NULL,
    [LEPBilingual]                                    VARCHAR (10)   NULL,
    [FREligibility]                                   VARCHAR (10)   NULL,
    [SpecialEd]                                       VARCHAR (10)   NULL,
    [SpecialEdLREA]                                   VARCHAR (10)   NULL,
    [SpecialEdLREB]                                   VARCHAR (10)   NULL,
    [OutsideServices]                                 VARCHAR (10)   NULL,
    [SchoolChoice]                                    VARCHAR (10)   NULL,
    [HomeLanguage]                                    VARCHAR (10)   NULL,
    [PreSchool]                                       VARCHAR (10)   NULL,
    [ServingSchool]                                   INT            NULL,
    [PrimarySchool]                                   VARCHAR (10)   NULL,
    [EnrollmentStatus]                                CHAR (10)      NULL,
    [DateEnrolledInDistrict]                          DATETIME       NULL,
    [DateExitedFromDistrict]                          DATETIME       NULL,
    [DateEnrolledInSchool]                            DATETIME       NOT NULL,
    [DateExitedFromSchool]                            DATETIME       NULL,
    [VocEdTechPrepComp]                               VARCHAR (10)   NULL,
    [VocEdVocComp]                                    VARCHAR (10)   NULL,
    [VocEdIndustryCertificate]                        VARCHAR (10)   NULL,
    [IsForeignExchangeStudent]                        VARCHAR (10)   NULL,
    [IsHomeBasedStudentAttendingPartTime]             VARCHAR (10)   NULL,
    [IsApprovedPrivateSchoolStudentAttendingPartTime] VARCHAR (10)   NULL,
    [ELLEnrollmentDate]                               DATETIME       NULL,
    [ELLExitDate]                                     DATETIME       NULL,
    [PrimaryFirst]                                    INT            NULL,
    [txt_filename]                                    VARCHAR (500)  NULL,
    [int_filename]                                    INT            NOT NULL,
    [yrmonth]                                         INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([int_ResearchID] ASC, [DistrictCode] ASC, [SchoolCode] ASC, [DateEnrolledInSchool] ASC, [int_filename] ASC, [yrmonth] ASC)
);

