select id_case_dim from CASE_PARTICIPANT_FACT except select id_case_dim from case_dim
select id_people_dim from CASE_PARTICIPANT_FACT except select id_people_dim from PEOPLE_DIM
select ID_EDUCATION_FACT from EDUCATION_RECORDS_REQUEST_REFERRAL_FACT 
except
select ID_EDUCATION_FACT from EDUCATION_FACT
select id_intake_fact from INTAKE_PARTICIPANT_FACT
except
select id_intake_fact from INTAKE_FACT

select id_investigation_assessment_Fact from SUBSTANCE_ABUSE_WIZARD_FACT
except
select id_investigation_assessment_Fact from INVESTIGATION_ASSESSMENT_FACT

select id_case_dim from CASE_PARTICIPANT_STATUS_DIM
except
select id_case_dim from case_dim

select ID_PEOPLE_DIM from CASE_PARTICIPANT_STATUS_DIM
except
select ID_PEOPLE_DIM from PEOPLE_DIM

select id_case_dim from case_participant_fact
except
select id_case_dim from case_dim

