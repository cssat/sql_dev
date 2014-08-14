use test_annie;

drop table if exists bkp_ref_lookup_max_date ;
create table bkp_ref_lookup_max_date as select * from ref_lookup_max_date;

truncate table test_annie.ref_lookup_max_date;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_lookup_max_date.txt'
into table ref_lookup_max_date
fields terminated by '|'
(id,procedure_name,max_date_all,max_date_any,max_date_qtr,max_date_yr,min_date_any,is_current);

analyze table ref_lookup_max_date;
  update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from ref_lookup_max_date)
  where tbl_name='ref_lookup_max_date';
