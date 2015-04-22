CREATE  VIEW dbo.prm_dep AS 
select ref_filter_dependency.bin_dep_cd AS bin_dep_cd,ref_filter_dependency.bin_dep_cd AS match_code 
from ref_filter_dependency where (ref_filter_dependency.bin_dep_cd <> 0) union select 0 ,ref_filter_dependency.bin_dep_cd AS match_code 
from ref_filter_dependency where (ref_filter_dependency.bin_dep_cd <> 0)