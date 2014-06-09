use test_annie;
truncate table ref_lookup_census_population_poc2;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_lookup_census_population_poc2.txt'
into table ref_lookup_census_population_poc2
fields terminated by '|';
	