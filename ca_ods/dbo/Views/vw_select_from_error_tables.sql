﻿
CREATE view  [dbo].[vw_select_from_error_tables]
as

select distinct  'ZERR_ABUSE_FACT' as Error_Table_Name,ID_ABUSE_FACT as ID_COLUMN_IN_TABLE FROM ZERR_ABUSE_FACT
union all
select distinct  'ZERR_ABUSE_TYPE_DIM',ID_ABUSE_TYPE_DIM FROM ZERR_ABUSE_TYPE_DIM
union all
select distinct  'ZERR_ADOPTION_FACT',ID_ADOPTION_FACT FROM ZERR_ADOPTION_FACT
union all
select distinct  'ZERR_ADOPTION_STATUS_DIM',ID_ADOPTION_STATUS_DIM FROM ZERR_ADOPTION_STATUS_DIM
union all
select distinct  'ZERR_AGREEMENT_DIM',ID_AGREEMENT_DIM FROM ZERR_AGREEMENT_DIM
union all
select distinct  'ZERR_ALLEGATION_FACT',ID_ALLEGATION_FACT FROM ZERR_ALLEGATION_FACT
union all
select distinct  'ZERR_ASSIGNMENT_ATTRIBUTE_DIM',ID_ASSIGNMENT_ATTRIBUTE_DIM FROM ZERR_ASSIGNMENT_ATTRIBUTE_DIM
union all
select distinct  'ZERR_ASSIGNMENT_FACT',ID_ASSIGNMENT_FACT FROM ZERR_ASSIGNMENT_FACT
union all
select distinct  'ZERR_AUTHORIZATION_DIM',ID_AUTHORIZATION_DIM FROM ZERR_AUTHORIZATION_DIM
union all
select distinct  'ZERR_AUTHORIZATION_FACT',ID_AUTHORIZATION_FACT FROM ZERR_AUTHORIZATION_FACT
union all
select distinct  'ZERR_CALENDAR_DIM',ID_CALENDAR_DIM FROM ZERR_CALENDAR_DIM
union all
select distinct  'ZERR_CASE_DIM',ID_CASE_DIM FROM ZERR_CASE_DIM
union all
select distinct  'ZERR_CASE_NOTE_TYPE_DIM',ID_CASE_NOTE_TYPE_DIM FROM ZERR_CASE_NOTE_TYPE_DIM
union all
select distinct  'ZERR_CASE_NOTE_FACT',ID_CASE_NOTE_FACT FROM ZERR_CASE_NOTE_FACT
union all
select distinct  'ZERR_CASE_PARTICIPANT_FACT',ID_CASE_PARTICIPANT_FACT FROM ZERR_CASE_PARTICIPANT_FACT
union all
select distinct  'ZERR_CHART_OF_ACCOUNTS_DIM',ID_CHART_OF_ACCOUNTS_DIM FROM ZERR_CHART_OF_ACCOUNTS_DIM
union all
select distinct  'ZERR_DISCHARGE_REASON_DIM',ID_DISCHARGE_REASON_DIM FROM ZERR_DISCHARGE_REASON_DIM
union all
select distinct  'ZERR_DISPOSITION_DIM',ID_DISPOSITION_DIM FROM ZERR_DISPOSITION_DIM
union all
select distinct  'ZERR_DLR_RISK_ASSESSMENT_FACT',ID_DLR_RISK_ASSESSMENT_FACT FROM ZERR_DLR_RISK_ASSESSMENT_FACT
union all
select distinct  'ZERR_EDUCATION_DIM',ID_EDUCATION_DIM FROM ZERR_EDUCATION_DIM
union all
select distinct  'ZERR_EDUCATION_PLAN_DIM',ID_EDUCATION_PLAN_DIM FROM ZERR_EDUCATION_PLAN_DIM
union all
select distinct  'ZERR_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM',ID_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM FROM ZERR_EDUCATION_RECORDS_REQUEST_REFERRAL_DIM
union all
select distinct  'ZERR_ELIGIBILITY_REMOVAL_HOME_DIM',ID_ELIGIBILITY_REMOVAL_HOME_DIM FROM ZERR_ELIGIBILITY_REMOVAL_HOME_DIM
union all
select distinct  'ZERR_ELIGIBILITY_FACT',ID_ELIGIBILITY_FACT FROM ZERR_ELIGIBILITY_FACT
union all
select distinct  'ZERR_ELIGIBILITY_DIM',ID_ELIGIBILITY_DIM FROM ZERR_ELIGIBILITY_DIM
union all
select distinct  'ZERR_ELIG_EPISODE_FACT',ID_ELIG_EPISODE_FACT FROM ZERR_ELIG_EPISODE_FACT
union all
select distinct  'ZERR_ELIGIBILITY_STATUS_DIM',ID_ELIGIBILITY_STATUS_DIM FROM ZERR_ELIGIBILITY_STATUS_DIM
union all
select distinct  'ZERR_FAMILY_STRUCTURE_DIM',ID_FAMILY_STRUCTURE_DIM FROM ZERR_FAMILY_STRUCTURE_DIM
union all
select distinct  'ZERR_FINDINGS_DIM',ID_FINDINGS_DIM FROM ZERR_FINDINGS_DIM
union all
select distinct  'ZERR_HEALTH_ACTIVITY_FACT',ID_HEALTH_ACTIVITY_FACT FROM ZERR_HEALTH_ACTIVITY_FACT
union all
select distinct  'ZERR_HEALTH_ACTIVITY_TYPE_DIM',ID_HEALTH_ACTIVITY_TYPE_DIM FROM ZERR_HEALTH_ACTIVITY_TYPE_DIM
union all
select distinct  'ZERR_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT',ID_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT FROM ZERR_HEALTH_CAT_ATTRIBUTE_BRIDGE_FACT
union all
select distinct  'ZERR_INTAKE_ATTRIBUTE_DIM',ID_INTAKE_ATTRIBUTE_DIM FROM ZERR_INTAKE_ATTRIBUTE_DIM
union all
select distinct  'ZERR_INTAKE_FACT',ID_INTAKE_FACT FROM ZERR_INTAKE_FACT
union all
select distinct  'ZERR_INTAKE_TYPE_DIM',ID_INTAKE_TYPE_DIM FROM ZERR_INTAKE_TYPE_DIM
union all
select distinct  'ZERR_INTAKE_SERVICE_BRIDGE_FACT',ID_INTAKE_SERVICE_BRIDGE_FACT FROM ZERR_INTAKE_SERVICE_BRIDGE_FACT
union all
select distinct  'ZERR_INTAKE_PARTICIPANT_ROLES_DIM',ID_INTAKE_PARTICIPANT_ROLES_DIM FROM ZERR_INTAKE_PARTICIPANT_ROLES_DIM
union all
select distinct  'ZERR_INTAKE_VICTIM_FACT',ID_INTAKE_VICTIM_FACT FROM ZERR_INTAKE_VICTIM_FACT
union all
select distinct  'ZERR_INVESTIGATION_ASSESSMENT_FACT',ID_INVESTIGATION_ASSESSMENT_FACT FROM ZERR_INVESTIGATION_ASSESSMENT_FACT
union all  
select distinct  'ZERR_INVESTIGATION_TYPE_DIM',ID_INVESTIGATION_TYPE_DIM FROM ZERR_INVESTIGATION_TYPE_DIM
union all  
select distinct  'ZERR_LEGAL_ACTION_DIM',ID_LEGAL_ACTION_DIM FROM ZERR_LEGAL_ACTION_DIM
union all 
select distinct  'ZERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT',ID_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT FROM ZERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT
union all 
select distinct  'ZERR_LEGAL_FACT',ID_LEGAL_FACT FROM ZERR_LEGAL_FACT
union all  
select distinct  'ZERR_LEGAL_JURISDICTION_DIM',ID_LEGAL_JURISDICTION_DIM FROM ZERR_LEGAL_JURISDICTION_DIM
union all  
select distinct  'ZERR_LEGAL_RESULT_DIM',ID_LEGAL_RESULT_DIM FROM ZERR_LEGAL_RESULT_DIM
union all  
select distinct  'ZERR_LEGAL_STATUS_DIM',ID_LEGAL_STATUS_DIM FROM ZERR_LEGAL_STATUS_DIM
union all  
select distinct  'ZERR_LEGAL_TPR_REFERRAL_FACT',ID_LEGAL_TPR_REFERRAL_FACT FROM ZERR_LEGAL_TPR_REFERRAL_FACT
union all  
select distinct  'ZERR_LICENSE_ACTION_FACT',ID_LICENSE_ACTION_FACT FROM ZERR_LICENSE_ACTION_FACT
union all  
select distinct  'ZERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT',ID_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT FROM ZERR_LEGAL_AGGRAVATED_CIRCUMSTANCES_FACT
union all  
select distinct  'ZERR_LICENSE_ATTRIB_DIM',ID_LICENSE_ATTRIB_DIM FROM ZERR_LICENSE_ATTRIB_DIM
union all  
select distinct  'ZERR_LICENSE_FACT',ID_LICENSE_FACT FROM ZERR_LICENSE_FACT
union all  
select distinct  'ZERR_LOCATION_DIM',ID_LOCATION_DIM FROM ZERR_LOCATION_DIM
union all  
select distinct  'ZERR_MENTAL_HEALTH_EVAL_DIM',ID_MENTAL_HEALTH_EVAL_DIM FROM ZERR_MENTAL_HEALTH_EVAL_DIM
union all  
select distinct  'ZERR_PAYMENT_DETAIL_FACT',ID_PAYMENT_DETAIL_FACT FROM ZERR_PAYMENT_DETAIL_FACT
union all  
select distinct  'ZERR_PAYMENT_DETAIL_DIM',ID_PAYMENT_DETAIL_DIM FROM ZERR_PAYMENT_DETAIL_DIM
union all  
select distinct  'ZERR_PAYMENT_DIM',ID_PAYMENT_DIM FROM ZERR_PAYMENT_DIM
union all  
select distinct  'ZERR_PAYMENT_FACT',ID_PAYMENT_FACT FROM ZERR_PAYMENT_FACT
union all  
select distinct  'ZERR_PEOPLE_DIM',ID_PEOPLE_DIM FROM ZERR_PEOPLE_DIM
union all  
select distinct  'ZERR_PERMANENCY_FACT',ID_PERMANENCY_FACT FROM ZERR_PERMANENCY_FACT
union all  
select distinct  'ZERR_PERMANENCY_PLAN_DIM',ID_PERMANENCY_PLAN_DIM FROM ZERR_PERMANENCY_PLAN_DIM
union all  
select distinct  'ZERR_PLACEMENT_CARE_AUTH_DIM',ID_PLACEMENT_CARE_AUTH_DIM FROM ZERR_PLACEMENT_CARE_AUTH_DIM
union all  
select distinct  'ZERR_PLACEMENT_CARE_AUTH_FACT',ID_PLACEMENT_CARE_AUTH_FACT FROM ZERR_PLACEMENT_CARE_AUTH_FACT
union all  
select distinct  'ZERR_PLACEMENT_FACT',ID_PLACEMENT_FACT FROM ZERR_PLACEMENT_FACT
union all  
select distinct  'ZERR_PLACEMENT_RESULT_DIM',ID_PLACEMENT_RESULT_DIM FROM ZERR_PLACEMENT_RESULT_DIM
union all  
select distinct  'ZERR_PLACEMENT_TYPE_DIM',ID_PLACEMENT_TYPE_DIM FROM ZERR_PLACEMENT_TYPE_DIM
union all   
select distinct  'ZERR_PRE_ADOPTION_LEGAL_FACT',ID_PRE_ADOPTION_LEGAL_FACT FROM ZERR_PRE_ADOPTION_LEGAL_FACT
union all
select distinct  'ZERR_PRIMARY_ASSIGNMENT_FACT',ID_PRIMARY_ASSIGNMENT_FACT FROM ZERR_PRIMARY_ASSIGNMENT_FACT
union all
select distinct  'ZERR_PROVIDER_DIM',ID_PROVIDER_DIM FROM ZERR_PROVIDER_DIM
union all  
select distinct  'ZERR_PROVIDER_NOTES_TYPE_DIM',ID_PROVIDER_NOTES_TYPE_DIM FROM ZERR_PROVIDER_NOTES_TYPE_DIM
union all  
select distinct  'ZERR_PROVIDER_PART_FACT',ID_PROVIDER_PART_FACT FROM ZERR_PROVIDER_PART_FACT
union all   
select distinct  'ZERR_PROVIDER_SERVICE_LICENSE_FACT',ID_PROVIDER_SERVICE_LICENSE_FACT FROM ZERR_PROVIDER_SERVICE_LICENSE_FACT
union all  
select distinct  'ZERR_RELATIONSHIP_DIM',ID_RELATIONSHIP_DIM FROM ZERR_RELATIONSHIP_DIM
union all  
select distinct  'ZERR_REMOVAL_DIM',ID_REMOVAL_DIM FROM ZERR_REMOVAL_DIM
union all  
select distinct  'ZERR_REMOVAL_EPISODE_FACT',ID_REMOVAL_EPISODE_FACT FROM ZERR_REMOVAL_EPISODE_FACT
union all  
select distinct  'ZERR_REPEAT_MALTREATMENT_FACT',ID_REPEAT_MALTREATMENT_FACT FROM ZERR_REPEAT_MALTREATMENT_FACT
union all  
select distinct  'ZERR_RESPONSE_TIME_EXP_DIM',ID_RESPONSE_TIME_EXP_DIM FROM ZERR_RESPONSE_TIME_EXP_DIM
union all  
select distinct  'ZERR_RGAP_AGREEMENT_ATTRIBUTE_DIM',ID_RGAP_AGREEMENT_ATTRIBUTE_DIM FROM ZERR_RGAP_AGREEMENT_ATTRIBUTE_DIM
union all   
 select distinct  'ZERR_RGAP_AGREEMENT_FACT',ID_RGAP_AGREEMENT_FACT FROM ZERR_RGAP_AGREEMENT_FACT
 union all 
 select distinct  'ZERR_RGAP_ELIGIBILITY_FACT',ID_RGAP_ELIGIBILITY_FACT FROM ZERR_RGAP_ELIGIBILITY_FACT
 union all 
 select distinct  'ZERR_RGAP_ELIGIBILITY_STATUS_DIM',ID_RGAP_ELIGIBILITY_STATUS_DIM FROM ZERR_RGAP_ELIGIBILITY_STATUS_DIM
 union all 
 select distinct  'ZERR_SAFETY_ASSESSMENT_FACT',ID_SAFETY_ASSESSMENT_FACT FROM ZERR_SAFETY_ASSESSMENT_FACT
 union all 
 select distinct  'ZERR_SCHOOL_DIM',ID_SCHOOL_DIM FROM ZERR_SCHOOL_DIM
 union all 
 select distinct  'ZERR_SERVICE_FACT',ID_SERVICE_FACT FROM ZERR_SERVICE_FACT
 union all 
 select distinct  'ZERR_SERVICE_REFERRAL_DIM',ID_SERVICE_REFERRAL_DIM FROM ZERR_SERVICE_REFERRAL_DIM
 union all 
 select distinct  'ZERR_SERVICE_TYPE_DIM',ID_SERVICE_TYPE_DIM FROM ZERR_SERVICE_TYPE_DIM
 union all 
 select distinct  'ZERR_SIBLING_RELATIONSHIP_FACT',ID_SIBLING_RELATIONSHIP_FACT FROM ZERR_SIBLING_RELATIONSHIP_FACT
 union all 
 select distinct  'ZERR_SOURCE_FUNDS_DIM',ID_SOURCE_FUNDS_DIM FROM ZERR_SOURCE_FUNDS_DIM
 union all 
 select distinct  'ZERR_SUBSTANCE_ABUSE_WIZARD_FACT',ID_SUBSTANCE_ABUSE_WIZARD_FACT FROM ZERR_SUBSTANCE_ABUSE_WIZARD_FACT
 union all 
 select distinct  'ZERR_TRIBE_ATTRIBUTE_DIM',ID_TRIBE_ATTRIBUTE_DIM FROM ZERR_TRIBE_ATTRIBUTE_DIM
 union all  
 select distinct  'ZERR_TRIBE_DIM',ID_TRIBE_DIM FROM ZERR_TRIBE_DIM
 union all 
 select distinct  'ZERR_TRIBE_FACT',ID_TRIBE_FACT FROM ZERR_TRIBE_FACT
 union all 
 select distinct  'ZERR_WORKER_DIM',ID_WORKER_DIM FROM ZERR_WORKER_DIM
  