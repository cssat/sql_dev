

select count(*) from dbo.intake_fact where year(DT_ACCESS_RCVD) between 2004 and 2010 --629176

select count(distinct inf.id_intake_fact) from dbo.intake_fact inf left join dbo.intake_type_dim itd
					on itd.id_intake_type_dim = inf.id_intake_type_dim
		left join dbo.intake_attribute_dim iad on iad.id_intake_attribute_dim=inf.id_intake_attribute_dim
 where year(DT_ACCESS_RCVD) between 2004 and 2010  and CHARINDEX('Re-open',iad.tx_spvr_rsn)=0 --586726

select (598160-559416) as chris,629176-586726 as ours
--chris	ours
--38744	42450

select count(distinct inf.id_intake_fact) from dbo.intake_fact inf left join dbo.intake_type_dim itd
					on itd.id_intake_type_dim = inf.id_intake_type_dim
		left join dbo.intake_attribute_dim iad on iad.id_intake_attribute_dim=inf.id_intake_attribute_dim
 where year(DT_ACCESS_RCVD) between 2004 and 2010  and CHARINDEX('Re-open',iad.tx_spvr_rsn)=0 
 and ID_PROVIDER_DIM_INTAKE=0  -- 532523



select count(distinct inf.id_intake_fact) from dbo.intake_fact inf left join dbo.intake_type_dim itd
					on itd.id_intake_type_dim = inf.id_intake_type_dim
		left join dbo.intake_attribute_dim iad on iad.id_intake_attribute_dim=inf.id_intake_attribute_dim
 where year(DT_ACCESS_RCVD) between 2004 and 2010  and CHARINDEX('Re-open',iad.tx_spvr_rsn)=0 
 and ID_PROVIDER_DIM_INTAKE=0 and CD_ACCESS_TYPE in (1,4) --451251








