			create view dbo.prtl_ref_kincare  as 
			select 0 [kincare],'All including Kin'  [placement_type]
			union select 1,'With Kin'