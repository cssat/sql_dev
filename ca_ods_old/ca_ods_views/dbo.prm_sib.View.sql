USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_sib]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  VIEW [dbo].[prm_sib] AS 

select ref_lookup_sibling_groups.nbr_siblings [bin_sibling_group_size]
,ref_lookup_sibling_groups.sibling_group_name [nbr_sibling_desc]
,ref_lookup_sibling_groups.nbr_siblings [match_code] 
from ref_lookup_sibling_groups 
where (ref_lookup_sibling_groups.Nbr_Siblings > 0) 

union select 0,qall.Sibling_Group_Name 
,ref_lookup_sibling_groups.nbr_siblings
from ref_lookup_sibling_groups ,ref_lookup_sibling_groups qall 
where ((ref_lookup_sibling_groups.nbr_siblings > 0) and (qall.nbr_siblings = 0))
GO
