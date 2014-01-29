
--2005	
	
	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2005 curr
	join ospi.Enrollment_2005 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	join ospi.school_dim currS on curr.schoolcode=currS.schoolcode and currS.schooltype is not null
	join ospi.school_dim nxtS on nxt.schoolcode=nxtS.schoolcode and nxtS.schooltype is not null
	where curr.schoolcode <> nxt.schoolcode
	and (
		(currS.Schooltype in ('ELEM','ALL','ELMD','MDHI','MIDL')
				and nxtS.Schooltype='HIGH')
	 OR (currS.Schooltype in ('ELEM','ELMD')
		and nxtS.Schooltype in ('ELMD','MDHI','MIDL'))
		)
	and currS.schooltype <> nxtS.schooltype
	go
	
	
	
	update curr
	set fl_other_txfr =1
		,fl_other_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_other_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2005 curr
	join ospi.Enrollment_2005 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go
	
	
--- 2006

	
	
	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2006 curr
	join ospi.Enrollment_2006 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	join ospi.school_dim currS on curr.schoolcode=currS.schoolcode and currS.schooltype is not null
	join ospi.school_dim nxtS on nxt.schoolcode=nxtS.schoolcode and nxtS.schooltype is not null
	where curr.schoolcode <> nxt.schoolcode
	and (
		(currS.Schooltype in ('ELEM','ALL','ELMD','MDHI','MIDL')
				and nxtS.Schooltype='HIGH')
	 OR (currS.Schooltype in ('ELEM','ELMD')
		and nxtS.Schooltype in ('ELMD','MDHI','MIDL'))
		)
	and currS.schooltype <> nxtS.schooltype
	go
	
	
	update curr
	set fl_other_txfr =1
		,fl_other_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_other_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2006 curr
	join ospi.Enrollment_2006 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go

--2007

	
	
	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2007 curr
	join ospi.Enrollment_2007 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	join ospi.school_dim currS on curr.schoolcode=currS.schoolcode and currS.schooltype is not null
	join ospi.school_dim nxtS on nxt.schoolcode=nxtS.schoolcode and nxtS.schooltype is not null
	where curr.schoolcode <> nxt.schoolcode
	and (
		(currS.Schooltype in ('ELEM','ALL','ELMD','MDHI','MIDL')
				and nxtS.Schooltype='HIGH')
	 OR (currS.Schooltype in ('ELEM','ELMD')
		and nxtS.Schooltype in ('ELMD','MDHI','MIDL'))
		)
	and currS.schooltype <> nxtS.schooltype
	go
	
	
	
	update curr
	set fl_other_txfr =1
		,fl_other_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_other_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2007 curr
	join ospi.Enrollment_2007 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go
	
--2008

	
	
	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2008 curr
	join ospi.Enrollment_2008 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	join ospi.school_dim currS on curr.schoolcode=currS.schoolcode and currS.schooltype is not null
	join ospi.school_dim nxtS on nxt.schoolcode=nxtS.schoolcode and nxtS.schooltype is not null
	where curr.schoolcode <> nxt.schoolcode
	and (
		(currS.Schooltype in ('ELEM','ALL','ELMD','MDHI','MIDL')
				and nxtS.Schooltype='HIGH')
	 OR (currS.Schooltype in ('ELEM','ELMD')
		and nxtS.Schooltype in ('ELMD','MDHI','MIDL'))
		)
	and currS.schooltype <> nxtS.schooltype
	go
	
	
	
	update curr
	set fl_other_txfr =1
		,fl_other_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_other_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2008 curr
	join ospi.Enrollment_2008 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go	
	
--2009	

	
	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2009 curr
	join ospi.Enrollment_2009 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	join ospi.school_dim currS on curr.schoolcode=currS.schoolcode and currS.schooltype is not null
	join ospi.school_dim nxtS on nxt.schoolcode=nxtS.schoolcode and nxtS.schooltype is not null
	where curr.schoolcode <> nxt.schoolcode
	and (
		(currS.Schooltype in ('ELEM','ALL','ELMD','MDHI','MIDL')
				and nxtS.Schooltype='HIGH')
	 OR (currS.Schooltype in ('ELEM','ELMD')
		and nxtS.Schooltype in ('ELMD','MDHI','MIDL'))
		)
	and currS.schooltype <> nxtS.schooltype
	go
	
	
	
	update curr
	set fl_other_txfr =1
		,fl_other_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_other_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.Enrollment_2009 curr
	join ospi.Enrollment_2009 nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go