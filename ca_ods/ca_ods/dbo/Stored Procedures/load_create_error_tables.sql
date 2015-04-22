
CREATE procedure [dbo].[load_create_error_tables]
as

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ABUSE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].[zERR_ABUSE_FACT]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ABUSE_TYPE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].[zERR_ABUSE_TYPE_DIM]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ADOPTION_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ADOPTION_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ADOPTION_STATUS_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ADOPTION_STATUS_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_AGREEMENT_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_AGREEMENT_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ALLEGATION_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ALLEGATION_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ASSIGNMENT_ATTRIBUTE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ASSIGNMENT_ATTRIBUTE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ASSIGNMENT_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ASSIGNMENT_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_AUTHORIZATION_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_AUTHORIZATION_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_AUTHORIZATION_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_AUTHORIZATION_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CALENDAR_DIM]') AND type in (N'U'))
DROP TABLE [dbo].[zERR_CALENDAR_DIM]

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CASE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_CASE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CASE_NOTE_TYPE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_CASE_NOTE_TYPE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CASE_NOTE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_CASE_NOTE_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CASE_PARTICIPANT_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_CASE_PARTICIPANT_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_CHART_OF_ACCOUNTS_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_CHART_OF_ACCOUNTS_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_DISCHARGE_REASON_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_DISCHARGE_REASON_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_DISPOSITION_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_DISPOSITION_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_DLR_RISK_ASSESSMENT_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_DLR_RISK_ASSESSMENT_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_EDUCATION_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_EDUCATION_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_EDUCATION_PLAN_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_EDUCATION_PLAN_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ELIGIBILITY_REMOVAL_HOME_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ELIGIBILITY_REMOVAL_HOME_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ELIGIBILITY_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ELIGIBILITY_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ELIGIBILITY_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ELIGIBILITY_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ELIG_EPISODE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ELIG_EPISODE_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_ELIGIBILITY_STATUS_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_ELIGIBILITY_STATUS_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_FAMILY_STRUCTURE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_FAMILY_STRUCTURE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_FINDINGS_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_FINDINGS_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_HEALTH_ACTIVITY_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_HEALTH_ACTIVITY_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_HEALTH_ACTIVITY_TYPE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_HEALTH_ACTIVITY_TYPE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_ATTRIBUTE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_ATTRIBUTE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_TYPE_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_TYPE_DIM

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_SERVICE_BRIDGE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_SERVICE_BRIDGE_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_FACT

if OBJECT_ID(N'dbo.zERR_INTAKE_PARTICIPANT_FACT',N'U') is not null drop table dbo.zERR_INTAKE_PARTICIPANT_FACT

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_PARTICIPANT_ROLES_DIM]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_PARTICIPANT_ROLES_DIM


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zERR_INTAKE_VICTIM_FACT]') AND type in (N'U'))
DROP TABLE [dbo].zERR_INTAKE_VICTIM_FACT

IF OBJECT_ID(N'dbo.zERR_INVESTIGATION_ASSESSMENT_FACT',N'U') is not null 
drop table dbo.zERR_INVESTIGATION_ASSESSMENT_FACT  

IF OBJECT_ID(N'dbo.zERR_INVESTIGATION_TYPE_DIM',N'U') is not null 
drop table dbo.zERR_INVESTIGATION_TYPE_DIM  

IF OBJECT_ID(N'dbo.zERR_LEGAL_ACTION_DIM',N'U') is not null 
drop table dbo.zERR_LEGAL_ACTION_DIM  

IF OBJECT_ID(N'dbo.zERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT',N'U') is not null 
drop table dbo.zERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT  

IF OBJECT_ID(N'dbo.zERR_LEGAL_FACT',N'U') is not null 
drop table dbo.zERR_LEGAL_FACT  

IF OBJECT_ID(N'dbo.zERR_LEGAL_JURISDICTION_DIM',N'U') is not null 
drop table dbo.zERR_LEGAL_JURISDICTION_DIM  

IF OBJECT_ID(N'dbo.zERR_LEGAL_RESULT_DIM',N'U') is not null 
drop table dbo.zERR_LEGAL_RESULT_DIM  

IF OBJECT_ID(N'dbo.zERR_LEGAL_STATUS_DIM',N'U') is not null 
drop table dbo.zERR_LEGAL_STATUS_DIM  

IF OBJECT_ID(N'dbo.zERR_LEGAL_TPR_REFERRAL_FACT',N'U') is not null 
drop table dbo.zERR_LEGAL_TPR_REFERRAL_FACT  

IF OBJECT_ID(N'dbo.zERR_LICENSE_ACTION_FACT',N'U') is not null 
drop table dbo.zERR_LICENSE_ACTION_FACT  

IF OBJECT_ID(N'dbo.zERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT',N'U') is not null 
drop table dbo.zERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT  

IF OBJECT_ID(N'dbo.zERR_LICENSE_ATTRIB_DIM',N'U') is not null 
drop table dbo.zERR_LICENSE_ATTRIB_DIM  

IF OBJECT_ID(N'dbo.zERR_LICENSE_FACT',N'U') is not null 
drop table dbo.zERR_LICENSE_FACT  

IF OBJECT_ID(N'dbo.zERR_LOCATION_DIM',N'U') is not null 
drop table dbo.zERR_LOCATION_DIM  



IF OBJECT_ID(N'dbo.zERR_MENTAL_HEALTH_EVAL_DIM',N'U') is not null 
drop table dbo.zERR_MENTAL_HEALTH_EVAL_DIM  

IF OBJECT_ID(N'dbo.zERR_PAYMENT_DETAIL_DIM',N'U') is not null 
drop table dbo.zERR_PAYMENT_DETAIL_DIM  

IF OBJECT_ID(N'dbo.zERR_PAYMENT_DETAIL_FACT',N'U') is not null 
drop table dbo.zERR_PAYMENT_DETAIL_FACT 

IF OBJECT_ID(N'dbo.zERR_PAYMENT_DIM',N'U') is not null 
drop table dbo.zERR_PAYMENT_DIM  

IF OBJECT_ID(N'dbo.zERR_PAYMENT_FACT',N'U') is not null 
drop table dbo.zERR_PAYMENT_FACT  

IF OBJECT_ID(N'dbo.zERR_PEOPLE_DIM',N'U') is not null 
drop table [dbo].[zERR_PEOPLE_DIM]  

IF OBJECT_ID(N'dbo.zERR_PERMANENCY_FACT',N'U') is not null 
drop table [dbo].[zERR_PERMANENCY_FACT]  

IF OBJECT_ID(N'dbo.zERR_PERMANENCY_PLAN_DIM',N'U') is not null 
drop table [dbo].[zERR_PERMANENCY_PLAN_DIM]  

IF OBJECT_ID(N'dbo.zERR_PLACEMENT_CARE_AUTH_DIM',N'U') is not null 
drop table [dbo].[zERR_PLACEMENT_CARE_AUTH_DIM]  

IF OBJECT_ID(N'dbo.zERR_PLACEMENT_CARE_AUTH_FACT',N'U') is not null 
drop table [dbo].[zERR_PLACEMENT_CARE_AUTH_FACT]  

IF OBJECT_ID(N'dbo.zERR_PLACEMENT_FACT',N'U') is not null 
drop table [dbo].[zERR_PLACEMENT_FACT]  

IF OBJECT_ID(N'dbo.zERR_PLACEMENT_RESULT_DIM',N'U') is not null 
drop table [dbo].[zERR_PLACEMENT_RESULT_DIM]  

IF OBJECT_ID(N'dbo.zERR_PLACEMENT_TYPE_DIM',N'U') is not null
 drop table [dbo].[zERR_PLACEMENT_TYPE_DIM]  
 
IF OBJECT_ID(N'dbo.zERR_PRE_ADOPTION_LEGAL_FACT',N'U') is not null 
drop table [dbo].[zERR_PRE_ADOPTION_LEGAL_FACT]  

IF OBJECT_ID(N'dbo.zERR_PRIMARY_ASSIGNMENT_FACT',N'U') is not null 
drop table [dbo].[zERR_PRIMARY_ASSIGNMENT_FACT]  

IF OBJECT_ID(N'dbo.zERR_PROVIDER_DIM',N'U') is not null 
drop table [dbo].[zERR_PROVIDER_DIM]  

IF OBJECT_ID(N'dbo.zERR_PROVIDER_NOTES_TYPE_DIM',N'U') is not null 
drop table [dbo].[zERR_PROVIDER_NOTES_TYPE_DIM]  

IF OBJECT_ID(N'dbo.zERR_PROVIDER_PART_FACT',N'U') is not null
 drop table [dbo].[zERR_PROVIDER_PART_FACT]  
 
IF OBJECT_ID(N'dbo.zERR_PROVIDER_SERVICE_LICENSE_FACT',N'U') is not null 
drop table [dbo].[zERR_PROVIDER_SERVICE_LICENSE_FACT]  

IF OBJECT_ID(N'dbo.zERR_RELATIONSHIP_DIM',N'U') is not null 
drop table [dbo].[zERR_RELATIONSHIP_DIM]  

IF OBJECT_ID(N'dbo.zERR_REMOVAL_DIM',N'U') is not null 
drop table [dbo].[zERR_REMOVAL_DIM]  

IF OBJECT_ID(N'dbo.zERR_REMOVAL_EPISODE_FACT',N'U') is not null 
drop table [dbo].[zERR_REMOVAL_EPISODE_FACT]  

IF OBJECT_ID(N'dbo.zERR_REPEAT_MALTREATMENT_FACT',N'U') is not null 
drop table [dbo].[zERR_REPEAT_MALTREATMENT_FACT]  

IF OBJECT_ID(N'dbo.zERR_RESPONSE_TIME_EXP_DIM',N'U') is not null 
drop table [dbo].[zERR_RESPONSE_TIME_EXP_DIM]  

IF OBJECT_ID(N'dbo.zERR_RGAP_AGREEMENT_ATTRIBUTE_DIM',N'U') is not null
 drop table [dbo].[zERR_RGAP_AGREEMENT_ATTRIBUTE_DIM]  
 
IF OBJECT_ID(N'dbo.zERR_RGAP_AGREEMENT_FACT',N'U') is not null 
drop table [dbo].[zERR_RGAP_AGREEMENT_FACT]  

IF OBJECT_ID(N'dbo.zERR_RGAP_ELIGIBILITY_FACT',N'U') is not null 
drop table [dbo].[zERR_RGAP_ELIGIBILITY_FACT]  

IF OBJECT_ID(N'dbo.zERR_RGAP_ELIGIBILITY_STATUS_DIM',N'U') is not null 
drop table [dbo].[zERR_RGAP_ELIGIBILITY_STATUS_DIM]  

IF OBJECT_ID(N'dbo.zERR_SAFETY_ASSESSMENT_FACT',N'U') is not null 
drop table [dbo].[zERR_SAFETY_ASSESSMENT_FACT]  

IF OBJECT_ID(N'dbo.zERR_SCHOOL_DIM',N'U') is not null 
drop table [dbo].[zERR_SCHOOL_DIM]  

IF OBJECT_ID(N'dbo.zERR_SERVICE_FACT',N'U') is not null 
drop table [dbo].[zERR_SERVICE_FACT]  

IF OBJECT_ID(N'dbo.zERR_SERVICE_REFERRAL_DIM',N'U') is not null 
drop table [dbo].[zERR_SERVICE_REFERRAL_DIM]  

IF OBJECT_ID(N'dbo.zERR_SERVICE_TYPE_DIM',N'U') is not null 
drop table [dbo].[zERR_SERVICE_TYPE_DIM]  

IF OBJECT_ID(N'dbo.zERR_SIBLING_RELATIONSHIP_FACT',N'U') is not null 
drop table [dbo].[zERR_SIBLING_RELATIONSHIP_FACT]  

IF OBJECT_ID(N'dbo.zERR_SOURCE_FUNDS_DIM',N'U') is not null 
drop table [dbo].[zERR_SOURCE_FUNDS_DIM]  

IF OBJECT_ID(N'dbo.zERR_SUBSTANCE_ABUSE_WIZARD_FACT',N'U') is not null 
drop table [dbo].[zERR_SUBSTANCE_ABUSE_WIZARD_FACT]  

IF OBJECT_ID(N'dbo.zERR_TRIBE_ATTRIBUTE_DIM',N'U') is not null
 drop table [dbo].[zERR_TRIBE_ATTRIBUTE_DIM]  
 
IF OBJECT_ID(N'dbo.zERR_TRIBE_DIM',N'U') is not null 
drop table [dbo].[zERR_TRIBE_DIM]  

IF OBJECT_ID(N'dbo.zERR_TRIBE_FACT',N'U') is not null 
drop table [dbo].[zERR_TRIBE_FACT]  

