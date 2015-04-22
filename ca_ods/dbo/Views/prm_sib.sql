create  VIEW dbo.prm_sib AS 

select ref_lookup_sibling_groups.nbr_siblings [bin_sibling_group_size]
,ref_lookup_sibling_groups.sibling_group_name [nbr_sibling_desc]
,ref_lookup_sibling_groups.nbr_siblings [match_code] 
from ref_lookup_sibling_groups 
where (ref_lookup_sibling_groups.Nbr_Siblings > 0) 

union select 0,qall.Sibling_Group_Name 
,ref_lookup_sibling_groups.nbr_siblings
from ref_lookup_sibling_groups ,ref_lookup_sibling_groups qall 
where ((ref_lookup_sibling_groups.nbr_siblings > 0) and (qall.nbr_siblings = 0))