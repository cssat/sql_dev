

CREATE  VIEW  dbo.prm_office_collapse AS 
select "ref"."cd_office" AS "cd_office","ref"."cd_office" AS "match_code" from "ref_lookup_office_collapse" "ref" where ("ref"."cd_office" > 0) union select 0 AS "0","ref"."cd_office" AS "cd_office" from "ref_lookup_office_collapse" "ref" where ("ref"."cd_office" <> 0) 