IF OBJECT_ID(N'dbo.zERR_WORKER_DIM',N'U') is not null 
drop table [dbo].[zERR_WORKER_DIM]  
IF OBJECT_ID(N'dbo.zERR_TRAINING_FACT',N'U') is not null DROP TABLE dbo.zERR_TRAINING_FACT
IF OBJECT_ID(N'dbo.zERR_EDUCATION_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_FACT
IF OBJECT_ID(N'dbo.zERR_EDUCATION_PLAN_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_PLAN_FACT
IF OBJECT_ID(N'dbo.zERR_IL_ANSELL_CASEY_ASSESSMENT_FACT',N'U') is not null DROP TABLE dbo.zERR_IL_ANSELL_CASEY_ASSESSMENT_FACT
--IF OBJECT_ID(N'dbo.zERR_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM',N'U') is not null DROP TABLE dbo.zERR_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM
IF OBJECT_ID(N'dbo.zERR_IL_NYTD_QUESTIONS_FACT',N'U') is not null DROP TABLE dbo.zERR_IL_NYTD_QUESTIONS_FACT
IF OBJECT_ID(N'dbo.zERR_TRAINING_FACT',N'U') is not null DROP TABLE dbo.zERR_TRAINING_FACT
IF OBJECT_ID(N'dbo.zERR_TRAINING_TYPE_DIM',N'U') is not null DROP TABLE dbo.zERR_TRAINING_TYPE_DIM
IF OBJECT_ID(N'dbo.zERR_INDEPENDENT_LIVING_BRIDGE_FACT',N'U') is not null DROP TABLE dbo.zERR_INDEPENDENT_LIVING_BRIDGE_FACT
IF OBJECT_ID(N'dbo.zERR_INDEPENDENT_LIVING_FACT',N'U') is not null DROP TABLE dbo.zERR_INDEPENDENT_LIVING_FACT
IF OBJECT_ID(N'dbo.zERR_TANF_FACT',N'U') is not null DROP TABLE dbo.zERR_TANF_FACT
IF OBJECT_ID(N'dbo.zERR_TANF_DIM',N'U') is not null DROP TABLE dbo.zERR_TANF_DIM
IF OBJECT_ID(N'dbo.zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT
IF OBJECT_ID(N'dbo.zERR_rptPlacement',N'U') is not null DROP TABLE dbo.zERR_rptPlacement
IF OBJECT_ID(N'dbo.zERR_rptPlacement_Events',N'U') is not null DROP TABLE dbo.zERR_rptPlacement_Events
IF OBJECT_ID(N'dbo.zERR_CASE_PARTICIPANT_STATUS_DIM',N'U') is not null DROP TABLE dbo.zERR_CASE_PARTICIPANT_STATUS_DIM


IF OBJECT_ID(N'dbo.[zERR_ABUSE_FACT]',N'U') IS NOT NULL DROP TABLE dbo.[zERR_ABUSE_FACT]
create table dbo.[zERR_ABUSE_FACT] (  [ID_ABUSE_FACT] nvarchar(50)  NULL ,   [ID_CPS] nvarchar(50)  NULL ,   [ID_PRSN_VCTM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_FOUNDED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_INCIDENT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_REFERRED] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INCIDENT] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INTAKE_WORKER] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INVESTIGATION_WORKER] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_PRIMARY_WORKER] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_VICTIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM_PRIMARY] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
IF OBJECT_ID('dbo.[[zERR_ABUSE_TYPE_DIM]]', 'U') IS NOT NULL DROP TABLE dbo.[zERR_ABUSE_TYPE_DIM]
create table dbo.[zERR_ABUSE_TYPE_DIM] (  [ID_ABUSE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_ALLEGATION] nvarchar(50)  NULL ,   [TX_ALLEGATION] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ADOPTION_FACT] (  [ID_ADOPTION_FACT] nvarchar(50)  NULL ,   [ID_ELIG] nvarchar(50)  NULL ,   [ID_ELIG_REDET] nvarchar(50)  NULL ,   [ID_ADOPTION_STATUS_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_COMPLETE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_EFFECTIVE_ELIGIBLE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_TERMINATED] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [FL_CMPLT] nvarchar(50)  NULL ,   [FL_VOID] nvarchar(50)  NULL ,   [DT_CMPLT] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ADOPTION_STATUS_DIM] (  [ID_ADOPTION_STATUS_DIM] nvarchar(50)  NULL ,   [CD_ELIG_STAT] nvarchar(50)  NULL ,   [TX_ELIG_STAT] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_AGREEMENT_DIM] (  [ID_AGREEMENT_DIM] nvarchar(50)  NULL ,   [CD_ADPTN_SUB_TYPE] nvarchar(50)  NULL ,   [TX_ADPTN_SUB_TYPE] nvarchar(50)  NULL ,   [CD_AGRM_TYPE] nvarchar(50)  NULL ,   [TX_AGRM_TYPE] nvarchar(50)  NULL ,   [CD_STAT] nvarchar(50)  NULL ,   [TX_STAT] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ALLEGATION_FACT] (  [ID_ALLEGATION_FACT] nvarchar(50)  NULL ,   [ID_ALGT] nvarchar(50)  NULL ,   [ID_CPS] nvarchar(50)  NULL ,   [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_INVESTIGATION_ASSESSMENT_FACT] nvarchar(50)  NULL ,   [ID_ABUSE_TYPE_DIM] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_FINDINGS_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_SUBJECT] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_VICTIM] nvarchar(50)  NULL ,   [ID_RELATIONSHIP_DIM] nvarchar(50)  NULL ,   [FL_FATALITY] nvarchar(50)  NULL ,   [FL_FATALITY_INVS] nvarchar(50)  NULL ,   [FL_INVS] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRSN_SUBJECT] nvarchar(50)  NULL ,   [ID_PRSN_VICTIM] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ASSIGNMENT_ATTRIBUTE_DIM] (  [ID_ASSIGNMENT_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [CD_ASGN_CTGRY] nvarchar(50)  NULL ,   [TX_ASGN_CTGRY] nvarchar(200)  NULL ,   [CD_ASGN_ROLE] nvarchar(50)  NULL ,   [TX_ASGN_ROLE] nvarchar(200)  NULL ,   [CD_ASGN_RSPNS] nvarchar(50)  NULL ,   [TX_ASGN_RSPNS] nvarchar(200)  NULL ,   [CD_ASGN_TYPE] nvarchar(50)  NULL ,   [TX_ASGN_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ASSIGNMENT_FACT] (  [ID_ASSIGNMENT_FACT] nvarchar(50)  NULL ,   [ID_ASGN] nvarchar(50)  NULL ,   [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_ASSIGNMENT_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_AUTHORIZATION_DIM] (  [ID_AUTHORIZATION_DIM] nvarchar(50)  NULL ,   [CD_AUTH_STATUS] nvarchar(50)  NULL ,   [TX_AUTH_STATUS] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_AUTHORIZATION_FACT] (  [ID_AUTHORIZATION_FACT] nvarchar(50)  NULL ,   [ID_AUTH] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_SSPS_AUTH] nvarchar(50)  NULL ,   [ID_AUTHORIZATION_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AUTH_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AUTH_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_SERVICE_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_SERVICE_END] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_CHART_OF_ACCOUNTS_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CLIENT] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_PAYEE] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_SERVICE] nvarchar(50)  NULL ,   [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [ID_SOURCE_FUNDS_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [AM_RATE] nvarchar(50)  NULL ,   [AM_TOTAL_PAID] nvarchar(50)  NULL ,   [AM_UNITS] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_PRSN_CLIENT] nvarchar(50)  NULL ,   [ID_PRVD_ORG_PAYEE] nvarchar(50)  NULL ,   [ID_PRVD_ORG_SERVICE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)

CREATE TABLE dbo.zERR_CALENDAR_DIM (
    [ID_CALENDAR_DIM] nvarchar(50),
    [CALENDAR_DATE] nvarchar(50),
    [YEAR_YYYY] nvarchar(50),
    [MONTH_MM] nvarchar(50),
    [DAY_DD] nvarchar(50),
    [DATE_NAME] nvarchar(50),
    [YEAR] nvarchar(50),
    [YEAR_NAME] nvarchar(50),
    [QUARTER] nvarchar(50),
    [QUARTER_NAME] nvarchar(50),
    [MONTH] nvarchar(50),
    [MONTH_NAME] nvarchar(50),
    [WEEK] nvarchar(50),
    [WEEK_NAME] nvarchar(50),
    [DAY_OF_YEAR] nvarchar(50),
    [DAY_OF_YEAR_NAME] nvarchar(50),
    [DAY_OF_QUARTER] nvarchar(50),
    [DAY_OF_QUARTER_NAME] nvarchar(50),
    [DAY_OF_MONTH] nvarchar(50),
    [DAY_OF_MONTH_NAME] nvarchar(50),
    [DAY_OF_WEEK] nvarchar(50),
    [DAY_OF_WEEK_NAME] nvarchar(50),
    [WEEK_OF_YEAR] nvarchar(50),
    [WEEK_OF_YEAR_NAME] nvarchar(50),
    [MONTH_OF_YEAR] nvarchar(50),
    [MONTH_OF_YEAR_NAME] nvarchar(50),
    [MONTH_OF_QUARTER] nvarchar(50),
    [MONTH_OF_QUARTER_NAME] nvarchar(50),
    [QUARTER_OF_YEAR] nvarchar(50),
    [QUARTER_OF_YEAR_NAME] nvarchar(50),
    [FEDERAL_FISCAL_YEAR] nvarchar(50),
    [FEDERAL_FISCAL_YEAR_NAME] nvarchar(50),
    [FEDERAL_FISCAL_QUARTER] nvarchar(50),
    [FEDERAL_FISCAL_QUARTER_NAME] nvarchar(50),
    [FEDERAL_FISCAL_MONTH] nvarchar(50),
    [FEDERAL_FISCAL_MONTH_NAME] nvarchar(50),
    [FEDERAL_FISCAL_WEEK] nvarchar(50),
    [FEDERAL_FISCAL_WEEK_NAME] nvarchar(50),
    [FEDERAL_FISCAL_DAY] nvarchar(50),
    [FEDERAL_FISCAL_DAY_NAME] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_YEAR] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_YEAR_NAME] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_QUARTER] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_QUARTER_NAME] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_MONTH] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_MONTH_NAME] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_WEEK] nvarchar(50),
    [FEDERAL_FISCAL_DAY_OF_WEEK_NAME] nvarchar(50),
    [FEDERAL_FISCAL_WEEK_OF_YEAR] nvarchar(50),
    [FEDERAL_FISCAL_WEEK_OF_YEAR_NAME] nvarchar(50),
    [FEDERAL_FISCAL_MONTH_OF_YEAR] nvarchar(50),
    [FEDERAL_FISCAL_MONTH_OF_YEAR_NAME] nvarchar(50),
    [FEDERAL_FISCAL_MONTH_OF_QUARTER] nvarchar(50),
    [FEDERAL_FISCAL_MONTH_OF_QUARTER_NAME] nvarchar(50),
    [FEDERAL_FISCAL_QUARTER_OF_YEAR] nvarchar(50),
    [FEDERAL_FISCAL_QUARTER_OF_YEAR_NAME] nvarchar(50),
    [STATE_FISCAL_YEAR] nvarchar(50),
    [STATE_FISCAL_YEAR_NAME] nvarchar(50),
    [STATE_FISCAL_QUARTER] nvarchar(50),
    [STATE_FISCAL_QUARTER_NAME] nvarchar(50),
    [STATE_FISCAL_MONTH] nvarchar(50),
    [STATE_FISCAL_MONTH_NAME] nvarchar(50),
    [STATE_FISCAL_WEEK] nvarchar(50),
    [STATE_FISCAL_WEEK_NAME] nvarchar(50),
    [STATE_FISCAL_DAY] nvarchar(50),
    [STATE_FISCAL_DAY_NAME] nvarchar(50),
    [STATE_FISCAL_DAY_OF_YEAR] nvarchar(50),
    [STATE_FISCAL_DAY_OF_QUARTER] nvarchar(50),
    [STATE_FISCAL_DAY_OF_QUARTER_NAME] nvarchar(50),
    [STATE_FISCAL_DAY_OF_MONTH] nvarchar(50),
    [STATE_FISCAL_DAY_OF_MONTH_NAME] nvarchar(50),
    [STATE_FISCAL_DAY_OF_WEEK] nvarchar(50),
    [STATE_FISCAL_DAY_OF_WEEK_NAME] nvarchar(50),
    [STATE_FISCAL_WEEK_OF_YEAR] nvarchar(50),
    [STATE_FISCAL_WEEK_OF_YEAR_NAME] nvarchar(50),
    [STATE_FISCAL_MONTH_OF_YEAR] nvarchar(50),
    [STATE_FISCAL_MONTH_OF_YEAR_NAME] nvarchar(50),
    [STATE_FISCAL_MONTH_OF_QUARTER] nvarchar(50),
    [STATE_FISCAL_MONTH_OF_QUARTER_NAME] nvarchar(50),
    [STATE_FISCAL_QUARTER_OF_YEAR] nvarchar(50),
    [STATE_FISCAL_QUARTER_OF_YEAR_NAME] nvarchar(50),
    [STATE_HOLIDAY_FLAG] nvarchar(50),
    [WORKDAY_FLAG] nvarchar(50),
    [DST_FLAG] nvarchar(50),
    [DT_ROW_BEGIN] nvarchar(50),
    [DT_ROW_END] nvarchar(50),
    [ID_CYCLE] nvarchar(50),
    [IS_CURRENT] nvarchar(50),
    [MONTH_END_FLAG] nvarchar(50),
    [CALENDAR_DATE_YYYY_MM_DD] nvarchar(50),
    [CALENDAR_DATE_MM_DD_YYYY] nvarchar(50),
    [LastOfMonth] nvarchar(50),
    [CaseMonth] nvarchar(50),
    [MONTH_TEXT] nvarchar(50),
    [MONTH_TEXT_ABBR] nvarchar(50),
    [YEAR_MONTH] nvarchar(50),
    [FIRST_OF_MONTH] nvarchar(50),
    [FEDERAL_FISCAL_YYYY] nvarchar(50),
    [STATE_FISCAL_YYYY] nvarchar(50),
    [ErrorCode] int,
    [ErrorColumn] int
)
create table dbo.[zERR_CASE_DIM] (  [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_LAST_ACTIVITY] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [CD_CASE_STAT] nvarchar(1)  NULL ,   [TX_CASE_STAT] nvarchar(200)  NULL ,   [CD_CASE_TYPE] nvarchar(50)  NULL ,   [TX_CASE_TYPE] nvarchar(200)  NULL ,   [CD_DCF_WRK_INV] nvarchar(50)  NULL ,   [TX_DCF_WRK_INV] nvarchar(200)  NULL ,   [DT_CASE_CLS] nvarchar(50)  NULL ,   [DT_CASE_OPN] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [FL_DELETED] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [FL_TRIBAL_IVE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_CASE_NOTE_FACT] (  [ID_CASE_NOTE_FACT] nvarchar(50)  NULL ,   [ID_CAN_ACTIVITIES] nvarchar(50)  NULL ,   [ID_CAN_EVENT] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_OCCURRED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_PRIOR_VISIT] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_CASE_NOTE_TYPE_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [CD_LOCATION] nvarchar(50)  NULL ,   [TX_LOCATION] nvarchar(200)  NULL ,   [FL_VISIT_ACTUAL] nvarchar(50)  NULL ,   [FL_VISIT_ANY] nvarchar(50)  NULL ,   [QT_PRIOR_FULL_MONTH_VISITS] nvarchar(50)  NULL ,   [QT_PRIOR_VISITS] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_CASE_NOTE_TYPE_DIM] (  [ID_CASE_NOTE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_ACTIVITY] nvarchar(50)  NULL ,   [TX_ACTIVITY] nvarchar(255)  NULL ,   [CD_CTGRY] nvarchar(50)  NULL ,   [TX_CTGRY] nvarchar(200)  NULL ,   [CD_TYPE] nvarchar(50)  NULL ,   [TX_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_CASE_PARTICIPANT_FACT] (  [ID_CASE_PARTICIPANT_FACT] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   ID_CASE_PARTICIPANT_STATUS_DIM nvarchar(50)  NULL ,  FL_ACTIVE_PARTICIPANT  nvarchar(50)  NULL , [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_CHART_OF_ACCOUNTS_DIM] (  [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ID_CHART_OF_ACCOUNTS_DIM] nvarchar(50)  NULL ,   [ID_CHART_OF_ACCOUNTS] nvarchar(50)  NULL ,   [CD_SRVC] nvarchar(50)  NULL ,   [TX_ALLOCATION] nvarchar(50)  NULL ,   [TX_APPROPRIATION_INDEX] nvarchar(50)  NULL ,   [TX_FUND] nvarchar(50)  NULL ,   [TX_PROGRAM_INDEX] nvarchar(50)  NULL ,   [TX_SOURCE_OF_FUNDS] nvarchar(50)  NULL ,   [TX_SUB_OBJECT] nvarchar(50)  NULL ,   [TX_SUB_SUB_OBJECT] nvarchar(50)  NULL ,   [DT_END] nvarchar(50)  NULL ,   [DT_START] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_DISCHARGE_REASON_DIM] (  [ID_DISCHARGE_REASON_DIM] nvarchar(50)  NULL ,   [CD_DSCH_RSN] nvarchar(50)  NULL ,   [TX_DSCH_RSN] nvarchar(200)  NULL ,   [CD_PLCM_DSCH_RSN] nvarchar(50)  NULL ,   [TX_PLCM_DSCH_RSN] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_DISPOSITION_DIM] (  [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ID_DISPOSITION_DIM] nvarchar(50)  NULL ,   [CD_INVS_DISP] nvarchar(50)  NULL ,   [TX_INVS_DISP] nvarchar(200)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_DLR_RISK_ASSESSMENT_FACT] (  [ID_DLR_RISK_ASSESSMENT_FACT] nvarchar(50)  NULL ,   [ID_RISK_ASSESS] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_COMPLETED] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [CD_CAREGIVER_CHAR] nvarchar(50)  NULL ,   [TX_CAREGIVER_CHAR] nvarchar(200)  NULL ,   [CD_CHILD_CHAR] nvarchar(50)  NULL ,   [TX_CHILD_CHAR] nvarchar(200)  NULL ,   [CD_CHRONICITY] nvarchar(50)  NULL ,   [TX_CHRONICITY] nvarchar(200)  NULL ,   [CD_OVERALL_RISK] nvarchar(50)  NULL ,   [TX_OVERALL_RISK] nvarchar(200)  NULL ,   [CD_PERPETRATOR_ACCESS] nvarchar(50)  NULL ,   [TX_PERPETRATOR_ACCESS] nvarchar(200)  NULL ,   [CD_RELATIONSHIP] nvarchar(50)  NULL ,   [TX_RELATIONSHIP] nvarchar(200)  NULL ,   [CD_SEVERITY_CAN] nvarchar(50)  NULL ,   [TX_SEVERITY_CAN] nvarchar(200)  NULL ,   [CD_SOCIAL_FACTOR] nvarchar(50)  NULL ,   [TX_SOCIAL_FACTOR] nvarchar(200)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_EDUCATION_DIM] (  [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ID_EDUCATION_DIM] nvarchar(50)  NULL ,   [CD_CHANGE_REASON] nvarchar(200)  NULL ,   [TX_CHANGE_REASON] nvarchar(200)  NULL ,   [CD_CMPLTN_STAT] nvarchar(200)  NULL ,   [TX_CMPLTN_STAT] nvarchar(200)  NULL ,   [CD_EFFORT_MADE] nvarchar(200)  NULL ,   [TX_EFFORT_MADE] nvarchar(200)  NULL ,   [CD_GRADE] nvarchar(200)  NULL ,   [TX_GRADE] nvarchar(200)  NULL ,   [CD_MAINTAIN_EFFORTS] nvarchar(200)  NULL ,   [TX_MAINTAIN_EFFORTS] nvarchar(200)  NULL ,   [CD_PRGM_TYPE] nvarchar(200)  NULL ,   [TX_PRGM_TYPE] nvarchar(200)  NULL ,   [CD_REASON_NOT_ENROLLED] nvarchar(200)  NULL ,   [TX_REASON_NOT_ENROLLED] nvarchar(200)  NULL ,   [CD_SCHL_TYPE] nvarchar(200)  NULL ,   [TX_SCHL_TYPE] nvarchar(200)  NULL ,   [CD_SPECIAL_EDUCATION_LEVEL] nvarchar(200)  NULL ,   [TX_SPECIAL_EDUCATION_LEVEL] nvarchar(200)  NULL ,   [CD_SPECIAL_REASON] nvarchar(200)  NULL ,   [TX_SPECIAL_REASON] nvarchar(200)  NULL ,   [CD_WASL_MATH] nvarchar(200)  NULL ,   [TX_WASL_MATH] nvarchar(200)  NULL ,   [CD_WASL_READING] nvarchar(200)  NULL ,   [TX_WASL_READING] nvarchar(200)  NULL ,   [CD_WASL_SCIENCE] nvarchar(200)  NULL ,   [TX_WASL_SCIENCE] nvarchar(200)  NULL ,   [CD_WASL_WRITING] nvarchar(200)  NULL ,   [TX_WASL_WRITING] nvarchar(200)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_EDUCATION_PLAN_DIM] (  [ID_EDUCATION_PLAN_DIM] nvarchar(50)  NULL ,   [CD_ACADEM_GOALS] nvarchar(50)  NULL ,   [TX_ACADEM_GOALS] nvarchar(200)  NULL ,   [CD_ACADEM_PROGRESS] nvarchar(50)  NULL ,   [TX_ACADEM_PROGRESS] nvarchar(200)  NULL ,   [CD_ED_ROLE] nvarchar(50)  NULL ,   [TX_ED_ROLE] nvarchar(200)  NULL ,   [CD_ISSUES_PROGRESS] nvarchar(50)  NULL ,   [TX_ISSUES_PROGRESS] nvarchar(200)  NULL ,   [CD_PLAN_CREDITS] nvarchar(50)  NULL ,   [TX_PLAN_CREDITS] nvarchar(200)  NULL ,   [CD_PREP_POST_ED] nvarchar(50)  NULL ,   [TX_PREP_POST_ED] nvarchar(200)  NULL ,   [CD_PROVIDED_BY] nvarchar(50)  NULL ,   [TX_PROVIDED_BY] nvarchar(200)  NULL ,   [CD_RES_ROLE] nvarchar(50)  NULL ,   [TX_RES_ROLE] nvarchar(200)  NULL ,   [CD_SERVICES_NEEDED] nvarchar(50)  NULL ,   [TX_SERVICES_NEEDED] nvarchar(200)  NULL ,   [CD_TRANSPORT] nvarchar(50)  NULL ,   [TX_TRANSPORT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] (  [ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM] nvarchar(50)  NULL ,   [CD_REASON_NOT_RECEIVED] nvarchar(50)  NULL ,   [TX_REASON_NOT_RECEIVED] nvarchar(200)  NULL ,   [CD_SCHOOL_DISTRICT] nvarchar(50)  NULL ,   [TX_SCHOOL_DISTRICT] nvarchar(200)  NULL ,   [CD_REFERRAL_TO] nvarchar(50)  NULL ,   [TX_REFERRAL_TO] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ELIG_EPISODE_FACT] (  [ID_ELIG_EPISODE_FACT] nvarchar(50)  NULL ,   [ID_ELIG] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [CD_ELIG] nvarchar(50)  NULL ,   [TX_ELIG] nvarchar(200)  NULL ,   [FL_APPLICABLE] nvarchar(50)  NULL ,   [FL_LCNS_VRFD] nvarchar(50)  NULL ,   [FL_REIMB] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [Copy of TX_ELIG] varchar(200)  NULL ,   [Copy of CD_ELIG] varchar(1)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ELIGIBILITY_DIM] (  [ID_ELIGIBILITY_DIM] nvarchar(50)  NULL ,   [CD_AGE] nvarchar(50)  NULL ,   [TX_AGE] nvarchar(200)  NULL ,   [CD_CTZN] nvarchar(50)  NULL ,   [TX_CTZN] nvarchar(200)  NULL ,   [CD_DPRV_TYPE] nvarchar(50)  NULL ,   [TX_DPRV_TYPE] nvarchar(200)  NULL ,   [CD_DPRVTN] nvarchar(50)  NULL ,   [TX_DPRVTN] nvarchar(200)  NULL ,   [CD_LGL_RESP] nvarchar(50)  NULL ,   [TX_LGL_RESP] nvarchar(200)  NULL ,   [CD_PRMNCY_PLAN] nvarchar(50)  NULL ,   [TX_PRMNCY_PLAN] nvarchar(200)  NULL ,   [CD_RMVL] nvarchar(50)  NULL ,   [TX_RMVL] nvarchar(200)  NULL ,   [CD_RMVL_RE] nvarchar(50)  NULL ,   [TX_RMVL_RE] nvarchar(200)  NULL ,   [CD_SSI] nvarchar(50)  NULL ,   [TX_SSI] nvarchar(200)  NULL ,   [CD_VPA_CTW] nvarchar(50)  NULL ,   [TX_VPA_CTW] nvarchar(200)  NULL ,   [FL_ASSET_TEST] nvarchar(50)  NULL ,   [FL_INCOME_TEST] nvarchar(50)  NULL ,   [FL_INITIAL_ELIGIBILITY] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ELIGIBILITY_FACT] (  [ID_ELIGIBILITY_DIM] nvarchar(50)  NULL ,   [ID_ELIGIBILITY_FACT] nvarchar(50)  NULL ,   [ID_ELIG] nvarchar(50)  NULL ,   [ID_ELIG_REDET] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_COMPLETE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ELIGIBILITY_COMPLETE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ELIGIBILITY_EFFECTIVE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ELIGIBILITY_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ELIGIBILITY_VPA_CTW] nvarchar(50)  NULL ,   [ID_ELIGIBILITY_REMOVAL_HOME_DIM] nvarchar(50)  NULL ,   [ID_ELIGIBILITY_STATUS_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [FL_CMPLT] nvarchar(50)  NULL ,   [FL_VOID] nvarchar(50)  NULL ,   [DT_CMPLT] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [FL_DETER_NA] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ELIGIBILITY_REMOVAL_HOME_DIM] (  [ID_ELIGIBILITY_REMOVAL_HOME_DIM] nvarchar(50)  NULL ,   [CD_NPR_CHILD_LIVED_PARENT] nvarchar(50)  NULL ,   [TX_NPR_CHILD_LIVED_PARENT] nvarchar(200)  NULL ,   [CD_NPR_CHILD_LIVING_PARENT] nvarchar(50)  NULL ,   [TX_NPR_CHILD_LIVING_PARENT] nvarchar(200)  NULL ,   [CD_RFNR_CHILD_LIVED] nvarchar(50)  NULL ,   [TX_RFNR_CHILD_LIVED] nvarchar(200)  NULL ,   [CD_RFNR_CHILD_LIVED_PARENT] nvarchar(50)  NULL ,   [TX_RFNR_CHILD_LIVED_PARENT] nvarchar(200)  NULL ,   [CD_RFNR_CHILD_LIVED_RSD] nvarchar(50)  NULL ,   [TX_RFNR_CHILD_LIVED_RSD] nvarchar(200)  NULL ,   [CD_RFNR_RSD_ABUSED_CHILD] nvarchar(50)  NULL ,   [TX_RFNR_RSD_ABUSED_CHILD] nvarchar(200)  NULL ,   [CD_RFNR_RSD_LIVED_PARENT] nvarchar(50)  NULL ,   [TX_RFNR_RSD_LIVED_PARENT] nvarchar(200)  NULL ,   [CD_RFNR_RSD_NAMED_IN_COURT] nvarchar(50)  NULL ,   [TX_RFNR_RSD_NAMED_IN_COURT] nvarchar(200)  NULL ,   [CD_RFR_CHILD_LIVED_PARENT] nvarchar(50)  NULL ,   [TX_RFR_CHILD_LIVED_PARENT] nvarchar(200)  NULL ,   [CD_RFR_RSD_ABUSE_CHILD] nvarchar(50)  NULL ,   [TX_RFR_RSD_ABUSE_CHILD] nvarchar(200)  NULL ,   [CD_RFR_RSD_NAMED_IN_COURT] nvarchar(50)  NULL ,   [TX_RFR_RSD_NAMED_IN_COURT] nvarchar(200)  NULL ,   [CD_RMVL_HOME] nvarchar(50)  NULL ,   [TX_RMVL_HOME] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_ELIGIBILITY_STATUS_DIM] (  [ID_ELIGIBILITY_STATUS_DIM] nvarchar(50)  NULL ,   [CD_ELIGIBILITY_STATUS] nvarchar(50)  NULL ,   [TX_ELIGIBILITY_STATUS] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_FAMILY_STRUCTURE_DIM] (  [ID_FAMILY_STRUCTURE_DIM] nvarchar(50)  NULL ,   [CD_CRTKR] nvarchar(50)  NULL ,   [TX_CRTKR] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_FINDINGS_DIM] (  [ID_FINDINGS_DIM] nvarchar(50)  NULL ,   [CD_FINDING] nvarchar(200)  NULL ,   [TX_FINDING] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_HEALTH_ACTIVITY_FACT] (  [ID_HEALTH_ACTIVITY_FACT] nvarchar(50)  NULL ,   [ID_SOURCE_KEY] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ACTIVITY_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ACTIVITY_START] nvarchar(50)  NULL ,   [ID_HEALTH_ACTIVITY_TYPE_DIM] nvarchar(50)  NULL ,   [ID_MENTAL_HEALTH_EVAL_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [FL_INACCURATE_DATA] nvarchar(50)  NULL ,   [QT_RECORDS_REQUEST] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_HEALTH_ACTIVITY_TYPE_DIM] (  [ID_HEALTH_ACTIVITY_TYPE_DIM] nvarchar(50)  NULL ,   [TX_HLTH_ACTVTY] nvarchar(50)  NULL ,   [TX_SOURCE_TABLE] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT] (  [ID_HEALTH_ACTIVITY_FACT] nvarchar(50)  NULL ,   [ID_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT] nvarchar(50)  NULL ,   [ID_HEALTH_CAT_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)

--DROP TABLE [dbo].[zERR_INTAKE_ATTRIBUTE_DIM]
CREATE TABLE [dbo].[zERR_INTAKE_ATTRIBUTE_DIM](
	[ID_INTAKE_ATTRIBUTE_DIM] [nvarchar](500) NULL,
	[ID_ACCESS_REPORT] [nvarchar](50) NULL,
	[CD_ALLEGATION_ABUSE] [nvarchar](200) NULL,
	[TX_ALLEGATION_ABUSE] [nvarchar](200) NULL,
	[CD_BEHAVIORAL_PROBLEMS] [nvarchar](200) NULL,
	[TX_BEHAVIORAL_PROBLEMS] [nvarchar](200) NULL,
	[CD_BENEFIT_TREATMENT] [nvarchar](200) NULL,
	[TX_BENEFIT_TREATMENT] [nvarchar](200) NULL,
	[CD_CHILD_ASLTD_IN_DOMESTIC_VIOLENCE] [nvarchar](200) NULL,
	[TX_CHILD_ASLTD_IN_DOMESTIC_VIOLENCE] [nvarchar](200) NULL,
	[CD_CHRONICITY] [nvarchar](200) NULL,
	[TX_CHRONICITY] [nvarchar](200) NULL,
	[CD_COMPLAINTS_HYGIENE] [nvarchar](50) NULL,
	[TX_COMPLAINTS_HYGIENE] [nvarchar](200) NULL,
	[CD_CONTACT_OTHERS] [nvarchar](50) NULL,
	[TX_CONTACT_OTHERS] [nvarchar](200) NULL,
	[TX_CPS_SPVR_RSN] [nvarchar](200) NULL,
	[CD_DCF_WRK_INV] [nvarchar](50) NULL,
	[TX_DCF_WRK_INV] [nvarchar](200) NULL,
	[CD_DEVELOPMENTAL_DISABILITY] [nvarchar](50) NULL,
	[TX_DEVELOPMENTAL_DISABILITY] [nvarchar](200) NULL,
	[CD_DNGR_TO_CHLD_IN_DOMESTIC_VIOLENCE] [nvarchar](50) NULL,
	[TX_DNGR_TO_CHLD_IN_DOMESTIC_VIOLENCE] [nvarchar](200) NULL,
	[CD_DRUG_ABUSE] [nvarchar](50) NULL,
	[TX_DRUG_ABUSE] [nvarchar](200) NULL,
	[CD_DSCN_OVERRIDE] [nvarchar](50) NULL,
	[TX_DSCN_OVERRIDE] [nvarchar](200) NULL,
	[CD_FAILURE_BASIC_NEEDS] [nvarchar](50) NULL,
	[TX_FAILURE_BASIC_NEEDS] [nvarchar](200) NULL,
	[CD_FAILURE_CLOTHING] [nvarchar](50) NULL,
	[TX_FAILURE_CLOTHING] [nvarchar](200) NULL,
	[CD_FAILURE_SUPERVISE] [nvarchar](50) NULL,
	[TX_FAILURE_SUPERVISE] [nvarchar](200) NULL,
	[CD_FAILURE_TREATMENT] [nvarchar](50) NULL,
	[TX_FAILURE_TREATMENT] [nvarchar](200) NULL,
	[CD_FEAR_AFRAID] [nvarchar](50) NULL,
	[TX_FEAR_AFRAID] [nvarchar](200) NULL,
	[CD_HAZARDOUS_CONDITIONS] [nvarchar](50) NULL,
	[TX_HAZARDOUS_CONDITIONS] [nvarchar](200) NULL,
	[CD_IMMEDIATE_CPS_RESPONSE] [nvarchar](50) NULL,
	[TX_IMMEDIATE_CPS_RESPONSE] [nvarchar](200) NULL,
	[CD_IMMEDIATE_MEDICAL] [nvarchar](50) NULL,
	[TX_IMMEDIATE_MEDICAL] [nvarchar](200) NULL,
	[CD_INDIAN_RESERVATION] [nvarchar](50) NULL,
	[TX_INDIAN_RESERVATION] [nvarchar](200) NULL,
	[CD_LANG] [nvarchar](50) NULL,
	[TX_LANG] [nvarchar](200) NULL,
	[CD_LOCO_PARENTIS] [nvarchar](50) NULL,
	[TX_LOCO_PARENTIS] [nvarchar](200) NULL,
	[CD_MEDICAL_NEGLECT] [nvarchar](50) NULL,
	[TX_MEDICAL_NEGLECT] [nvarchar](200) NULL,
	[CD_MEET_WAC] [nvarchar](50) NULL,
	[TX_MEET_WAC] [nvarchar](200) NULL,
	[CD_MEMBER] [nvarchar](50) NULL,
	[TX_MEMBER] [nvarchar](200) NULL,
	[CD_MTHD] [nvarchar](50) NULL,
	[TX_MTHD] [nvarchar](200) NULL,
	[CD_NATIVE] [nvarchar](50) NULL,
	[TX_NATIVE] [nvarchar](200) NULL,
	[CD_OVERRIDE_REASON] [nvarchar](50) NULL,
	[TX_OVERRIDE_REASON] [nvarchar](200) NULL,
	[CD_PHYSICAL_HARM] [nvarchar](50) NULL,
	[TX_PHYSICAL_HARM] [nvarchar](200) NULL,
	[CD_PHYSICAL_SEXUAL_ABUSE] [nvarchar](50) NULL,
	[TX_PHYSICAL_SEXUAL_ABUSE] [nvarchar](200) NULL,
	[CD_POOR_JUDGMENT] [nvarchar](50) NULL,
	[TX_POOR_JUDGMENT] [nvarchar](200) NULL,
	[CD_PREVIOUS_FOUNDED] [nvarchar](50) NULL,
	[TX_PREVIOUS_FOUNDED] [nvarchar](200) NULL,
	[CD_PRNT_KILLED_BY_PERPETRATOR] [nvarchar](50) NULL,
	[TX_PRNT_KILLED_BY_PERPETRATOR] [nvarchar](200) NULL,
	[CD_RPTR_DSCR] [nvarchar](50) NULL,
	[TX_RPTR_DSCR] [nvarchar](200) NULL,
	[CD_RTM_DSGNTN] [nvarchar](50) NULL,
	[TX_RTM_DSGNTN] [nvarchar](200) NULL,
	[CD_SERIOUS_INJURIES] [nvarchar](50) NULL,
	[TX_SERIOUS_INJURIES] [nvarchar](200) NULL,
	[CD_SPVR_RSN] [nvarchar](50) NULL,
	[TX_SPVR_RSN] [nvarchar](200) NULL,
	[CD_THREAT_LIFE] [nvarchar](50) NULL,
	[TX_THREAT_LIFE] [nvarchar](200) NULL,
	[CD_THREAT_PHSCL_FRC_AGNST_ADLT] [nvarchar](50) NULL,
	[TX_THREAT_PHSCL_FRC_AGNST_ADLT] [nvarchar](200) NULL,
	[CD_UNDER_AGE] [nvarchar](50) NULL,
	[TX_UNDER_AGE] [nvarchar](200) NULL,
	[CD_UNREALISTIC_EXPECTATION] [nvarchar](50) NULL,
	[TX_UNREALISTIC_EXPECTATION] [nvarchar](200) NULL,
	[CD_WARD_TRIBAL_COURT] [nvarchar](50) NULL,
	[TX_WARD_TRIBAL_COURT] [nvarchar](200) NULL,
	[CD_WRKR_RSN] [nvarchar](50) NULL,
	[TX_WRKR_RSN] [nvarchar](200) NULL,
	[FL_AFTER_HOURS] [nvarchar](50) NULL,
	[FL_CIA] [nvarchar](50) NULL,
	[FL_EFFS] [nvarchar](50) NULL,
	[FL_INTERP] [nvarchar](50) NULL,
	[FL_INVS] [nvarchar](50) NULL,
	[FL_MNDREP] [nvarchar](50) NULL,
	[FL_NTC_GEN] [nvarchar](50) NULL,
	[FL_OTHR] [nvarchar](50) NULL,
	[FL_PCKT] [nvarchar](50) NULL,
	[FL_POLICE] [nvarchar](50) NULL,
	[FL_PRVD_ASSOCIATED] [nvarchar](50) NULL,
	[FL_REFERRER_REQ_CONFIDENTIALITY] [nvarchar](50) NULL,
	[FL_RESPONSE_COMPLETE] [nvarchar](50) NULL,
	[FL_RPT_ADDRSS] [nvarchar](50) NULL,
	[FL_RSPNS_DSCN_OVERRIDE] [nvarchar](50) NULL,
	[FL_RTM_TIME] [nvarchar](50) NULL,
	[FL_SER_INCD_RPT_GNRTD] [nvarchar](50) NULL,
	[FL_WRKR_SFTY_CONCERNS] [nvarchar](50) NULL,
	[DT_ROW_BEGIN] [nvarchar](50) NULL,
	[DT_ROW_END] [nvarchar](50) NULL,
	[ID_CYCLE] [nvarchar](50) NULL,
	[IS_CURRENT] [nvarchar](50) NULL,
	[FL_DELETED] [nvarchar](50) NULL,
	[FL_EXPUNGED] [nvarchar](50) NULL,
	[CD_INTAKE_TYPE_DERIVED] [nvarchar](50) NULL,
	[TX_INTAKE_TYPE_DERIVED] [nvarchar](200) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)

--drop table dbo.[zERR_INTAKE_FACT]
create table dbo.[zERR_INTAKE_FACT] (  [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_ACCESS_REPORT] nvarchar(50)  NULL ,   [ID_POLICE_REPORT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ACCESS_RCVD] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_CPS_SPVR_DSCN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_INCD] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_SPVR_DSCN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_WRKR_DSCN] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_INTAKE_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [ID_INTAKE_TYPE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INTAKE_WORKER] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_INTAKE] nvarchar(50)  NULL ,   [ID_RESPONSE_TIME_EXP_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM_CPS_SUPERVISOR] nvarchar(50)  NULL ,   [ID_WORKER_DIM_INTAKE] nvarchar(50)  NULL ,   [ID_WORKER_DIM_INTAKE_SUPERVISOR] nvarchar(50)  NULL ,   [DT_ACCESS_RCVD] nvarchar(50)  NULL ,  [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRVD_ORG_INTAKE] nvarchar(50)  NULL,
	[ID_INVS] nvarchar(50)  NULL ,
	[ID_FACP] nvarchar(50)  NULL ,
	[CD_INTAKE_VERSION] nvarchar(50)  NULL ,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)

