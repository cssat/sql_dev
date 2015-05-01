﻿CREATE TABLE [ospi].[WCAP2011_all_RID_Final_no_grphdr_no_raw] (
    [ResearchID]                           VARCHAR (7)  NULL,
    [SchoolYear]                           VARCHAR (9)  NULL,
    [DistrictCode]                         VARCHAR (5)  NULL,
    [SchoolCode]                           VARCHAR (4)  NULL,
    [DistrictName]                         VARCHAR (19) NULL,
    [SchoolName]                           VARCHAR (20) NULL,
    [SchoolType]                           VARCHAR (1)  NULL,
    [StudentGender]                        VARCHAR (1)  NULL,
    [HomeBasedSchool]                      VARCHAR (1)  NULL,
    [PrivateSchool]                        VARCHAR (1)  NULL,
    [ReportingGrade]                       VARCHAR (2)  NULL,
    [ReadingGrade]                         VARCHAR (2)  NULL,
    [WritingGrade]                         VARCHAR (2)  NULL,
    [MathGrade]                            VARCHAR (2)  NULL,
    [ScienceGrade]                         VARCHAR (2)  NULL,
    [StatisticalSampleCycleNumber]         VARCHAR (1)  NULL,
    [ReadingAccomBraille]                  VARCHAR (1)  NULL,
    [ReadingAccomLgPrint]                  VARCHAR (1)  NULL,
    [ReadingAmericanSignLanguage]          VARCHAR (1)  NULL,
    [ReadingSigningExactEnglish]           VARCHAR (1)  NULL,
    [ReadingAccomCDorReader]               VARCHAR (1)  NULL,
    [ReadingAccomScribe]                   VARCHAR (1)  NULL,
    [ReadingAccomTextToSpeech]             VARCHAR (1)  NULL,
    [ReadingAccomWordPrediction]           VARCHAR (1)  NULL,
    [ReadingAccomSpeechToText]             VARCHAR (1)  NULL,
    [ReadingAccomLowVisionDevices]         VARCHAR (1)  NULL,
    [ReadingAccomExtraTime]                VARCHAR (1)  NULL,
    [ReadingAccomGrammarDevices]           VARCHAR (1)  NULL,
    [ReadingIrregIndividual]               VARCHAR (1)  NULL,
    [ReadingIrregGroup]                    VARCHAR (1)  NULL,
    [ReadingIrregMakeup]                   VARCHAR (1)  NULL,
    [ReadingHomeBased]                     VARCHAR (1)  NULL,
    [ReadingPrivateSchool]                 VARCHAR (1)  NULL,
    [ReadingDemoNNEP]                      VARCHAR (1)  NULL,
    [ReadingDemoAbsentEx]                  VARCHAR (1)  NULL,
    [ReadingDemoAbsentUnex]                VARCHAR (1)  NULL,
    [ReadingDemoRefusal]                   VARCHAR (1)  NULL,
    [ReadingDemoPP]                        VARCHAR (1)  NULL,
    [ReadingDemoBasic]                     VARCHAR (1)  NULL,
    [ReadingDemoInvalid]                   VARCHAR (1)  NULL,
    [ReadingDistrictCode]                  VARCHAR (5)  NULL,
    [ReadingSchoolCode]                    VARCHAR (4)  NULL,
    [ReadingDemographicSource]             VARCHAR (1)  NULL,
    [ReadingTestOnline]                    VARCHAR (1)  NULL,
    [WritingAccomBraille]                  VARCHAR (1)  NULL,
    [WritingAccomLgPrint]                  VARCHAR (1)  NULL,
    [WritingAmericanSignLanguage]          VARCHAR (1)  NULL,
    [WritingSigningExactEnglish]           VARCHAR (1)  NULL,
    [WritingAccomCDorReader]               VARCHAR (1)  NULL,
    [WritingAccomScribe]                   VARCHAR (1)  NULL,
    [WritingAccomTextToSpeech]             VARCHAR (1)  NULL,
    [WritingAccomWordPrediction]           VARCHAR (1)  NULL,
    [WritingAccomSpeechtoText]             VARCHAR (1)  NULL,
    [WritingAccomLowVisionDevices]         VARCHAR (1)  NULL,
    [WritingAccomExtraTime]                VARCHAR (1)  NULL,
    [WritingAccomDictionaryThesaurus]      VARCHAR (1)  NULL,
    [WritingIrregIndividual]               VARCHAR (1)  NULL,
    [WritingIrregGroup]                    VARCHAR (1)  NULL,
    [WritingIrregMakeup]                   VARCHAR (1)  NULL,
    [WritingHomeBased]                     VARCHAR (1)  NULL,
    [WritingPrivateSchool]                 VARCHAR (1)  NULL,
    [WritingDemoNNEP]                      VARCHAR (1)  NULL,
    [WritingDemoAbsentEx]                  VARCHAR (1)  NULL,
    [WritingDemoAbsentUnex]                VARCHAR (1)  NULL,
    [WritingDemoRefusal]                   VARCHAR (1)  NULL,
    [WritingDemoPP]                        VARCHAR (1)  NULL,
    [WritingDemoBasic]                     VARCHAR (1)  NULL,
    [WritingDemoInvalid]                   VARCHAR (1)  NULL,
    [WritingDistrictCode]                  VARCHAR (5)  NULL,
    [WritingSchoolCode]                    VARCHAR (4)  NULL,
    [WritingDemographicSource]             VARCHAR (1)  NULL,
    [WritingTestOnline]                    VARCHAR (1)  NULL,
    [Writing2AccomBraille]                 VARCHAR (1)  NULL,
    [Writing2AccomLgPrint]                 VARCHAR (1)  NULL,
    [Writing2AmericanSignLanguage]         VARCHAR (1)  NULL,
    [Writing2SigningExactEnglish]          VARCHAR (1)  NULL,
    [Writing2AccomCDorReader]              VARCHAR (1)  NULL,
    [Writing2AccomScribe]                  VARCHAR (1)  NULL,
    [Writing2AccomTextToSpeech]            VARCHAR (1)  NULL,
    [Writing2AccomWordPrediction]          VARCHAR (1)  NULL,
    [Writing2AccomSpeechtoText]            VARCHAR (1)  NULL,
    [Writing2AccomLowVisionDevices]        VARCHAR (1)  NULL,
    [Writing2AccomExtraTime]               VARCHAR (1)  NULL,
    [Writing2AccomDictionaryThesaurus]     VARCHAR (1)  NULL,
    [Writing2HomeBased]                    VARCHAR (1)  NULL,
    [Writing2PrivateSchool]                VARCHAR (1)  NULL,
    [Writing2DemoNNEP]                     VARCHAR (1)  NULL,
    [Writing2DemoAbsentEx]                 VARCHAR (1)  NULL,
    [Writing2DemoAbsentUnex]               VARCHAR (1)  NULL,
    [Writing2DemoRefusal]                  VARCHAR (1)  NULL,
    [Writing2DemoPP]                       VARCHAR (1)  NULL,
    [Writing2DemoBasic]                    VARCHAR (1)  NULL,
    [Writing2DemoInvalid]                  VARCHAR (1)  NULL,
    [Writing2DistrictCode]                 VARCHAR (1)  NULL,
    [Writing2SchoolCode]                   VARCHAR (1)  NULL,
    [Writing2DemographicSource]            VARCHAR (1)  NULL,
    [Writing2TestOnline]                   VARCHAR (1)  NULL,
    [MathAccomBraille]                     VARCHAR (1)  NULL,
    [MathAccomLgPrint]                     VARCHAR (1)  NULL,
    [MathAmericanSignLanguage]             VARCHAR (1)  NULL,
    [MathSignExactEnglish]                 VARCHAR (1)  NULL,
    [MathAccomCDorReader]                  VARCHAR (1)  NULL,
    [MathAccomScribe]                      VARCHAR (1)  NULL,
    [MathAccomTextToSpeech]                VARCHAR (1)  NULL,
    [MathAccomWordPrediction]              VARCHAR (1)  NULL,
    [MathAccomSpeechtoText]                VARCHAR (1)  NULL,
    [MathAccomLowVisionDevices]            VARCHAR (1)  NULL,
    [MathAccomExtraTime]                   VARCHAR (1)  NULL,
    [MathAccomGrammarDevices]              VARCHAR (1)  NULL,
    [MathAccomTranslatedCD]                VARCHAR (1)  NULL,
    [MathIrregIndividual]                  VARCHAR (1)  NULL,
    [MathIrregGroup]                       VARCHAR (1)  NULL,
    [MathIrregMakeup]                      VARCHAR (1)  NULL,
    [MathHomeBased]                        VARCHAR (1)  NULL,
    [MathPrivateSchool]                    VARCHAR (1)  NULL,
    [MathDemoNNEP]                         VARCHAR (1)  NULL,
    [MathDemoAbsentEx]                     VARCHAR (1)  NULL,
    [MathDemoAbsentUnex]                   VARCHAR (1)  NULL,
    [MathDemoRefusal]                      VARCHAR (1)  NULL,
    [MathDemoPP]                           VARCHAR (1)  NULL,
    [MathDemoBasic]                        VARCHAR (1)  NULL,
    [MathDemoInvalid]                      VARCHAR (1)  NULL,
    [MathDistrictCode]                     VARCHAR (5)  NULL,
    [MathSchoolCode]                       VARCHAR (4)  NULL,
    [MathDemographicSource]                VARCHAR (1)  NULL,
    [MathTestOnline]                       VARCHAR (1)  NULL,
    [ScienceAccomBraille]                  VARCHAR (1)  NULL,
    [ScienceAccomLgPrint]                  VARCHAR (1)  NULL,
    [ScienceAmericanSignLanguage]          VARCHAR (1)  NULL,
    [ScienceSignExactEnglish]              VARCHAR (1)  NULL,
    [ScienceAccomCDorReader]               VARCHAR (1)  NULL,
    [ScienceAccomScribe]                   VARCHAR (1)  NULL,
    [ScienceAccomTextToSpeech]             VARCHAR (1)  NULL,
    [ScienceAccomWordPrediction]           VARCHAR (1)  NULL,
    [ScienceAccomSpeechtoText]             VARCHAR (1)  NULL,
    [ScienceAccomLowVisionDevices]         VARCHAR (1)  NULL,
    [ScienceAccomExtraTime]                VARCHAR (1)  NULL,
    [ScienceAccomGrammarDevices]           VARCHAR (1)  NULL,
    [ScienceAccomTranslatedCD]             VARCHAR (1)  NULL,
    [ScienceIrregIndividual]               VARCHAR (1)  NULL,
    [ScienceIrregGroup]                    VARCHAR (1)  NULL,
    [ScienceIrregMakeup]                   VARCHAR (1)  NULL,
    [ScienceHomeBased]                     VARCHAR (1)  NULL,
    [SciencePrivateSchool]                 VARCHAR (1)  NULL,
    [ScienceDemoNNEP]                      VARCHAR (1)  NULL,
    [ScienceDemoAbsentEx]                  VARCHAR (1)  NULL,
    [scienceDemoAbsentUnex]                VARCHAR (1)  NULL,
    [ScienceDemoRefusal]                   VARCHAR (1)  NULL,
    [ScienceDemoPP]                        VARCHAR (1)  NULL,
    [ScienceDemoBasic]                     VARCHAR (1)  NULL,
    [ScienceDemoInvalid]                   VARCHAR (1)  NULL,
    [ScienceDistrictCode]                  VARCHAR (5)  NULL,
    [ScienceSchoolCode]                    VARCHAR (4)  NULL,
    [ScienceDemographicSource]             VARCHAR (1)  NULL,
    [ScienceTestOnline]                    VARCHAR (1)  NULL,
    [ReadingTotalRaw]                      VARCHAR (2)  NULL,
    [ReadingScaleScore]                    VARCHAR (3)  NULL,
    [ReadingAttempt]                       VARCHAR (2)  NULL,
    [ReadingTestType]                      VARCHAR (4)  NULL,
    [ReadingLevel]                         VARCHAR (2)  NULL,
    [ReadingMetStandard]                   VARCHAR (3)  NULL,
    [WritingTotalRaw]                      VARCHAR (2)  NULL,
    [WritingScaleScore]                    VARCHAR (3)  NULL,
    [WritingAttempt]                       VARCHAR (2)  NULL,
    [WritingTestType]                      VARCHAR (4)  NULL,
    [WritingLevel]                         VARCHAR (2)  NULL,
    [WritingMetStandard]                   VARCHAR (3)  NULL,
    [MathTotalRaw]                         VARCHAR (2)  NULL,
    [MathScaleScore]                       VARCHAR (3)  NULL,
    [MathAttempt]                          VARCHAR (2)  NULL,
    [MathTestType]                         VARCHAR (4)  NULL,
    [MathLevel]                            VARCHAR (2)  NULL,
    [MathMetStandard]                      VARCHAR (3)  NULL,
    [ScienceTotalRaw]                      VARCHAR (2)  NULL,
    [ScienceScaleScore]                    VARCHAR (3)  NULL,
    [ScienceAttempt]                       VARCHAR (2)  NULL,
    [ScienceTestType]                      VARCHAR (4)  NULL,
    [ScienceLevel]                         VARCHAR (2)  NULL,
    [ScienceMetStandard]                   VARCHAR (3)  NULL,
    [ReadingResolvedRaw]                   VARCHAR (2)  NULL,
    [ReadingResolvedScaleScore]            VARCHAR (3)  NULL,
    [ReadingResolvedAttempt]               VARCHAR (2)  NULL,
    [ReadingResolvedTestType]              VARCHAR (4)  NULL,
    [ReadingResolvedLevel]                 VARCHAR (2)  NULL,
    [ReadingResolvedMetStandard]           VARCHAR (3)  NULL,
    [WritingResolvedRaw]                   VARCHAR (2)  NULL,
    [WritingResolvedScaleScore]            VARCHAR (3)  NULL,
    [WritingResolvedAttempt]               VARCHAR (2)  NULL,
    [WritingResolvedTestType]              VARCHAR (4)  NULL,
    [WritingResolvedLevel]                 VARCHAR (2)  NULL,
    [WritingResolvedMetStandard]           VARCHAR (3)  NULL,
    [MathResolvedRaw]                      VARCHAR (2)  NULL,
    [MathResolvedScaleScore]               VARCHAR (3)  NULL,
    [MathResolvedAttempt]                  VARCHAR (2)  NULL,
    [MathResolvedTestType]                 VARCHAR (4)  NULL,
    [MathResolvedLevel]                    VARCHAR (2)  NULL,
    [MathResolvedMetStandard]              VARCHAR (3)  NULL,
    [ScienceResolvedRaw]                   VARCHAR (2)  NULL,
    [ScienceResolvedScaleScore]            VARCHAR (3)  NULL,
    [ScienceResolvedAttempt]               VARCHAR (2)  NULL,
    [ScienceResolvedTestType]              VARCHAR (4)  NULL,
    [ScienceResolvedLevel]                 VARCHAR (2)  NULL,
    [ScienceResolvedMetStandard]           VARCHAR (3)  NULL,
    [ReadingComprehensionMet]              VARCHAR (1)  NULL,
    [ReadingAnalysisMet]                   VARCHAR (1)  NULL,
    [ReadingCriticalThinkMet]              VARCHAR (1)  NULL,
    [ReadingLIteraryTextMet]               VARCHAR (1)  NULL,
    [ReadingInfoTextMet]                   VARCHAR (1)  NULL,
    [WritingCOSMet]                        VARCHAR (1)  NULL,
    [WritingConvMet]                       VARCHAR (1)  NULL,
    [MathNumberAlgebraicSenseMet]          VARCHAR (1)  NULL,
    [MathMeasureGeoSenseStatMet]           VARCHAR (1)  NULL,
    [MathProbSolveReasoningMet]            VARCHAR (1)  NULL,
    [MathProceduresConceptsMet]            VARCHAR (1)  NULL,
    [MathMeasureGeoSenseProbStatMet]       VARCHAR (1)  NULL,
    [MathMeasureGeoSenseMet]               VARCHAR (1)  NULL,
    [MathProbStatMet]                      VARCHAR (1)  NULL,
    [ScienceSystemsMet]                    VARCHAR (1)  NULL,
    [ScienceInquiryMet]                    VARCHAR (1)  NULL,
    [ScienceApplicationMet]                VARCHAR (1)  NULL,
    [ScienceDomainsMet]                    VARCHAR (1)  NULL,
    [WritingNarrativeMET]                  VARCHAR (1)  NULL,
    [WritingExpositoryMET]                 VARCHAR (1)  NULL,
    [WritingPersuasiveMET]                 VARCHAR (1)  NULL,
    [AYPReadCESchool]                      VARCHAR (1)  NULL,
    [AYPMathCESchool]                      VARCHAR (1)  NULL,
    [AYPPortCESchool]                      VARCHAR (1)  NULL,
    [AYPReadCEDistrict]                    VARCHAR (1)  NULL,
    [AYPMathCEDistrict]                    VARCHAR (1)  NULL,
    [AYPPortCEDistrict]                    VARCHAR (1)  NULL,
    [AccomResolvedReading]                 VARCHAR (1)  NULL,
    [AccomResolvedWriting]                 VARCHAR (1)  NULL,
    [AccomResolvedMath]                    VARCHAR (1)  NULL,
    [AccomResolvedScience]                 VARCHAR (1)  NULL,
    [CEDARS_DistrictCode]                  VARCHAR (5)  NULL,
    [CEDARS_Gender]                        VARCHAR (1)  NULL,
    [CEDARS_Language]                      VARCHAR (3)  NULL,
    [CEDARS_RaceEthnicityFedRollup]        VARCHAR (1)  NULL,
    [CEDARS_EthnicityCode1]                VARCHAR (2)  NULL,
    [CEDARS_EthnicityCode2]                VARCHAR (1)  NULL,
    [CEDARS_EthnicityCode3]                VARCHAR (1)  NULL,
    [MultipleEthnicityCodeFlag]            VARCHAR (1)  NULL,
    [CEDARS_RaceCode1]                     VARCHAR (3)  NULL,
    [CEDARS_RaceCode2]                     VARCHAR (3)  NULL,
    [CEDARS_RaceCode3]                     VARCHAR (1)  NULL,
    [MultipleRaceCodeFlag]                 VARCHAR (2)  NULL,
    [CEDARS_GradReqmtYear]                 VARCHAR (4)  NULL,
    [CEDARS_504]                           VARCHAR (1)  NULL,
    [FosterCare]                           VARCHAR (1)  NULL,
    [CEDARS_ExpectedGradYear]              VARCHAR (4)  NULL,
    [CEDARS_LAPReading]                    VARCHAR (1)  NULL,
    [CEDARS_LAPMath]                       VARCHAR (1)  NULL,
    [CEDARS_TASReading]                    VARCHAR (1)  NULL,
    [CEDARS_TASMath]                       VARCHAR (1)  NULL,
    [CEDARS_Migrant]                       VARCHAR (1)  NULL,
    [CEDARS_Homeless]                      VARCHAR (1)  NULL,
    [CEDARS_Gifted]                        VARCHAR (1)  NULL,
    [CEDARS_EllBilingual]                  VARCHAR (1)  NULL,
    [CEDARS_FREligibility]                 VARCHAR (1)  NULL,
    [CEDARS_F1VisaStudent]                 VARCHAR (1)  NULL,
    [CEDARS_SpecialEd]                     VARCHAR (1)  NULL,
    [CEDARS_TitleIII_Immigrant]            VARCHAR (1)  NULL,
    [CEDARS_TitleIII_NativeAmerican]       VARCHAR (1)  NULL,
    [CEDARS_Title1_TargetAssistSocStudies] VARCHAR (1)  NULL,
    [CEDARS_Title1_TargetAssistScience]    VARCHAR (1)  NULL,
    [CEDARS_Title1_TargetAssistLangArts]   VARCHAR (1)  NULL,
    [CEDARS_LAP_TargetAssistLangArts]      VARCHAR (1)  NULL,
    [CEDARS_Grant21stCentury]              VARCHAR (1)  NULL,
    [CEDARS_EarlyEducation]                VARCHAR (1)  NULL,
    [CEDARS_OutsideServices]               VARCHAR (1)  NULL,
    [CEDARS_SchoolChoice]                  VARCHAR (1)  NULL,
    [ReadingMedical]                       VARCHAR (1)  NULL,
    [WritingMedical]                       VARCHAR (1)  NULL,
    [MathMedical]                          VARCHAR (1)  NULL,
    [ScienceMedical]                       VARCHAR (1)  NULL,
    [CEDARS_SchoolCode]                    VARCHAR (4)  NULL,
    [CEDARS_PrimarySchool]                 VARCHAR (1)  NULL,
    [CEDARS_WithdrawCode]                  VARCHAR (2)  NULL,
    [CEDARS_DateEnrolledInDistrict]        VARCHAR (10) NULL,
    [CEDARS_DateExitedFromDistrict]        VARCHAR (10) NULL,
    [CEDARS_DateEnrolledInSchool]          VARCHAR (10) NULL,
    [CEDARS_DateExitedFromSchool]          VARCHAR (10) NULL,
    [ELLProgramEnroll]                     VARCHAR (10) NULL,
    [ELLProgramExit]                       VARCHAR (1)  NULL,
    [HighSchoolReadingEnrolled]            VARCHAR (1)  NULL,
    [HighSchoolWritingEnrolled]            VARCHAR (1)  NULL,
    [EOCMathEnrolled]                      VARCHAR (1)  NULL,
    [HighSchoolScienceEnrolled]            VARCHAR (1)  NULL,
    [Grade38PaperEnrolled]                 VARCHAR (1)  NULL,
    [Grade38OnlineEnrolled]                VARCHAR (1)  NULL,
    [CEDARS_DisabilityCode]                VARCHAR (2)  NULL,
    [ReadingPPTestType]                    VARCHAR (4)  NULL,
    [WritingPPTestType]                    VARCHAR (4)  NULL,
    [MathematicsPPTestType]                VARCHAR (1)  NULL,
    [SciencePPTestType]                    VARCHAR (1)  NULL,
    [ReadingPPLevel]                       VARCHAR (1)  NULL,
    [WritingPPLevel]                       VARCHAR (1)  NULL,
    [MathPPLevel]                          VARCHAR (1)  NULL,
    [SciencePPLevel]                       VARCHAR (1)  NULL,
    [NotEnrolled12thGradeRetester]         VARCHAR (1)  NULL,
    [WAASPortfolio_BinderGrade]            VARCHAR (1)  NULL,
    [WAASPortfolio_ScoreGrade]             VARCHAR (1)  NULL,
    [WAASPortfolioReadingAttempt]          VARCHAR (1)  NULL,
    [WAASPortfolioReadingTotal]            VARCHAR (1)  NULL,
    [WAASPortfolioReadingLevel]            VARCHAR (1)  NULL,
    [WAASPortfolioReadingStandard]         VARCHAR (1)  NULL,
    [WAASPortfolioWritingAttempt]          VARCHAR (1)  NULL,
    [WAASPortfolioWritingTotal]            VARCHAR (1)  NULL,
    [WAASPortfolioWritingLevel]            VARCHAR (1)  NULL,
    [WAASPortfolioWritingStandard]         VARCHAR (1)  NULL,
    [WAASPortfolioMathAttempt]             VARCHAR (1)  NULL,
    [WAASPortfolioMathTotal]               VARCHAR (1)  NULL,
    [WAASPortfolioMathLevel]               VARCHAR (1)  NULL,
    [WAASPortfolioMathStandard]            VARCHAR (1)  NULL,
    [WAASPortfolioScienceAttempt]          VARCHAR (1)  NULL,
    [WAASPortfolioScienceTotal]            VARCHAR (1)  NULL,
    [WAASPortfolioScienceLevel]            VARCHAR (1)  NULL,
    [WAASPortfolioScienceStandard]         VARCHAR (1)  NULL,
    [EOCMath1TestFlag]                     VARCHAR (2)  NULL,
    [EOCMath1AccomBraille]                 VARCHAR (1)  NULL,
    [EOCMath1AccomLgPrint]                 VARCHAR (1)  NULL,
    [EOCMath1AmericanSignLanguage]         VARCHAR (1)  NULL,
    [EOCMath1SignExactEnglish]             VARCHAR (1)  NULL,
    [EOCMath1AccomCDorReader]              VARCHAR (1)  NULL,
    [EOCMath1AccomScribe]                  VARCHAR (1)  NULL,
    [EOCMath1AccomTextToSpeech]            VARCHAR (1)  NULL,
    [EOCMath1AccomWordPrediction]          VARCHAR (1)  NULL,
    [EOCMath1AccomSpeechtoText]            VARCHAR (1)  NULL,
    [EOCMath1AccomLowVisionDevices]        VARCHAR (1)  NULL,
    [EOCMath1AccomExtraTime]               VARCHAR (1)  NULL,
    [EOCMath1AccomGrammarDevices]          VARCHAR (1)  NULL,
    [EOCMath1AccomTranslatedCD]            VARCHAR (1)  NULL,
    [EOCMath1IrregIndividual]              VARCHAR (1)  NULL,
    [EOCMath1IrregGroup]                   VARCHAR (1)  NULL,
    [EOCMath1IrregMakeup]                  VARCHAR (1)  NULL,
    [EOCMath1HomeBased]                    VARCHAR (1)  NULL,
    [EOCMath1PrivateSchool]                VARCHAR (1)  NULL,
    [EOCMath1DemoNNEP]                     VARCHAR (1)  NULL,
    [EOCMath1DemoAbsentEx]                 VARCHAR (1)  NULL,
    [EOCMath1DemoAbsentUnex]               VARCHAR (1)  NULL,
    [EOCMath1DemoRefusal]                  VARCHAR (1)  NULL,
    [EOCMath1DemoPP]                       VARCHAR (1)  NULL,
    [EOCMath1DemoBasic]                    VARCHAR (1)  NULL,
    [EOCMath1DemoInvalid]                  VARCHAR (1)  NULL,
    [EOCMath1DistrictCode]                 VARCHAR (5)  NULL,
    [EOCMath1SchoolCode]                   VARCHAR (4)  NULL,
    [EOCMath1DemographicSource]            VARCHAR (1)  NULL,
    [EOCMath1TestOnline]                   VARCHAR (1)  NULL,
    [EOCMath1TotalRaw]                     VARCHAR (2)  NULL,
    [EOCMath1ScaleScore]                   VARCHAR (3)  NULL,
    [EOCMath1Attempt]                      VARCHAR (2)  NULL,
    [EOCMath1TestType]                     VARCHAR (3)  NULL,
    [EOCMath1Level]                        VARCHAR (2)  NULL,
    [EOCMath1MetStandard]                  VARCHAR (3)  NULL,
    [EOCMath1_NOEVMet]                     VARCHAR (1)  NULL,
    [EOCMath1_LEIMet]                      VARCHAR (1)  NULL,
    [EOCMath1_BLNFMet]                     VARCHAR (1)  NULL,
    [EOCMath1_DSMet]                       VARCHAR (1)  NULL,
    [EOCMath1_CSCMet]                      VARCHAR (1)  NULL,
    [AYPEOCMathCESchool]                   VARCHAR (1)  NULL,
    [AYPEOCMathCEDistrict]                 VARCHAR (1)  NULL,
    [AccomResolvedEOCMath1]                VARCHAR (1)  NULL,
    [EOCMath1Medical]                      VARCHAR (1)  NULL,
    [EOCMath1PPTestType]                   VARCHAR (1)  NULL,
    [EOCMath1PPLevel]                      VARCHAR (1)  NULL,
    [EOCMath2TestFlag]                     VARCHAR (2)  NULL,
    [EOCMath2AccomBraille]                 VARCHAR (1)  NULL,
    [EOCMath2AccomLgPrint]                 VARCHAR (1)  NULL,
    [EOCMath2AmericanSignLanguage]         VARCHAR (1)  NULL,
    [EOCMath2SignExactEnglish]             VARCHAR (1)  NULL,
    [EOCMath2AccomCDorReader]              VARCHAR (1)  NULL,
    [EOCMath2AccomScribe]                  VARCHAR (1)  NULL,
    [EOCMath2AccomTextToSpeech]            VARCHAR (1)  NULL,
    [EOCMath2AccomWordPrediction]          VARCHAR (1)  NULL,
    [EOCMath2AccomSpeechtoText]            VARCHAR (1)  NULL,
    [EOCMath2AccomLowVisionDevices]        VARCHAR (1)  NULL,
    [EOCMath2AccomExtraTime]               VARCHAR (1)  NULL,
    [EOCMath2AccomGrammarDevices]          VARCHAR (1)  NULL,
    [EOCMath2AccomTranslatedCD]            VARCHAR (1)  NULL,
    [EOCMath2IrregIndividual]              VARCHAR (1)  NULL,
    [EOCMath2IrregGroup]                   VARCHAR (1)  NULL,
    [EOCMath2IrregMakeup]                  VARCHAR (1)  NULL,
    [EOCMath2HomeBased]                    VARCHAR (1)  NULL,
    [EOCMath2PrivateSchool]                VARCHAR (1)  NULL,
    [EOCMath2DemoNNEP]                     VARCHAR (1)  NULL,
    [EOCMath2DemoAbsentEx]                 VARCHAR (1)  NULL,
    [EOCMath2DemoAbsentUnex]               VARCHAR (1)  NULL,
    [EOCMath2DemoRefusal]                  VARCHAR (1)  NULL,
    [EOCMath2DemoPP]                       VARCHAR (1)  NULL,
    [EOCMath2DemoBasic]                    VARCHAR (1)  NULL,
    [EOCMath2DemoInvalid]                  VARCHAR (1)  NULL,
    [EOCMath2DistrictCode]                 VARCHAR (5)  NULL,
    [EOCMath2SchoolCode]                   VARCHAR (4)  NULL,
    [EOCMath2DemographicSource]            VARCHAR (1)  NULL,
    [EOCMath2TestOnline]                   VARCHAR (1)  NULL,
    [EOCMath2TotalRaw]                     VARCHAR (2)  NULL,
    [EOCMath2ScaleScore]                   VARCHAR (3)  NULL,
    [EOCMath2Attempt]                      VARCHAR (2)  NULL,
    [EOCMath2TestType]                     VARCHAR (3)  NULL,
    [EOCMath2Level]                        VARCHAR (2)  NULL,
    [EOCMath2MetStandard]                  VARCHAR (3)  NULL,
    [EOCMath2_LAPMet]                      VARCHAR (1)  NULL,
    [EOCMath2_PAPFMet]                     VARCHAR (1)  NULL,
    [EOCMath2_FCPMMet]                     VARCHAR (1)  NULL,
    [EOCMath2_CSCMet]                      VARCHAR (1)  NULL,
    [AccomResolvedEOCMath2]                VARCHAR (1)  NULL,
    [EOCMath2Medical]                      VARCHAR (1)  NULL,
    [EOCMath2PPTestType]                   VARCHAR (1)  NULL,
    [EOCMath2PPLevel]                      VARCHAR (1)  NULL
);

