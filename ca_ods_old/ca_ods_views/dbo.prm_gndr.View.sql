USE [CA_ODS]
GO
/****** Object:  View [dbo].[prm_gndr]    Script Date: 4/10/2014 8:12:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[prm_gndr] 
as select ref_lookup_gender.pk_gndr [pk_gndr],ref_lookup_gender.pk_gndr [match_code] 
from ref_lookup_gender where (ref_lookup_gender.pk_gndr <> 0) 
union 
select zr.pk_gndr [pk_gndr],gdr.pk_gndr [match_code] from ref_lookup_gender gdr , ref_lookup_gender zr where ((gdr.pk_gndr <> 0) and (zr.pk_gndr = 0))
GO