CREATE TABLE dbo.[zERR_INTAKE_PARTICIPANT_FACT](	[ID_INTAKE_PARTICIPANT_FACT] nvarchar(max),	[CD_INTK_TYPE] nvarchar(max),	[ID_INTK] nvarchar(max),	[TS_CR] nvarchar(max),	[ID_INTAKE_FACT] nvarchar(max),	[ID_INTAKE_PARTICIPANT_ROLES_DIM] nvarchar(max),	[ID_PEOPLE_DIM_CHILD] nvarchar(max),	[TX_INTK_TYPE] nvarchar(max),	[FL_EXPUNGED] nvarchar(max),	[ID_PRSN_CHILD] nvarchar(max), [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_INTAKE_PARTICIPANT_ROLES_DIM] (  [ID_INTAKE_PARTICIPANT_ROLES_DIM] nvarchar(50)  NULL ,   [CD_ROLE1] nvarchar(50)  NULL ,   [TX_ROLE1] nvarchar(200)  NULL ,   [CD_ROLE2] nvarchar(50)  NULL ,   [TX_ROLE2] nvarchar(200)  NULL ,   [CD_ROLE3] nvarchar(50)  NULL ,   [TX_ROLE3] nvarchar(200)  NULL ,   [CD_ROLE4] nvarchar(50)  NULL ,   [TX_ROLE4] nvarchar(200)  NULL ,   [CD_ROLE5] nvarchar(50)  NULL ,   [TX_ROLE5] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_INTAKE_SERVICE_BRIDGE_FACT] (  [ID_INTAKE_SERVICE_BRIDGE_FACT] nvarchar(50)  NULL ,   [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_SERVICE_REFERRAL_DIM] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)

create table dbo.[zERR_INTAKE_TYPE_DIM] (  [ID_INTAKE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_ACCESS_TYPE] nvarchar(50)  NULL ,   [TX_ACCESS_TYPE] nvarchar(200)  NULL ,   [CD_CPS_SUPERVISOR_DECISION] nvarchar(50)  NULL ,   [TX_CPS_SUPERVISOR_DECISION] nvarchar(200)  NULL ,   [CD_FINAL_DECISION] nvarchar(50)  NULL ,   [TX_FINAL_DECISION] nvarchar(200)  NULL ,   [CD_SUPERVISOR_DECISION] nvarchar(50)  NULL ,   [TX_SUPERVISOR_DECISION] nvarchar(200)  NULL ,   [CD_WORKER_DECISION] nvarchar(50)  NULL ,   [TX_WORKER_DECISION] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,
	[CD_INTAKE_TYPE_DERIVED] nvarchar(50)  NULL ,
	[TX_INTAKE_TYPE_DERIVED] nvarchar(200)  NULL ,
   	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)

create table dbo.[zERR_INTAKE_VICTIM_FACT] (  [ID_INTAKE_VICTIM_FACT] nvarchar(50)  NULL ,   [ID_ACCESS_REPORT] nvarchar(50)  NULL ,   [ID_INVS] nvarchar(50)  NULL ,   [ID_PRSN_VCTM] nvarchar(50)  NULL ,   [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_IFF_RESPONSE_ATTEMPT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_IFF_RESPONSE_COMPLETED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_VICTIM_ADDED] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_RESPONSE_TIME_EXP_DIM] nvarchar(50)  NULL ,   [CD_ACTIVITY_LOCATION_IFF] nvarchar(50)  NULL ,   [TX_ACTIVITY_LOCATION_IFF] nvarchar(200)  NULL ,   [ACTUAL_RESPONSE_TIME] nvarchar(50)  NULL ,   [ATTEMPTED_RESPONSE_TIME] nvarchar(50)  NULL ,   [DT_IFF_ATTEMPTED] nvarchar(50)  NULL ,   [DT_IFF_COMPLETED] nvarchar(50)  NULL ,   [DT_VICTIM_ADDED] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [DT_DUE_ORIGINAL] nvarchar(50)  NULL ,   [DT_DUE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_DUE_ORIGINAL] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_DUE] nvarchar(50)  NULL ,   [FL_EXCEPTION] nvarchar(50)  NULL ,   [FL_EXTENSION] nvarchar(50)  NULL ,   [FL_IFF_REQUIRED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_EXTENSION] nvarchar(50)  NULL ,   [DT_EXTENSION] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRVD_ORG_INTAKE] nvarchar(50)  NULL ,
	[ID_FACP] nvarchar(50)  NULL ,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
)

