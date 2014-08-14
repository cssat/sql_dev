use test_annie;
truncate table ref_match_allegation;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_allegation.txt'
into table ref_match_allegation
fields terminated by '|'
(cd_allegation,filter_allegation,fl_phys_abuse,fl_sexual_abuse,fl_neglect,fl_any_legal);
analyze table ref_match_allegation;

truncate table ref_match_finding;
LOAD DATA LOCAL INFILE '/data/pocweb/ref_match_finding.txt'
into table ref_match_finding
fields terminated by '|'
(filter_finding,fl_founded_phys_abuse,fl_founded_sexual_abuse,fl_founded_neglect,fl_any_finding_legal,cd_finding);
analyze table ref_match_finding;