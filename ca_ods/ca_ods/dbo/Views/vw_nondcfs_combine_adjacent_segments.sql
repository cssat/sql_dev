create view dbo.vw_nondcfs_combine_adjacent_segments as 
select id_prsn, Min(NewStartDate) cust_begin, MAX(enddate) cust_end
								from
								(select  id_prsn
										, v.[number]
										, t.startDate
										, t.enddate
										, NewStartDate = t.startdate+v.number
										, NewStartDateGroup =
											dateadd(d,
													1- DENSE_RANK() over (partition by id_prsn order by t.startdate+v.number),
													t.startdate+v.number)
									from (select id_prsn,cust_begin as startDate,cust_end as enddate from base.WRK_nonDCFS_All) t
									inner join dbo.numbers  v
									  on  v.number  <=  DATEDIFF(d, startdate, EndDate)
									--  order by [UserID],StartDate,v.number
								) X group by id_prsn , NewStartDateGroup ;