create table dbo.[zERR_INVESTIGATION_ASSESSMENT_FACT] (  [ID_INVESTIGATION_ASSESSMENT_FACT] nvarchar(50)  NULL ,   [ID_INVS] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_LEVEL1_APPROVED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_LEVEL2_APPROVED] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_DISPOSITION_DIM] nvarchar(50)  NULL ,   [ID_INVESTIGATION_TYPE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [QT_DAYS_LEVEL1_APPROVAL] nvarchar(50)  NULL ,   [QT_DAYS_LEVEL2_APPROVAL] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_INVESTIGATION_TYPE_DIM] (  [ID_INVESTIGATION_TYPE_DIM] nvarchar(50)  NULL ,   [CD_INVS_TYPE] nvarchar(50)  NULL ,   [TX_INVS_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL)
create table dbo.[zERR_LEGAL_ACTION_DIM] (  [ID_LEGAL_ACTION_DIM] nvarchar(50)  NULL ,   [CD_LEGAL_ACTION] nvarchar(50)  NULL ,   [TX_LEGAL_ACTION] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT] (  [ID_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT] nvarchar(50)  NULL ,   [ID_LEGAL_AGGRAVATED_CIRCUMSTANCES] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_FINDING] nvarchar(50)  NULL ,   [FL_ADOPTION_NOT_APPROPRIATE] nvarchar(50)  NULL ,   [FL_AGGRV_CIRCUMSTANCE_EXISTS] nvarchar(50)  NULL ,   [FL_COMP_REASON_EXISTS] nvarchar(50)  NULL ,   [FL_NO_RSNBL_EFFORT_CT_FINDING] nvarchar(50)  NULL ,   [FL_PROGRESS] nvarchar(50)  NULL ,   [FL_OTHER_TPR_REASON] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_FACT] (  [ID_LEGAL_FACT] nvarchar(50)  NULL ,   [ID_CRT_DISP] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_EFFECTIVE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_HEARING] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_ACTION_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_JURISDICTION_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_RESULT_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [FL_REASONABLE_EFFORT_FINALIZE_PERMANENCY] nvarchar(50)  NULL ,   [FL_REASONABLE_EFFORT_PREVENT_REMOVAL] nvarchar(50)  NULL ,   [TS_UP] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_JURISDICTION_DIM] (  [ID_LEGAL_JURISDICTION_DIM] nvarchar(50)  NULL ,   [CD_JURISDICTION] nvarchar(50)  NULL ,   [TX_JURISDICTION] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_RESULT_DIM] (  [ID_LEGAL_RESULT_DIM] nvarchar(50)  NULL ,   [CD_RESULT] nvarchar(50)  NULL ,   [TX_RESULT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_STATUS_DIM] (  [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [CD_LGL_STAT] nvarchar(50)  NULL ,   [TX_LGL_STAT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LEGAL_TPR_REFERRAL_FACT] (  [ID_LEGAL_TPR_REFERRAL_FACT] nvarchar(50)  NULL ,   [ID_LEGAL_TPR_REFERRAL] nvarchar(50)  NULL ,   [ID_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_TPR_REFERRAL] nvarchar(50)  NULL ,   [ID_RELATIONSHIP_DIM_TPR] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_TPR_PARENT] nvarchar(50)  NULL ,   [ID_PRSN_TPR_PARENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LICENSE_ACTION_FACT] (  [ID_LICENSE_ACTION_FACT] nvarchar(50)  NULL ,   [ID_LCNS] nvarchar(50)  NULL ,   [ID_LCNS_ACTN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ACTION] nvarchar(50)  NULL ,   [ID_LICENSE_ATTRIB_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [CD_ACTN] nvarchar(50)  NULL ,   [TX_ACTN] nvarchar(200)  NULL ,   [CD_ACTN_RSN] nvarchar(50)  NULL ,   [TX_ACTN_RSN] nvarchar(200)  NULL ,   [CD_ACTN_RSN2] nvarchar(50)  NULL ,   [TX_ACTN_RSN2] nvarchar(200)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LICENSE_ATTRIB_DIM] (  [ID_LICENSE_ATTRIB_DIM] nvarchar(50)  NULL ,   [ID_LCNS] nvarchar(50)  NULL ,   [CD_APPLICATION_STATUS] nvarchar(50)  NULL ,   [TX_LICENSE_APPLICATION_STATUS] nvarchar(50)  NULL ,   [CD_CHILD_SPECIFIC_FOSTER_HOME] nvarchar(50)  NULL ,   [TX_LICENSE_CHILD_SPECIFIC] nvarchar(200)  NULL ,   [CD_FACILITY_TYPE] nvarchar(50)  NULL ,   [TX_LICENSE_FACILITY_TYPE] nvarchar(200)  NULL ,   [CD_LCNS_STAT] nvarchar(50)  NULL ,   [TX_LCNS_STAT] nvarchar(200)  NULL ,   [CD_LCNS_TYPE] nvarchar(50)  NULL ,   [TX_LCNS_TYPE] nvarchar(200)  NULL ,   [CD_LICENSE_CERTIFICATE] nvarchar(50)  NULL ,   [TX_LICENSE_CERTIFICATE] nvarchar(200)  NULL ,   [CD_LICENSE_REASON] nvarchar(50)  NULL ,   [TX_LICENSE_REASON] nvarchar(200)  NULL ,   [TX_GENDER] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_LICENSE_FACT] (  [ID_LICENSE_FACT] nvarchar(50)  NULL ,   [ID_BSNS] nvarchar(50)  NULL ,   [ID_LCNS] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_APPLICATION] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_CLOSED] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_EXPIRATION] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ISSUE] nvarchar(50)  NULL ,   [ID_LICENSE_ATTRIB_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [FL_AGE_GROUP1] nvarchar(50)  NULL ,   [FL_AGE_GROUP2] nvarchar(50)  NULL ,   [FL_AGE_GROUP3] nvarchar(50)  NULL ,   [FL_BRS] nvarchar(50)  NULL ,   [FL_FOSTER_CARE_LEVEL1] nvarchar(50)  NULL ,   [FL_FOSTER_CARE_LEVEL2] nvarchar(50)  NULL ,   [FL_FOSTER_CARE_LEVEL3] nvarchar(50)  NULL ,   [FL_FOSTER_CARE_LEVEL4] nvarchar(50)  NULL ,   [FL_NEW_LCNS] nvarchar(50)  NULL ,   [FL_RESPITE] nvarchar(50)  NULL ,   [QT_AGE_FROM_MONTH] nvarchar(50)  NULL ,   [QT_AGE_FROM_YEAR] nvarchar(50)  NULL ,   [QT_AGE_TO_MONTH] nvarchar(50)  NULL ,   [QT_AGE_TO_YEAR] nvarchar(50)  NULL ,   [QT_CHILDREN_UNDER_TWO_MAXIMUM] nvarchar(50)  NULL ,   [QT_EITHER_CAP] nvarchar(50)  NULL ,   [QT_FEMALE_CAP] nvarchar(50)  NULL ,   [QT_MALE_CAP] nvarchar(50)  NULL ,   [QT_PENDING_DAYS] nvarchar(50)  NULL ,   [QT_TOTAL_CAP] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)

CREATE TABLE dbo.[zERR_LOCATION_DIM] (
    [DT_ROW_BEGIN] nvarchar(50),
    [DT_ROW_END] nvarchar(50),
    [ID_CYCLE] nvarchar(50),
    [IS_CURRENT] nvarchar(50),
    [ID_LOCATION_DIM] nvarchar(50),
    [CD_CNTY] nvarchar(50),
    [TX_CNTY] nvarchar(200),
    [CD_LCTN] nvarchar(50),
    [TX_LCTN] nvarchar(200),
    [CD_OFFICE] nvarchar(50),
    [TX_OFFICE] nvarchar(200),
    [CD_REGION] nvarchar(50),
    [TX_REGION] nvarchar(200),
    [CD_TOWN] nvarchar(50),
    [TX_TOWN] nvarchar(200),
    [CD_UNIT] nvarchar(50),
    [TX_UNIT] nvarchar(200),
    [CD_ACTIVE] nvarchar(50),
    [CD_RGN] nvarchar(50),
    [CD_STATE] nvarchar(50),
    [CD_ZIP] nvarchar(50),
    [CD_CITY_TYPE] nvarchar(50),
    [TX_CITY_TYPE] nvarchar(200),
    [ErrorCode] int,
    [ErrorColumn] int
)
create table dbo.[zERR_MENTAL_HEALTH_EVAL_DIM] (  [ID_MENTAL_HEALTH_EVAL_DIM] nvarchar(50)  NULL ,   [CD_EVAL_RESULT] nvarchar(50)  NULL ,   [TX_EVAL_RESULT] nvarchar(200)  NULL ,   [CD_EVAL_TYPE] nvarchar(50)  NULL ,   [TX_EVAL_TYPE] nvarchar(200)  NULL ,   [TX_IN_OUT_PATIENT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PAYMENT_DETAIL_DIM] (  [ID_PAYMENT_DETAIL_DIM] nvarchar(50)  NULL ,   [TX_ALLOCATION] nvarchar(50)  NULL ,   [TX_APPROPRIATION] nvarchar(50)  NULL ,   [TX_FUND] nvarchar(50)  NULL ,   [TX_PROGRAM_INDEX] nvarchar(50)  NULL ,   [TX_SUB_OBJECT] nvarchar(50)  NULL ,   [TX_SUB_SUB_OBJECT] nvarchar(50)  NULL ,   [SERVICE_YEAR_MONTH] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
CREATE TABLE [dbo].[zERR_PAYMENT_DETAIL_FACT](	[ID_PAYMENT_DETAIL_FACT] [nvarchar](50) NULL,	[ID_PMNT_HISTORY] [nvarchar](50) NULL,	[ID_PAYMENT_FACT] [nvarchar](50) NULL,	[ID_CALENDAR_DIM_EFFECTIVE] [nvarchar](50) NULL,	[ID_CALENDAR_DIM_FROM] [nvarchar](50) NULL,	[ID_CALENDAR_DIM_TO] [nvarchar](50) NULL,	[ID_PAYMENT_DETAIL_DIM] [nvarchar](50) NULL,	[ID_SOURCE_FUNDS_DIM] [nvarchar](50) NULL,	[AM_PAID] [nvarchar](50) NULL,	[FL_ACTIVE] [nvarchar](50) NULL,	[ErrorCode] [int] NULL,	[ErrorColumn] [int] NULL) ON [PRIMARY]
create table dbo.[zERR_PAYMENT_DIM] (  [ID_PAYMENT_DIM] nvarchar(50)  NULL ,   [CD_PAYMENT_SRVC_UNIT_TYPE] nvarchar(50)  NULL ,   [TX_PAYMENT_SRVC_UNIT_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PAYMENT_FACT] (  [ID_PAYMENT_FACT] nvarchar(50)  NULL ,   [ID_PMNT] nvarchar(50)  NULL ,   [ID_SSPS_AUTH] nvarchar(50)  NULL ,   [ID_SSPS_PAYEE_ID] nvarchar(50)  NULL ,   [ID_SSPS_PRVD_ID] nvarchar(50)  NULL ,   [ID_AUTHORIZATION_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AUTHORIZATION_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AUTHORIZATION_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_PAYMENT_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_PAYMENT_START] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_SERVICE_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_SERVICE_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_WARRANT] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PAYMENT_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CLIENT] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_PAYEE] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_SERVICE] nvarchar(50)  NULL ,   [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [CD_SSPS_REGION_CODE] nvarchar(50)  NULL ,   [CD_SSPS_RPT_UNIT] nvarchar(50)  NULL ,   [AM_RATE] nvarchar(50)  NULL ,   [AM_TOTAL_PAID] nvarchar(50)  NULL ,   [AM_UNITS] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_PRSN_CLIENT] nvarchar(50)  NULL ,   [ID_PRVD_ORG_PAYEE] nvarchar(50)  NULL ,   [ID_PRVD_ORG_SERVICE] nvarchar(50)  NULL ,  [ID_CASE] nvarchar(50)  NULL , [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
CREATE TABLE dbo.zERR_PEOPLE_DIM (
    [ID_PEOPLE_DIM] nvarchar(50),
    [ID_PRSN] nvarchar(50),
    [ID_ACES] nvarchar(50),
    [ID_WORKER_DIM_SSI_SSA_UPDATE] nvarchar(50),
    [TX_BRAAM_RACE] nvarchar(200),
    [CD_CMBN_ETHN] nvarchar(50),
    [TX_CMBN_ETHN] nvarchar(200),
    [CD_CTZN] nvarchar(50),
    [TX_CTZN] nvarchar(200),
    [CD_GNDR] nvarchar(50),
    [TX_GNDR] nvarchar(200),
    [CD_HSPNC] nvarchar(50),
    [TX_HSPNC] nvarchar(200),
    [CD_INDN] nvarchar(50),
    [TX_INDN] nvarchar(200),
    [CD_INDN2] nvarchar(50),
    [TX_INDN2] nvarchar(200),
    [CD_LICWAC] nvarchar(50),
    [TX_LICWAC] nvarchar(200),
    [CD_LNG_PRFR] nvarchar(50),
    [TX_LNG_PRFR] nvarchar(200),
    [CD_LNG_SECONDARY] nvarchar(50),
    [TX_LNG_SECONDARY] nvarchar(200),
    [CD_LTD_ENGLISH] nvarchar(50),
    [TX_LTD_ENGLISH] nvarchar(200),
    [CD_MRTL_STAT] nvarchar(50),
    [TX_MRTL_STAT] nvarchar(50),
    [TX_MULTIRACE] nvarchar(200),
    [CD_PRNTL_RLTNSHP] nvarchar(50),
    [TX_PRNTL_RLTNSHP] nvarchar(200),
    [CD_RACE] nvarchar(50),
    [TX_RACE] nvarchar(200),
    [CD_RACE_FIVE] nvarchar(50),
    [TX_RACE_FIVE] nvarchar(200),
    [CD_RACE_FOUR] nvarchar(50),
    [TX_RACE_FOUR] nvarchar(200),
    [CD_RACE_THREE] nvarchar(50),
    [TX_RACE_THREE] nvarchar(200),
    [CD_RACE_TWO] nvarchar(50),
    [TX_RACE_TWO] nvarchar(200),
    [CD_RLGN] nvarchar(50),
    [TX_RLGN] nvarchar(200),
    [CD_SSI_SSA_STATUS] nvarchar(50),
    [TX_SSI_SSA_STATUS] nvarchar(200),
    [CD_STATE_RSDNT] nvarchar(50),
    [TX_STATE_RSDNT] nvarchar(200),
    [FL_ADOPTION_MATCH] nvarchar(50),
    [FL_DANGER_TO_WORKER] nvarchar(50),
    [FL_DECEASED] nvarchar(50),
    [FL_DT_BIRTH_ESTIMATED] nvarchar(50),
    [FL_ICW_INVOLVEMENT] nvarchar(50),
    [FL_PHYS_DISABLED] nvarchar(50),
    [FL_PRSN_MALTREATER] nvarchar(50),
    [FL_SEX_AGGRESIVE_YOUTH] nvarchar(50),
    [FL_TEEN_PARENT] nvarchar(50),
    [FL_VIS_HEARING_IMPR] nvarchar(50),
    [DT_BIRTH] nvarchar(50),
    [DT_DEATH] nvarchar(50),
    [DT_LICWAC_DETERMINATION] nvarchar(50),
    [MULTI_RACE_MASK] nvarchar(50),
    [DT_ROW_BEGIN] nvarchar(50),
    [DT_ROW_END] nvarchar(50),
    [ID_CYCLE] nvarchar(50),
    [IS_CURRENT] nvarchar(50),
    [FL_DELETED] nvarchar(50),
    [FL_EXPUNGED] nvarchar(50),
    [FL_MNTAL_RETARDATN] nvarchar(50),
    [FL_EMOTION_DSTRBD] nvarchar(50),
    [FL_OTHR_SPC_CARE] nvarchar(50),
    [FL_PHYSICAL_AGGRSVE_YOUTH] nvarchar(50),
    [CD_REG_SEX_OFFENDER_LEVEL] nvarchar(50),
    [TX_REG_SEX_OFFENDER_LEVEL] nvarchar(200),
    [CD_SEXUAL_BEHAVIOR] nvarchar(50),
    [TX_SEXUAL_BEHAVIOR] nvarchar(200),
    [CD_RISKY_BEHAVIOR] nvarchar(50),
    [TX_RISKY_BEHAVIOR] nvarchar(200),
    [FL_LITIGATION_HOLD] nvarchar(50),
    [FL_PUBLIC_DISCLOSURE] nvarchar(50),
    [ID_PRSN_MOM] nvarchar(50),
    [ID_PRSN_DAD] nvarchar(50),
    [ID_PEOPLE_DIM_MOM] nvarchar(50),
    [ID_PEOPLE_DIM_DAD] nvarchar(50),
    [FL_PATERNITY_STATUS_KNOWN] nvarchar(50),
    [CD_MULTI_RACE_ETHNICITY] nvarchar(50),
    [TX_MULTI_RACE_ETHNICITY] nvarchar(200),
    [ErrorCode] int,
    [ErrorColumn] int
)
create table dbo.[zERR_PERMANENCY_FACT] (  [ID_PERMANENCY_FACT] nvarchar(50)  NULL ,   [ID_CRT_DISP] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_HEARING] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ORDER_ENTERED] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_JURISDICTION_DIM] nvarchar(50)  NULL ,   [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PERMANENCY_PLAN_DIM] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PERMANENCY_PLAN_DIM] (  [ID_PERMANENCY_PLAN_DIM] nvarchar(50)  NULL ,   [CD_RESULT] nvarchar(50)  NULL ,   [TX_PERM_PLAN] nvarchar(200)  NULL ,   [TX_PERM_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PLACEMENT_CARE_AUTH_DIM] (  [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [CD_PLACEMENT_CARE_AUTH] nvarchar(50)  NULL ,   [TX_PLACEMENT_CARE_AUTH] nvarchar(200)  NULL ,   [CD_TRIBE] nvarchar(50)  NULL ,   [TX_TRIBE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PLACEMENT_CARE_AUTH_FACT] (  [ID_PLACEMENT_CARE_AUTH_FACT] nvarchar(50)  NULL ,   [ID_PLCMNT_CARE_AUTHORITY] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [FL_COMPLETE] nvarchar(50)  NULL ,   [FL_VOID] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PLACEMENT_FACT] (  [ID_PLACEMENT_FACT] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_REMOVAL_EPISODE_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_RMVL] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_PLACEMENT] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_REMOVAL] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_WORKER] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_DISCHARGE_REASON_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_RESULT_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_CAREGIVER] nvarchar(50)  NULL ,   [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_REL] nvarchar(50)  NULL ,   [TX_REL] nvarchar(200)  NULL ,   [FL_CITY_SAME_AS_REMOVAL] nvarchar(50)  NULL ,   [FL_COUNTY_SAME_AS_REMOVAL] nvarchar(50)  NULL ,   [FL_REGION_SAME_AS_REMOVAL] nvarchar(50)  NULL ,   [FL_STATE_SAME_AS_REMOVAL] nvarchar(50)  NULL ,   [FL_ZIP_SAME_AS_REMOVAL] nvarchar(50)  NULL ,   [QT_DAYS_CLOSURE_LAG] nvarchar(50)  NULL ,   [CHILD_AGE_PLACEMENT_BEGIN] nvarchar(50)  NULL ,   [CHILD_AGE_PLACEMENT_END] nvarchar(50)  NULL ,   [LENGTH_OF_STAY] nvarchar(50)  NULL ,   [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRVD_ORG_CAREGIVER] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PLACEMENT_RESULT_DIM] (  [ID_PLACEMENT_RESULT_DIM] nvarchar(50)  NULL ,   [CD_ENDING_PURPOSE] nvarchar(50)  NULL ,   [TX_END_PURPOSE] nvarchar(200)  NULL ,   [CD_END_RSN] nvarchar(50)  NULL ,   [TX_END_RSN] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PLACEMENT_TYPE_DIM] (  [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [CD_EPSD_TYPE] nvarchar(50)  NULL ,   [TX_EPSD_TYPE] nvarchar(200)  NULL ,   [CD_PLCM_SETNG] nvarchar(50)  NULL ,   [TX_PLCM_SETNG] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PRE_ADOPTION_LEGAL_FACT] (  [ID_PRE_ADOPTION_LEGAL_FACT] nvarchar(50)  NULL ,   [ID_CASE_NEW] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ADOPTION] nvarchar(50)  NULL ,   [ID_LEGAL_JURISDICTION_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PRIMARY_ASSIGNMENT_FACT] (  [ID_PRIMARY_ASSIGNMENT_FACT] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_WORKER] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM_CURRENT] nvarchar(50)  NULL ,   [CD_ASGN_ROLE] nvarchar(50)  NULL ,   [DT_BEGIN] nvarchar(50)  NULL ,   [DT_END] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PROVIDER_DIM] (  [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_BSNS] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ID_SSPS] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_CREATED] nvarchar(50)  NULL ,   [CD_MAIL_CITY] nvarchar(50)  NULL ,   [TX_MAIL_CITY] nvarchar(200)  NULL ,   [TX_MAIL_COUNTY] nvarchar(200)  NULL ,   [TX_MAIL_STATE] nvarchar(200)  NULL ,   [TX_MAIL_ZIP] nvarchar(200)  NULL ,   [CD_PHYS_CITY] nvarchar(50)  NULL ,   [TX_PHYS_CITY] nvarchar(200)  NULL ,   [TX_PHYS_COUNTY] nvarchar(200)  NULL ,   [TX_PHYS_STATE] nvarchar(200)  NULL ,   [TX_PHYS_ZIP] nvarchar(200)  NULL ,   [CD_PROVIDER_TYPE] nvarchar(50)  NULL ,   [TX_PROVIDER_TYPE] nvarchar(200)  NULL ,   [CD_REGION] nvarchar(50)  NULL ,   [TX_REGION] nvarchar(200)  NULL ,   [CD_SSPS_STATUS] nvarchar(50)  NULL ,   [TX_SSPS_STATUS] nvarchar(200)  NULL ,   [CD_STAT] nvarchar(50)  NULL ,   [CD_TRIBAL_AFLTN] nvarchar(50)  NULL ,   [TX_TRIBAL_AFLTN] nvarchar(200)  NULL ,   [FL_24_HOUR_CARE] nvarchar(50)  NULL ,   [FL_ABUSES_ANIMALS] nvarchar(50)  NULL ,   [FL_ADA_NEEDS] nvarchar(50)  NULL ,   [FL_ADJUDICATED_CRIMINAL] nvarchar(50)  NULL ,   [FL_AFFILIATED_WITH_GANGS] nvarchar(50)  NULL ,   [FL_AUTISTIC] nvarchar(50)  NULL ,   [FL_BEFORE_AFTER_SCHOOL_ONLY] nvarchar(50)  NULL ,   [FL_DEVELOPMENTAL_DELAY] nvarchar(50)  NULL ,   [FL_DIABETIC] nvarchar(50)  NULL ,   [FL_DIAGNOSED_MENTAL_HEALTH_CONDITION] nvarchar(50)  NULL ,   [FL_DIAGNOSED_WITH_FETAL_ALCOHOL_SYNDROME] nvarchar(50)  NULL ,   [FL_DRUG_AFFECTED] nvarchar(50)  NULL ,   [FL_EATING_DISORDER] nvarchar(50)  NULL ,   [FL_ENCOPRETIC] nvarchar(50)  NULL ,   [FL_ENURESIS] nvarchar(50)  NULL ,   [FL_EVENING] nvarchar(50)  NULL ,   [FL_FEMALE] nvarchar(50)  NULL ,   [FL_FIRE_SETTER] nvarchar(50)  NULL ,   [FL_HEARING_IMPAIRED] nvarchar(50)  NULL ,   [FL_HIV_POSITIVE] nvarchar(50)  NULL ,   [FL_IV_DRUG_USER] nvarchar(50)  NULL ,   [FL_IVE_TRIBAL_AGREEMENT] nvarchar(50)  NULL ,   [FL_IVE_TRIBAL_AGRMT_IN_PLC] nvarchar(50)  NULL ,   [FL_LEARNING_DISABILITIES] nvarchar(50)  NULL ,   [FL_LIFE_SKILLS_TRAINING] nvarchar(50)  NULL ,   [FL_MALE] nvarchar(50)  NULL ,   [FL_MASTURBATES_IN_PUBLIC] nvarchar(50)  NULL ,   [FL_MEDICALLY_FRAGILE] nvarchar(50)  NULL ,   [FL_NAA_ACCREDITED] nvarchar(50)  NULL ,   [FL_NAEYC_ACCREDITED] nvarchar(50)  NULL ,   [FL_NAFCC_ACCREDITED] nvarchar(50)  NULL ,   [FL_OPEN] nvarchar(50)  NULL ,   [FL_PARENT_AGENCY] nvarchar(50)  NULL ,   [FL_PHYSICALLY_AGGRESSIVE_YOUTH] nvarchar(50)  NULL ,   [FL_PHYSICALLY_ASSAULTIVE_YOUTH_PAY] nvarchar(50)  NULL ,   [FL_PROPERTY_DESTRUCTION] nvarchar(50)  NULL ,   [FL_PSYCHIATRIC_HOSPITALIZATION_HISTORY] nvarchar(50)  NULL ,   [FL_RELATIVE_CAREGIVER] nvarchar(50)  NULL ,   [FL_REQUIRES_MEDICATION] nvarchar(50)  NULL ,   [FL_REQUIRES_SPECIAL_DIET] nvarchar(50)  NULL ,   [FL_RESIDENTIAL_TREATMENT_HISTORY] nvarchar(50)  NULL ,   [FL_RUNAWAY_HISTORY] nvarchar(50)  NULL ,   [FL_SELF_ABUSIVE] nvarchar(50)  NULL ,   [FL_SEXUALLY_ABUSED] nvarchar(50)  NULL ,   [FL_SEXUALLY_ACTIVE] nvarchar(50)  NULL ,   [FL_SEXUALLY_AGGRESSIVE_YOUTH] nvarchar(50)  NULL ,   [FL_SEXUALLY_AGGRESSIVE_YOUTH_SAY] nvarchar(50)  NULL ,   [FL_SEXUALLY_REACTIVE] nvarchar(50)  NULL ,   [FL_SIBLING_GROUP] nvarchar(50)  NULL ,   [FL_SIGNIFICANT_ASTHMA_OR_ALLERGIES] nvarchar(50)  NULL ,   [FL_SPECIAL_NEEDS_CHILDREN] nvarchar(50)  NULL ,   [FL_SPECIALIZED_MEDICAL_CERTIFICATION] nvarchar(50)  NULL ,   [FL_SUICIDAL_THREAT_ATTEMPT] nvarchar(50)  NULL ,   [FL_TREATMENT_FOSTER_HOME_TRAINING] nvarchar(50)  NULL ,   [FL_TUTORING] nvarchar(50)  NULL ,   [FL_VISUALLY_IMPAIRED] nvarchar(50)  NULL ,   [FL_WEEKEND_CARE] nvarchar(50)  NULL ,   [DT_ADDR_LAST_VERIFIED] nvarchar(50)  NULL ,   [DT_IVE_TRIBAL_AGREEMENT_EFFECTIVE] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [CD_MAIL_COUNTY] nvarchar(50)  NULL ,   [CD_PHYS_COUNTY] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PROVIDER_NOTES_TYPE_DIM] (  [ID_PROVIDER_NOTES_TYPE_DIM] nvarchar(50)  NULL ,   [CD_CTGRY] nvarchar(50)  NULL ,   [TX_CATEGORY] nvarchar(200)  NULL ,   [CD_TYPE] nvarchar(50)  NULL ,   [TX_CATEGORY_TYPE] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PROVIDER_PART_FACT] (  [ID_PROVIDER_PART_FACT] nvarchar(50)  NULL ,   [ID_BSNS] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_START] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM_CAREGIVER] nvarchar(50)  NULL ,   [CD_ROLE] nvarchar(50)  NULL ,   [TX_ROLE] nvarchar(200)  NULL ,   [CD_RSN_END] nvarchar(50)  NULL ,   [TX_RSN_END] nvarchar(200)  NULL ,   [CD_RSN_START] nvarchar(50)  NULL ,   [TX_RSN_START] nvarchar(200)  NULL ,   [TS_CR] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_PROVIDER_SERVICE_LICENSE_FACT] (  [ID_PROVIDER_SERVICE_LICENSE_FACT] nvarchar(50)  NULL ,   [ID_BSNS] nvarchar(50)  NULL ,   [ID_LCNS] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ID_LICENSE_FACT] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_SRVC] nvarchar(50)  NULL ,   [QT_LCNS_CAP] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RELATIONSHIP_DIM] (  [ID_RELATIONSHIP_DIM] nvarchar(50)  NULL ,   [CD_RLTNSHP_VCTM] nvarchar(50)  NULL ,   [TX_RLTNSHP_VCTM] nvarchar(200)  NULL ,   [CD_TPR_RELATIONSHIP] nvarchar(50)  NULL ,   [TX_TPR_RELATIONSHIP] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_REMOVAL_DIM] (  [ID_REMOVAL_DIM] nvarchar(50)  NULL ,   [CD_RMVL_MNR] nvarchar(50)  NULL ,   [TX_RMVL_MNR] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)

