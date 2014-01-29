

	update curr
	set fl_prm_txfr=1
		,fl_prm_txfr_intra =case when curr.DIstrictID=nxt.DistrictID then 1 else 0 end
		,fl_prm_txfr_inter=case when curr.DIstrictID<>nxt.DistrictID then 1 else 0 end
	from ospi.temp curr
	join ospi.temp nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
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
	from ospi.temp curr
	join ospi.temp nxt on curr.int_researchID=nxt.int_researchID and curr.row_num_asc+1=nxt.row_num_asc
	where curr.schoolcode <> nxt.schoolcode
	and curr.fl_prm_txfr=0
	go
	
	--Confirmed transfer out of the school district                                   
	update ospi
	set fl_other_txfr =1,
		fl_other_txfr_inter=1
	from ospi.temp ospi
	where fl_prm_txfr=0 and fl_other_txfr= 0 
		and EnrollmentStatus  = 'T0'
		 and row_num_desc=1
		 
	--Confirmed transfer out of the school within district                            	
	update ospi
	set fl_other_txfr =1,
		fl_other_txfr_intra=1
	from ospi.temp ospi
	where fl_prm_txfr=0 and fl_other_txfr= 0 
		and EnrollmentStatus  = 'T1'
		 and row_num_desc=1
	
	
	--qa
--	select sum(fl_prm_txfr),sum(fl_prm_txfr_intra),sum(fl_prm_txfr_inter)
--		,sum(fl_other_txfr),sum(fl_other_txfr_intra),sum(fl_other_txfr_inter)
--	from ospi.temp 
	
	
--	select * from ospi.temp where fl_prm_txfr=1 and EnrollmentStatus='FE'
--	select * from ospi.temp where int_researchID=3777 order by row_num_asc
	
--	select * from ospi.school_dim where schoolcode in (2284,4429)
	
--	select * from ospi.temp where int_researchID=1877 order by row_num_asc
	
	
--select * from ospi.temp where fl_prm_txfr=0 and fl_other_txfr= 0 and EnrollmentStatus like 'T%' and row_num_desc>1
--and last_enr_mnth <> 201108
	
	
select * into ospi.temp_thru_6 from ospi.temp