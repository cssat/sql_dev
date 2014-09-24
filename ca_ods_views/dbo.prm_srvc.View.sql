

alter  VIEW [dbo].[prm_srvc] AS 
select ref_match_srvc_type_category.cd_subctgry_poc_fr AS cd_subctgry_poc_frc,ref_match_srvc_type_category.int_filter_service_category 
AS match_code from ref_match_srvc_type_category 
where (ref_match_srvc_type_category.cd_subctgry_poc_fr <> 0) union select 0 ,ref_match_srvc_type_category.int_filter_service_category AS filter_srvc_type 
from ref_match_srvc_type_category where (ref_match_srvc_type_category.cd_subctgry_poc_fr <> 0) union select cd_subctgry_poc_fr,int_filter_service_category from ref_match_srvc_type_category where cd_subctgry_poc_fr=0
GO