create table dbo.[zERR_REMOVAL_EPISODE_FACT] (  [ID_REMOVAL_EPISODE_FACT] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AFCARS_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_AFCARS_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_FIRST_HEALTH_SAFETY_VISIT] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_DISCHARGE_REASON_DIM] nvarchar(50)  NULL ,   [ID_FAMILY_STRUCTURE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_REMOVAL] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_WORKER] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_PARENT_PRIMARY] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_PARENT_SECONDARY] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_REMOVAL_DIM] nvarchar(50)  NULL ,   [ID_WORKER_DIM_CURRENT] nvarchar(50)  NULL ,   [ID_WORKER_DIM_ORIGINAL] nvarchar(50)  NULL ,   [FL_AAFC] nvarchar(50)  NULL ,   [FL_ABANDONMENT] nvarchar(50)  NULL ,   [FL_ABUSE] nvarchar(50)  NULL ,   [FL_CARETAKER_INABILITY_COPE] nvarchar(50)  NULL ,   [FL_CHILD_ABUSE_ALCOHOL] nvarchar(50)  NULL ,   [FL_CHILD_ABUSES_DRUG] nvarchar(50)  NULL ,   [FL_CHILD_BEHAVIOR_PROBLEMS] nvarchar(50)  NULL ,   [FL_CHILD_CLINICALLY_DIAGNOSED] nvarchar(50)  NULL ,   [FL_IN_ERROR] nvarchar(50)  NULL ,   [FL_INADEQUATE_HOUSNG] nvarchar(50)  NULL ,   [FL_NEGLECT] nvarchar(50)  NULL ,   [FL_PARENT_ABUSE_ALCOHOL] nvarchar(50)  NULL ,   [FL_PARENT_DEATH] nvarchar(50)  NULL ,   [FL_PARENT_DRUG_ABUSE] nvarchar(50)  NULL ,   [FL_PARENT_INCARCERATION] nvarchar(50)  NULL ,   [FL_PHYSICAL_ABUSE] nvarchar(50)  NULL ,   [FL_REENTRY] nvarchar(50)  NULL ,   [FL_RELINQUISHMENT] nvarchar(50)  NULL ,   [FL_SEX_ABUSE] nvarchar(50)  NULL ,   [CHILD_AGE_REMOVAL_BEGIN] nvarchar(50)  NULL ,   [CHILD_AGE_REMOVAL_END] nvarchar(50)  NULL ,   [LENGTH_OF_STAY] nvarchar(50)  NULL ,   [ID_LEGAL_STATUS_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_RESULT_DIM_LATEST] nvarchar(50)  NULL ,   [FL_TRIAL_RETURN_HOME] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_PRSN_PARENT_PRIMARY] nvarchar(50)  NULL ,   [ID_PRSN_PARENT_SECONDARY] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   
	[FL_EXTENDED_FOSTER_CARE] nvarchar(50)  NULL,
    [ErrorCode] int,
    [ErrorColumn] int
)

