
use test_annie;
truncate table age_dim;
LOAD DATA LOCAL INFILE '/data/pocweb/age_dim.txt'
into table age_dim
fields terminated by '|'
(age_mo,
age_yr,
census_child_group_cd,
census_child_group_tx,
census_20_group_cd,
census_20_group_tx,
census_all_group_cd,
census_all_group_tx,
custom_group_cd,
custom_group_tx,
developmental_age_cd,
developmental_age_tx,
school_age_cd,
school_age_tx,
cdc_age_cd,
cdc_age_tx,
cdc_census_mix_age_cd,
cdc_census_mix_age_tx);

update prtl_tables_last_update
  set load_date=now(),row_count=(select count(*) from age_dim)
  where tbl_name='age_dim';
