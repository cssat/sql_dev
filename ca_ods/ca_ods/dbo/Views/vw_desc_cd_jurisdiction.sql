create view dbo.vw_desc_cd_jurisdiction as
select distinct cd_jurisdiction,tx_jurisdiction , replace(tx_jurisdiction,'County','') [county],county_cd
from LEGAL_JURISDICTION_DIM 
join ref_lookup_county  cnty on cnty.county_desc= replace(tx_jurisdiction,'County','')
where TX_JURISDICTION <> 'Failed'