create table dbo.[zERR_REPEAT_MALTREATMENT_FACT] (  [ID_REPEAT_MALTREATMENT_FACT] nvarchar(50)  NULL ,   [ID_CPS] nvarchar(50)  NULL ,   [ID_CPS_PRIOR] nvarchar(50)  NULL ,   [ID_PRSN_VCTM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_PRIOR] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_REPEAT] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INCIDENT] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INTAKE_WORKER] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_INVESTIGATION_WORKER] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_PRIMARY_WORKER] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_VICTIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [QT_DAYS_BETWEEN_OCCURRENCE] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RESPONSE_TIME_EXP_DIM] (  [ID_RESPONSE_TIME_EXP_DIM] nvarchar(50)  NULL ,   [CD_RESPONSE_TIME_CAT] nvarchar(50)  NULL ,   [TX_RESPONSE_TIME_CAT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RGAP_AGREEMENT_ATTRIBUTE_DIM] (  [ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [CD_RGAP_AGREEMENT_TYPE] nvarchar(50)  NULL ,   [TX_RGAP_AGREEMENT_TYPE] nvarchar(200)  NULL ,   [CD_RGAP_SUB_TYPE] nvarchar(50)  NULL ,   [TX_RGAP_SUB_TYPE] nvarchar(200)  NULL ,   [CD_RGAP_STAT] nvarchar(50)  NULL ,   [TX_RGAP_STAT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RGAP_AGREEMENT_FACT] (  [ID_RGAP_AGREEMENT_FACT] nvarchar(50)  NULL ,   [ID_RGAP_AGREEMENT] nvarchar(50)  NULL ,   [ID_ORIG_RGAP_AGREEMENT] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_RGAP_AGREEMENT_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_RGAP_EFFECTIVE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_RGAP_END] nvarchar(50)  NULL ,   [ID_WORKER_DIM_RESPONSIBLE] nvarchar(50)  NULL ,     [ID_PRVD_ORG] nvarchar(50)  NULL ,  ID_CASE int NULL,ID_PRSN int NULL,	[ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RGAP_ELIGIBILITY_FACT] (  [ID_RGAP_ELIGIBILITY_FACT] nvarchar(50)  NULL ,   [ID_RGAP_ELIGIBILITY] nvarchar(50)  NULL ,   [ID_ORIG_RGAP_ELIGIBILITY] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_RGAP_ELIGIBILITY_STATUS_DIM] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_DETERMINATION_EFFECTIVE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_DETERMINATION_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_DETERMINATION_COMPLETED] nvarchar(50)  NULL ,   [ID_WORKER_DIM_DETERMINATION_COMPLETED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_RGAP_ELIGIBILITY_STATUS_DIM] (  [ID_RGAP_ELIGIBILITY_STATUS_DIM] nvarchar(50)  NULL ,   [CD_RGAP_ELIG_STAT] nvarchar(50)  NULL ,   [TX_RGAP_ELIG_STAT] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SAFETY_ASSESSMENT_FACT] (  [ID_SAFETY_ASSESSMENT_FACT] nvarchar(50)  NULL ,   [ID_SFTY_ASMNT_PART] nvarchar(50)  NULL ,   [ID_SFTY_ASMNT_PLAN] nvarchar(50)  NULL ,   [ID_INTAKE_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_APPROVAL] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_INVESTIGATION_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_INVESTIGATION_END] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_WORKER_DIM] nvarchar(50)  NULL ,   [CD_SDM_CALCULATED_RISK_LEVEL] nvarchar(50)  NULL ,   [TX_SDM_CALCULATED_RISK_LEVEL] nvarchar(200)  NULL ,   [CD_SDM_FINAL_RISK_LEVEL] nvarchar(50)  NULL ,   [TX_SDM_FINAL_RISK_LEVEL] nvarchar(200)  NULL ,   [CD_SDM_OVERRIDE_RISK_LEVEL] nvarchar(50)  NULL ,   [TX_SDM_OVERRIDE_RISK_LEVEL] nvarchar(200)  NULL ,   [CD_SDM_OVERRIDE_RISK_LEVEL_REASON] nvarchar(50)  NULL ,   [TX_SDM_OVERRIDE_RISK_LEVEL_REASON] nvarchar(200)  NULL ,   [FL_REQUIRED_SAFETY_ASSESSMENT] nvarchar(50)  NULL ,   [FL_RISK_LEVEL_OVERRIDE] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR1] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR2] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR3] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR4] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR5] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR6] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR7] nvarchar(50)  NULL ,   [FL_SAFETY_FACTOR8] nvarchar(50)  NULL ,   [FL_SAFETY_PLAN_EXISTS] nvarchar(50)  NULL ,   [QT_ABUSE_SCORE] nvarchar(50)  NULL ,   [QT_DAYS_UNTIL_START] nvarchar(50)  NULL ,   [QT_NEGLECT_SCORE] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SCHOOL_DIM] (  [ID_SCHOOL_DIM] nvarchar(50)  NULL ,   [ID_SCHL] nvarchar(50)  NULL ,   [ID_SCHL_CODE] nvarchar(50)  NULL ,   [CD_SCHL_DISTRICT] nvarchar(50)  NULL ,   [TX_SCHL_DISTRICT] nvarchar(200)  NULL ,   [CD_SCHL_LEVEL] nvarchar(2)  NULL ,   [TX_SCHL_LEVEL] nvarchar(200)  NULL ,   [FL_LEVEL_ELEM] nvarchar(1)  NULL ,   [FL_LEVEL_HIGH] nvarchar(1)  NULL ,   [FL_LEVEL_MIDDLE] nvarchar(1)  NULL ,   [NM_SCHL] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SERVICE_FACT] (  [ID_SERVICE_FACT] nvarchar(50)  NULL ,   [ID_EPSD] nvarchar(50)  NULL ,   [ID_REMOVAL_EPISODE_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_START] nvarchar(50)  NULL ,   [ID_CASE_DIM] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_TIME_OF_APPROVAL] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_SERVICE_RECIPIENT] nvarchar(50)  NULL ,   [ID_PLACEMENT_CARE_AUTH_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_FACT] nvarchar(50)  NULL ,   [ID_PLACEMENT_RESULT_DIM] nvarchar(50)  NULL ,   [ID_PLACEMENT_TYPE_DIM] nvarchar(50)  NULL ,   [ID_PROVIDER_DIM] nvarchar(50)  NULL ,   [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_SSPS_REGION] nvarchar(50)  NULL ,   [AM_RATE] nvarchar(50)  NULL ,   [AM_UNITS] nvarchar(50)  NULL ,   [FL_APPROVED] nvarchar(50)  NULL ,   [FL_IN_ERROR] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_PRSN_SERVICE_RECIPIENT] nvarchar(50)  NULL ,   [ID_PRVD_ORG] nvarchar(50)  NULL ,   [ID_CASE] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SERVICE_REFERRAL_DIM] (  [ID_SERVICE_REFERRAL_DIM] nvarchar(50)  NULL ,   [CD_SERVICE_REFERRAL_TYPE] nvarchar(50)  NULL ,   [TX_SERVICE_REFERRAL_TYPE] nvarchar(200)  NULL ,   [CD_SPECIFIC_SERVICE_REQUESTED] nvarchar(50)  NULL ,   [NM_SPECIFIC_SERVICE_REQUESTED] nvarchar(200)  NULL ,   [TX_RQST_SRVC_POSITION] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SERVICE_TYPE_DIM] (  [ID_SERVICE_TYPE_DIM] nvarchar(50)  NULL ,   [CD_PAYMENT_TYPE] nvarchar(50)  NULL ,   [TX_PAYMENT_TYPE] nvarchar(200)  NULL ,   [CD_SERVICE_CONCURRENCY] nvarchar(50)  NULL ,   [TX_SERVICE_CONCURRENCY] nvarchar(200)  NULL ,   [CD_SOCIAL_SRV_PAYMENT_SYS_SRV_CODE] nvarchar(50)  NULL ,   [CD_SRVC] nvarchar(50)  NULL ,   [TX_SRVC] nvarchar(200)  NULL ,   [CD_SRVC_CTGRY] nvarchar(50)  NULL ,   [TX_SRVC_CTGRY] nvarchar(200)  NULL ,   [CD_SSPS_REASON] nvarchar(50)  NULL ,   [CD_SUBCTGRY] nvarchar(50)  NULL ,   [TX_SUBCTGRY] nvarchar(200)  NULL ,   [CD_UNIT_RATE_TYPE] nvarchar(50)  NULL ,   [TX_UNIT_RATE_TYPE] nvarchar(200)  NULL ,   [FL_ELIGIBLE_IVE] nvarchar(50)  NULL ,   [FL_FUNDING_IV_E] nvarchar(50)  NULL ,   [FL_IV_E_PENETRATION_RATE] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [FL_RGAP] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SIBLING_RELATIONSHIP_FACT] (  [ID_SIBLING_RELATIONSHIP_FACT] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_BEGIN] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_END] nvarchar(50)  NULL ,   [ID_CASE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_CHILD] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_SIBLING] nvarchar(50)  NULL ,   [ID_PLACEMENT_FACT] nvarchar(50)  NULL ,   [TX_RELATIONSHIP_TYPE] nvarchar(200)  NULL ,   [FL_SIBLING_IN_PLACEMENT] nvarchar(50)  NULL ,   [FL_TOGETHER] nvarchar(50)  NULL ,   [CHILD_AGE] nvarchar(50)  NULL ,   [SIBLING_AGE] nvarchar(50)  NULL ,   [ID_PRSN_CHILD] nvarchar(50)  NULL ,   [ID_PRSN_SIBLING] nvarchar(50)  NULL ,   [ID_CASE_CHILD] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SOURCE_FUNDS_DIM] (  [ID_SOURCE_FUNDS_DIM] nvarchar(50)  NULL ,   [CD_ELIG_STATUS] nvarchar(50)  NULL ,   [TX_ELIG_STATUS] nvarchar(200)  NULL ,   [CD_SOURCE_FUNDS] nvarchar(50)  NULL ,   [TX_SOURCE_FUNDS] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_SUBSTANCE_ABUSE_WIZARD_FACT] (  [ID_SUBSTANCE_ABUSE_WIZARD_FACT] nvarchar(50)  NULL ,   [ID_SUBSTANCE_ABUSE] nvarchar(50)  NULL ,   [ID_INVESTIGATION_ASSESSMENT_FACT] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM_SUBJECT] nvarchar(50)  NULL ,   [CD_DRUG_ALCOHOL_PROBLEM] nvarchar(50)  NULL ,   [TX_DRUG_ALCOHOL_PROBLEM] nvarchar(200)  NULL ,   [CD_REFER_CHEM_DEP_SRVS] nvarchar(50)  NULL ,   [TX_REFER_CHEM_DEP_SRVS] nvarchar(200)  NULL ,   [CD_SUBST_ABUSE_SRVS] nvarchar(50)  NULL ,   [TX_SUBST_ABUSE_SRVS] nvarchar(200)  NULL ,   [FL_ALCOHOL_DURING_TWELVE_MOS] nvarchar(50)  NULL ,   [FL_ALCOHOL_PRIOR_TWELVE_MOS] nvarchar(50)  NULL ,   [FL_DRUG_DURING_TWELVE_MOS] nvarchar(50)  NULL ,   [FL_DRUG_PRIOR_TWELVE_MOS] nvarchar(50)  NULL ,   [ID_PRSN_SUBJECT] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_TRIBE_ATTRIBUTE_DIM] (  [ID_TRIBE_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [CD_PRSN_TRB_RESPONSE] nvarchar(50)  NULL ,   [TX_PRSN_TRB_RESPONSE] nvarchar(200)  NULL ,   [CD_PRSN_TRB_STATUS] nvarchar(50)  NULL ,   [TX_PRSN_TRB_STATUS] nvarchar(200)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_TRIBE_DIM] (  [ID_TRIBE_DIM] nvarchar(50)  NULL ,   [CD_TRIBE_TYPE] nvarchar(50)  NULL ,   [TX_TRIBE_TYPE] nvarchar(50)  NULL ,   [TX_TRIBE_NAME] nvarchar(200)  NULL ,   [FL_FED_TRIBE] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,  ID_TRIBE INT, [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_TRIBE_FACT] (  [ID_TRIBE_DIM] nvarchar(50)  NULL ,   [ID_TRIBE_FACT] nvarchar(50)  NULL ,   [ID_PRSN_TRIBE] nvarchar(50)  NULL ,   [ID_TRIBE] nvarchar(50)  NULL ,   [ID_CALENDAR_DIM_ENTERED] nvarchar(50)  NULL ,   [ID_PEOPLE_DIM] nvarchar(50)  NULL ,   [ID_TRIBE_ATTRIBUTE_DIM] nvarchar(50)  NULL ,   [FL_EXPUNGED] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
create table dbo.[zERR_WORKER_DIM] (  [ID_WORKER_DIM] nvarchar(50)  NULL ,   [ID_PRSN] nvarchar(50)  NULL ,   [ID_PRSN_SPRV] nvarchar(50)  NULL ,   [ID_RMTS_GROUP_COORD] nvarchar(50)  NULL ,   [ID_LOCATION_DIM_WORKER] nvarchar(50)  NULL ,   [ID_WORKER_DIM_SUPERVISOR] nvarchar(50)  NULL ,   [CD_JOB_CLS] nvarchar(50)  NULL ,   [TX_JOB_CLS] nvarchar(200)  NULL ,   [CD_RMTS_WRKR_TYP] nvarchar(50)  NULL ,   [TX_RMTS_WRKR_TYP] nvarchar(200)  NULL ,   [CD_STAT] nvarchar(50)  NULL ,   [TX_STAT] nvarchar(200)  NULL ,   [CD_UNT] nvarchar(50)  NULL ,   [QT_WRK_MEASURE] nvarchar(50)  NULL ,   [DT_BRTH] nvarchar(50)  NULL ,   [DT_END] nvarchar(50)  NULL ,   [DT_START] nvarchar(50)  NULL ,   [DT_ROW_BEGIN] nvarchar(50)  NULL ,   [DT_ROW_END] nvarchar(50)  NULL ,   [ID_CYCLE] nvarchar(50)  NULL ,   [IS_CURRENT] nvarchar(50)  NULL ,   [ErrorCode] int  NULL ,   [ErrorColumn] int  NULL)
IF OBJECT_ID(N'dbo.zERR_TRAINING_FACT',N'U') is not null DROP TABLE dbo.zERR_TRAINING_FACT

CREATE TABLE dbo.zERR_TRAINING_FACT(	FL_EXPUNGED nvarchar(50) NULL,	ID_TRAINING_FACT nvarchar(50) NULL,	ID_PRSN_TRAINING nvarchar(50) NULL,	ID_CALENDAR_DIM_COMPLETION nvarchar(50) NULL,	ID_CALENDAR_DIM_EXPIRATION nvarchar(50) NULL,	ID_PEOPLE_DIM_TRAINING_PARTICIPANT nvarchar(50) NULL,	ID_TRAINING_TYPE_DIM nvarchar(50) NULL,	FL_MEETS_REQUIREMENT nvarchar(50) NULL,	QT_HOURS nvarchar(50) NULL,	ID_PRSN nvarchar(50) NULL,	ID_SUBSTANCE_ABUSE_WIZARD_FACT nvarchar(50) NULL,	ID_SUBSTANCE_ABUSE nvarchar(50) NULL,	ID_INVESTIGATION_ASSESSMENT_FACT nvarchar(50) NULL,	ID_PEOPLE_DIM_SUBJECT nvarchar(50) NULL,	CD_DRUG_ALCOHOL_PROBLEM nvarchar(50) NULL,	TX_DRUG_ALCOHOL_PROBLEM nvarchar(200) NULL,	CD_REFER_CHEM_DEP_SRVS nvarchar(50) NULL,	TX_REFER_CHEM_DEP_SRVS nvarchar(200) NULL,	CD_SUBST_ABUSE_SRVS nvarchar(50) NULL,	TX_SUBST_ABUSE_SRVS nvarchar(200) NULL,	FL_ALCOHOL_DURING_TWELVE_MOS nvarchar(50) NULL,	FL_ALCOHOL_PRIOR_TWELVE_MOS nvarchar(50) NULL,	FL_DRUG_DURING_TWELVE_MOS nvarchar(50) NULL,	FL_DRUG_PRIOR_TWELVE_MOS nvarchar(50) NULL,	ID_PRSN_SUBJECT nvarchar(50) NULL,	ErrorCode int NULL,	ErrorColumn int NULL) 

IF OBJECT_ID(N'dbo.zERR_EDUCATION_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_FACT
CREATE TABLE dbo.zERR_EDUCATION_FACT (    ID_EDUCATION_FACT nvarchar(50),    ID_EDUC nvarchar(50),    ID_EDUC_MAIN nvarchar(50),    ID_SCHOOL_HISTORY nvarchar(50),    ID_STUDENT nvarchar(50),    ID_CALENDAR_DIM_CREATED nvarchar(50),    ID_CALENDAR_DIM_EARNED_DIPLOMA nvarchar(50),    ID_CALENDAR_DIM_ENROLLED nvarchar(50),    ID_CALENDAR_DIM_ENROLLMENT_END nvarchar(50),    ID_EDUCATION_DIM nvarchar(50),    ID_LOCATION_DIM_CASE nvarchar(50),    ID_LOCATION_DIM_CHILD nvarchar(50),    ID_PEOPLE_DIM_CHILD nvarchar(50),    ID_SCHOOL_DIM nvarchar(50),   ID_WORKER_DIM_CASE nvarchar(50),    ID_WORKER_DIM_CHILD nvarchar(50),    TX_SCHOOL_YEAR nvarchar(50),    FL_ENROLLED_FULL_TIME nvarchar(50),    FL_NO_SPECIAL_NEED nvarchar(50),    FL_NO_SPECIAL_PROVIDED nvarchar(50),    FL_OTHER nvarchar(50),    FL_PRIMARY_SCHOOL nvarchar(50),    FL_RECEIVING_SPECIAL nvarchar(50),    FL_SEVERE_BEHAVIORAL_ISSUES nvarchar(50),    FL_SPECIAL_HISTORY nvarchar(50),    FL_SPECIAL_PROVIDED nvarchar(50),    CHILD_AGE nvarchar(50),    FL_EXPUNGED nvarchar(50),    ID_PRSN_CHILD nvarchar(50),    ID_CALENDAR_DIM_ANTICIPATED_GRAD nvarchar(50),    ErrorCode int,    ErrorColumn int)

IF OBJECT_ID(N'dbo.zERR_EDUCATION_PLAN_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_PLAN_FACT
CREATE TABLE dbo.zERR_EDUCATION_PLAN_FACT (    ID_EDUCATION_PLAN_FACT nvarchar(50),    ID_EDUC_PLAN nvarchar(50),    ID_CALENDAR_DIM_PLAN_DATE nvarchar(50),    ID_EDUCATION_PLAN_DIM nvarchar(50),    ID_PEOPLE_DIM_CHILD nvarchar(50),    FL_APPLICATIONS nvarchar(50),    FL_ASSISTANCE nvarchar(50),    FL_COLLEGE_TOUR nvarchar(50),    FL_OTHER nvarchar(50),    FL_POST_PLANNING nvarchar(50),    FL_EXPUNGED nvarchar(50),    ID_PRSN_CHILD nvarchar(50),    ErrorCode int,    ErrorColumn int )	
IF OBJECT_ID(N'dbo.zERR_IL_ANSELL_CASEY_ASSESSMENT_FACT',N'U') is not null DROP TABLE dbo.zERR_IL_ANSELL_CASEY_ASSESSMENT_FACT
CREATE TABLE dbo.zERR_IL_ANSELL_CASEY_ASSESSMENT_FACT (    ID_IL_ANSELL_CASEY_ASSESSMENT_FACT nvarchar(50),    ID_IL_ANSELL_CASEY_ASSESSMENT nvarchar(50),    ID_INDEPENDENT_LIVING_FACT nvarchar(50),    CD_LEVEL nvarchar(50),    FL_YOUTH_REFUSES nvarchar(50),    ErrorCode int,    ErrorColumn int)

IF OBJECT_ID(N'dbo.zERR_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM',N'U') is not null DROP TABLE dbo.zERR_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM
CREATE TABLE dbo.zERR_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM (    ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM nvarchar(50),    CD_TYPE nvarchar(50),    TX_TYPE nvarchar(50),    CD_PARTICIPATION_STATUS nvarchar(50),    TX_PARTICIPATION_STATUS nvarchar(50),    DT_ROW_BEGIN nvarchar(50),    DT_ROW_END nvarchar(50),    ID_CYCLE nvarchar(50),    IS_CURRENT nvarchar(50),    ErrorCode int,    ErrorColumn int)	

IF OBJECT_ID(N'dbo.zERR_IL_NYTD_QUESTIONS_FACT',N'U') is not null DROP TABLE dbo.zERR_IL_NYTD_QUESTIONS_FACT
CREATE TABLE dbo.zERR_IL_NYTD_QUESTIONS_FACT (    ID_IL_NYTD_QUESTIONS_FACT nvarchar(50),    ID_IL_NYTD_QUESTIONS nvarchar(50),    ID_INDEPENDENT_LIVING_FACT nvarchar(50),    ID_IL_NYTD_QUESTIONS_ATTRIBUTE_DIM nvarchar(50),    ID_CALENDAR_DIM_SURVEY_COMPLETED nvarchar(50),    DT_SURVEY_COMPLETED nvarchar(50),    ErrorCode int,    ErrorColumn int)

IF OBJECT_ID(N'dbo.zERR_TRAINING_FACT',N'U') is not null DROP TABLE dbo.zERR_TRAINING_FACT
CREATE TABLE dbo.zERR_TRAINING_FACT (    ID_TRAINING_FACT nvarchar(50),    ID_PRSN_TRAINING nvarchar(50),    ID_CALENDAR_DIM_COMPLETION nvarchar(50),    ID_CALENDAR_DIM_EXPIRATION nvarchar(50),    ID_PEOPLE_DIM_TRAINING_PARTICIPANT nvarchar(50),    ID_TRAINING_TYPE_DIM nvarchar(50),    FL_MEETS_REQUIREMENT nvarchar(50),    QT_HOURS nvarchar(50),    FL_EXPUNGED nvarchar(50),    ID_PRSN nvarchar(50),    ErrorCode int,    ErrorColumn int)

IF OBJECT_ID(N'dbo.zERR_TRAINING_TYPE_DIM',N'U') is not null DROP TABLE dbo.zERR_TRAINING_TYPE_DIM
CREATE TABLE dbo.zERR_TRAINING_TYPE_DIM (    ID_TRAINING_TYPE_DIM nvarchar(50),    CD_TRAINING_TYPE nvarchar(50),    TX_TRAINING_TYPE nvarchar(50),    DT_ROW_BEGIN nvarchar(50),    DT_ROW_END nvarchar(50),    ID_CYCLE nvarchar(50),    IS_CURRENT nvarchar(50),    ErrorCode int,    ErrorColumn int)

IF OBJECT_ID(N'dbo.zERR_INDEPENDENT_LIVING_BRIDGE_FACT',N'U') is not null DROP TABLE dbo.zERR_INDEPENDENT_LIVING_BRIDGE_FACT
CREATE TABLE dbo.zERR_INDEPENDENT_LIVING_BRIDGE_FACT (    ID_INDEPENDENT_LIVING_BRIDGE_FACT nvarchar(50),    ID_INDEPENDENT_LIVING_FACT nvarchar(50),    ID_IL_SERVICE_CATERY_TYPE_DIM nvarchar(50),    ErrorCode int,    ErrorColumn int)	

IF OBJECT_ID(N'dbo.zERR_INDEPENDENT_LIVING_FACT',N'U') is not null DROP TABLE dbo.zERR_INDEPENDENT_LIVING_FACT
CREATE TABLE dbo.zERR_INDEPENDENT_LIVING_FACT(	ID_INDEPENDENT_LIVING_FACT nvarchar(50) NULL,	ID_INDEPENDENT_LIVING nvarchar(50) NULL,	ID_PRSN nvarchar(50) NULL,	ID_CALENDAR_DIM_ANTICIPATED_OUT_CARE nvarchar(50) NULL,	ID_CALENDAR_DIM_BEGAN nvarchar(50) NULL,	ID_CALENDAR_DIM_IL_PLAN_COMPLETED nvarchar(50) NULL,	ID_CALENDAR_DIM_INITIAL_IL_REFERRAL nvarchar(50) NULL,	ID_CALENDAR_DIM_REFERRED nvarchar(50) NULL,	ID_CALENDAR_DIM_YOUTH_NOT_PARTICIPATING nvarchar(50) NULL,	ID_PEOPLE_DIM nvarchar(50) NULL,	FL_YOUTH_REFERRED nvarchar(50) NULL,	FL_YOUTH_RECEIVING nvarchar(50) NULL,	FL_YOUTH_NOT_PARTICIPATING nvarchar(50) NULL)

IF OBJECT_ID(N'dbo.zERR_TANF_FACT',N'U') is not null DROP TABLE dbo.zERR_TANF_FACT
CREATE TABLE dbo.zERR_TANF_FACT (    ID_TANF_FACT nvarchar(50),    ID_AUTH nvarchar(50),    ID_TANF nvarchar(50),    ID_CALENDAR_DIM_BEGIN nvarchar(50),    ID_CALENDAR_DIM_END nvarchar(50),    ID_CASE_DIM nvarchar(50),    ID_PEOPLE_DIM nvarchar(50),    ID_TANF_DIM nvarchar(50),    ID_WORKER_DIM_COMPLETED nvarchar(50),    ID_WORKER_DIM_DETERMINATION nvarchar(50),    FL_VOID nvarchar(50),    ID_PRSN nvarchar(50),    ID_CASE nvarchar(50),    ErrorCode int,    ErrorColumn int)	

IF OBJECT_ID(N'dbo.zERR_TANF_DIM',N'U') is not null DROP TABLE dbo.zERR_TANF_DIM
CREATE TABLE dbo.zERR_TANF_DIM (    ID_TANF_DIM nvarchar(50),    CD_APPLICATION_CHILD_UNDER_18 nvarchar(50),    TX_APPLICATION_CHILD_UNDER_18 nvarchar(50),    CD_ELIGIBILITY_DECISION nvarchar(50),    TX_ELIGIBILITY_DECISION nvarchar(50),    CD_EMERGENCY_ASSISTANCE_EXIST nvarchar(50),    TX_EMERGENCY_ASSISTANCE_EXIST nvarchar(50),    CD_TANF_STAT nvarchar(50),    TX_TANF_STAT nvarchar(50),    DT_ROW_BEGIN nvarchar(50),    DT_ROW_END nvarchar(50),    ID_CYCLE nvarchar(50),    IS_CURRENT nvarchar(50),	   ErrorCode int,    ErrorColumn int)	

IF OBJECT_ID(N'dbo.zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT',N'U') is not null DROP TABLE dbo.zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT
CREATE TABLE dbo.zERR_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT (    ID_EDUCATION_RECORDS_REQUEST_REFERRAL_FACT nvarchar(50),    ID_REQUEST nvarchar(50),    ID_REFERRAL nvarchar(50),    ID_EDUCATION_FACT nvarchar(50),    ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM nvarchar(50),    ID_CALENDAR_DIM_REQUESTED nvarchar(50),    ID_CALENDAR_DIM_RECEIVED nvarchar(50),    ID_CALENDAR_DIM_REFERRAL nvarchar(50),    DT_REQUESTED nvarchar(50),    DT_RECEIVED nvarchar(50),    DT_REFERRAL nvarchar(50),    FL_EXPUNGED nvarchar(50),    ID_EDUC nvarchar(50),    ErrorCode int,    ErrorColumn int)
   
CREATE TABLE dbo.zERR_CASE_PARTICIPANT_STATUS_DIM (
    [ID_CASE_PARTICIPANT_STATUS_DIM] nvarchar(50),
    [ID_CASE] nvarchar(50),
    [ID_PRSN] nvarchar(50),
    [ID_CASE_DIM] nvarchar(50),
    [ID_PEOPLE_DIM] nvarchar(50),
    [CD_PARTICIPANT_STATUS] nvarchar(50),
    [TX_PARTICIPANT_STATUS] nvarchar(50),
    [CD_PARTICIPANT_STATUS_REASON] nvarchar(50),
    [TX_PARTICIPANT_STATUS_REASON] nvarchar(50),
    [DT_ROW_BEGIN] nvarchar(50),
    [DT_ROW_END] nvarchar(50),
    [ID_CYCLE] nvarchar(50),
    [IS_CURRENT] nvarchar(50),
    [ErrorCode] int,
    [ErrorColumn] int
  )   


  --DROP TABLE dbo.zERR_rptPlacement
   CREATE TABLE dbo.zERR_rptPlacement (
    [TableKey] nvarchar(50),
    [ID_REMOVAL_EPISODE_FACT] nvarchar(50),
    [CHILD] nvarchar(50),
    [ID_CASE] nvarchar(50),
    [CD_CASE_TYPE] nvarchar(50),
    [TX_CASE_TYPE] nvarchar(200),
    [TX_REGION] nvarchar(200),
    [CD_REGION] nvarchar(50),
    [TX_OFFICE] nvarchar(200),
    [CD_OFFICE] nvarchar(50),
    [TX_County] nvarchar(200),
    [CD_County] nvarchar(50),
    [PRIMARY_WORKER] nvarchar(50),
    [WORKER_REGION] nvarchar(200),
    [CD_WORKER_REGION] nvarchar(50),
    [WORKER_OFFICE] nvarchar(200),
    [CD_WORKER_OFFICE] nvarchar(50),
    [WORKER_COUNTY] nvarchar(200),
    [CD_WORKER_COUNTY] nvarchar(50),
    [WORKER_UNIT] nvarchar(200),
    [EPISODE_LOS] nvarchar(50),
    [EPISODE_LOS_GRP] nvarchar(200),
    [PLACEMENT_LOS] nvarchar(50),
    [PLACEMENT_LOS_GRP] nvarchar(200),
    [REMOVAL_DT] nvarchar(50),
    [ID_CALENDAR_DIM_BEGIN] nvarchar(50),
    [ID_EPSD] nvarchar(50),
    [ID_PLACEMENT_FACT] nvarchar(50),
    [LATEST_PLCMNT_DT] nvarchar(50),
    [LATEST_PLCMNT_END_DT] nvarchar(50),
    [LAST_END_RSN] nvarchar(200),
    [ID_PRVD_ORG_CAREGIVER] nvarchar(50),
    [DISCHARGE_DT] nvarchar(50),
    [ID_CALENDAR_DIM_AFCARS_END] nvarchar(50),
    [TX_EPSD_TYPE] nvarchar(200),
    [CD_EPSD_TYPE] nvarchar(50),
    [BIRTHDATE] nvarchar(50),
    [TX_GNDR] nvarchar(50),
    [CHILD_AGE] nvarchar(50),
    [TX_BRAAM_RACE] nvarchar(200),
    [TX_MULTIRACE] nvarchar(200),
    [SETTING] nvarchar(200),
    [TX_SUBCTGRY] nvarchar(200),
    [RELATIVE] nvarchar(200),
    [CD_REL] nvarchar(50),
    [TX_REL] nvarchar(200),
    [CURRENT_SETTING] nvarchar(200),
    [CURRENT_SERVICE] nvarchar(200),
    [REMOVAL] nvarchar(50),
    [EXIT] nvarchar(50),
    [EXIT_REASON] nvarchar(200),
    [TX_PLACEMENT_CARE_AUTH] nvarchar(200),
    [TX_LGL_STAT] nvarchar(200),
    [TX_PLCM_DSCH_RSN] nvarchar(200),
    [TX_DSCH_RSN] nvarchar(200),
    [TRH] nvarchar(50),
    [TS_UP] nvarchar(50),
    [RunTime] nvarchar(50),
    [Mom_ID] nvarchar(50),
    [Dad_ID] nvarchar(50),
    [Placement_Worker_ID] nvarchar(50),
    [Placement_Worker_Region] nvarchar(200),
    [Placement_Worker_Region_CD] nvarchar(50),
    [Placement_Worker_Office] nvarchar(200),
    [Placement_Worker_Office_CD] nvarchar(50),
    [Placement_Worker_County] nvarchar(200),
    [Placement_Worker_County_CD] nvarchar(50),
    [Placement_Worker_Unit] nvarchar(200),
    [Placement_WorkerINT_Level] nvarchar(50),
    [Placement_WorkerINT_Reason] nvarchar(200),
    [staddress] nvarchar(200),
    [town] nvarchar(200),
    [zip] nvarchar(50),
    [cd_cnty] nvarchar(50),
    [staddress_type] nvarchar(200),
    [town_type] nvarchar(200),
    [zip_type] nvarchar(200),
    [cnty_type] nvarchar(200),
    [state] nvarchar(200),
    [FL_ABANDONMENT] nvarchar(50),
    [FL_CARETAKER_INABILITY_COPE] nvarchar(50),
    [FL_CHILD_ABUSE_ALCOHOL] nvarchar(50),
    [FL_CHILD_ABUSES_DRUG] nvarchar(50),
    [FL_CHILD_BEHAVIOR_PROBLEMS] nvarchar(50),
    [FL_INADEQUATE_HOUSNG] nvarchar(50),
    [FL_NEGLECT] nvarchar(50),
    [FL_PARENT_ABUSE_ALCOHOL] nvarchar(50),
    [FL_PARENT_DEATH] nvarchar(50),
    [FL_PARENT_DRUG_ABUSE] nvarchar(50),
    [FL_PARENT_INCARCERATION] nvarchar(50),
    [FL_PHYSICAL_ABUSE] nvarchar(50),
    [FL_SEX_ABUSE] nvarchar(50),
    [FL_RELINQUISHMENT] nvarchar(50),
    [PRIMARY_PPLN] nvarchar(50),
    [CD_PRIMARY_PPLN] nvarchar(50),
    [ALT_PPLN] nvarchar(50),
    [LF_DT] nvarchar(50),
    [CD_ALT_PPLN] nvarchar(50),
    [MULTI_RACE_MASK] nvarchar(50),
    [CD_HSPNC] nvarchar(50),
    [TX_HSPNC] nvarchar(50),
    [TX_TRIBE_NAME] nvarchar(200),
    [RE-ENTRY] nvarchar(50),
    [FL_FALSE] nvarchar(50),
    [DT_CASE_cls] nvarchar(50),
    [H&S] nvarchar(50),
    [VISIT_SPAN] nvarchar(50),
    [LLS_DT] nvarchar(50),
    [VPA_LNGTH] nvarchar(50),
    [CD_RMVL_MNR] nvarchar(50),
    [TX_RMVL_MNR] nvarchar(200),
    [CD_PLACEMENT_CARE_AUTH] nvarchar(50),
    [ORIG_CD_PLCM_DSCH_RSN] nvarchar(50),
    [ORIG_TX_PLCM_DSCH_RSN] nvarchar(200),
    [FL_CHILD_CLINICALLY_DIAGNOSED] nvarchar(200),
    [BDAY18] nvarchar(50),
    [CD_MULTI_RACE_ETHNICITY] nvarchar(50),
    [TX_MULTI_RACE_ETHNICITY] nvarchar(200),
	[REMOVAL_QTR] nvarchar(50),
	[DISCHARGE_QTR] nvarchar(50),
	[FIRST_SETTING] nvarchar(200),
	[FIRST_RELATIVE] nvarchar(50),
    [ErrorCode] int,
    [ErrorColumn] int
)
CREATE TABLE [dbo].[zERR_rptPlacement_Events](
	[Row_ID] [nvarchar](50) NULL,
	[id_removal_episode_fact] [nvarchar](50) NULL,
	[RMVL_SEQ] [nvarchar](50) NULL,
	[child] [nvarchar](50) NULL,
	[birthdate] [nvarchar](50) NULL,
	[tx_gndr] [nvarchar](50) NULL,
	[bday] [nvarchar](50) NULL,
	[tx_braam_race] [nvarchar](200) NULL,
	[tx_multirace] [nvarchar](200) NULL,
	[id_case] [nvarchar](50) NULL,
	[tx_region] [nvarchar](200) NULL,
	[worker_region] [nvarchar](200) NULL,
	[worker_office] [nvarchar](200) NULL,
	[worker_unit] [nvarchar](200) NULL,
	[episode_los] [nvarchar](50) NULL,
	[episode_los_grp] [nvarchar](200) NULL,
	[removal_dt] [nvarchar](50) NULL,
	[removal_year] [nvarchar](50) NULL,
	[removal_sfy_name] [nvarchar](200) NULL,
	[removal_cy_name] [nvarchar](200) NULL,
	[discharge_dt] [nvarchar](50) NULL,
	[discharge_year] [nvarchar](50) NULL,
	[discharge_sfy_name] [nvarchar](200) NULL,
	[discharge_cy_name] [nvarchar](200) NULL,
	[exit_reason] [nvarchar](200) NULL,
	[last_pca] [nvarchar](200) NULL,
	[last_lgl_stat] [nvarchar](200) NULL,
	[id_epsd] [nvarchar](50) NULL,
	[id_prvd_org_caregiver] [nvarchar](50) NULL,
	[id_bsns] [nvarchar](50) NULL,
	[tx_provider_type] [nvarchar](200) NULL,
	[current_prvd_status] [nvarchar](50) NULL,
	[id_ssps] [nvarchar](50) NULL,
	[id_calendar_dim_begin] [nvarchar](50) NULL,
	[id_calendar_dim_end] [nvarchar](50) NULL,
	[age_plcm_begin] [nvarchar](50) NULL,
	[begin_date] [nvarchar](50) NULL,
	[begin_year] [nvarchar](50) NULL,
	[begin_year_name] [nvarchar](200) NULL,
	[begin_state_fiscal_year_name] [nvarchar](200) NULL,
	[begin_month] [nvarchar](50) NULL,
	[begin_month_name] [nvarchar](200) NULL,
	[end_date] [nvarchar](50) NULL,
	[end_year] [nvarchar](50) NULL,
	[end_year_name] [nvarchar](200) NULL,
	[end_state_fiscal_year_name] [nvarchar](200) NULL,
	[end_month] [nvarchar](50) NULL,
	[end_month_name] [nvarchar](200) NULL,
	[age_plcm_end] [nvarchar](50) NULL,
	[plcmnt_days] [nvarchar](50) NULL,
	[tx_plcm_setng] [nvarchar](200) NULL,
	[tx_srvc] [nvarchar](200) NULL,
	[tx_srvc_ctgry] [nvarchar](200) NULL,
	[tx_subctgry] [nvarchar](200) NULL,
	[tx_end_rsn] [nvarchar](200) NULL,
	[plcmnt_type] [nvarchar](200) NULL,
	[post_brs] [nvarchar](50) NULL,
	[brs_id] [nvarchar](50) NULL,
	[brs_nm] [nvarchar](200) NULL,
	[BRS_bsns] [nvarchar](200) NULL,
	[BRS_srvc] [nvarchar](200) NULL,
	[BRS_srvc_ctgry] [nvarchar](50) NULL,
	[BRS_subctgry] [nvarchar](50) NULL,
	[BRS_plcm_setng] [nvarchar](200) NULL,
	[BRS_plcmnt_days] [nvarchar](50) NULL,
	[days_from_rmvl] [nvarchar](50) NULL,
	[days_to_dsch] [nvarchar](50) NULL,
	[plcmnt_seq] [nvarchar](50) NULL,
	[days_to_dsch_grp] [nvarchar](200) NULL,
	[days_from_rmvl_grp] [nvarchar](200) NULL,
	[CD_PLCM_SETNG] [nvarchar](50) NULL,
	[RunDate] [nvarchar](50) NULL,
	[primary_plan] [nvarchar](200) NULL,
	[alt_plan] [nvarchar](200) NULL,
	[ErrorCode] [int] NULL,
	[ErrorColumn] [int] NULL
);

