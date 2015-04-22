  create view dbo.ref_bin_sibling_group_size
  as 
  select distinct bin_sibling_group_size,nbr_sibling_desc from prm_sib