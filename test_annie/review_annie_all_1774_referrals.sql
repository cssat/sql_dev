use review_annie;
truncate table rate_referrals;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals.txt'
into table rate_referrals
fields terminated by '|'
IGNORE 1 LINES;


analyze table rate_referrals;



  
truncate table rate_referral_findings;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referral_findings.txt'
into table rate_referral_findings
fields terminated by '|'
IGNORE 1 LINES;

analyze table rate_referral_findings;

  
truncate table rate_referrals_order_specific;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals_order_specific.txt'
into table rate_referrals_order_specific
fields terminated by '|'
IGNORE 1 LINES;
analyze table rate_referrals_order_specific;

  
truncate table rate_referrals_order_specific_findings;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals_order_specific_findings.txt'
into table rate_referrals_order_specific_findings
fields terminated by '|'
IGNORE 1 LINES;
analyze table rate_referrals_order_specific_findings;


truncate table rate_placement;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_placement.txt'
into table rate_placement
fields terminated by '|';
analyze table rate_placement;

truncate table rate_placement_order_specific;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_placement_order_specific.txt'
into table rate_placement_order_specific
fields terminated by '|';
analyze table rate_placement_order_specific;

truncate table rate_care_day_finding;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_care_day_finding.txt'
into table rate_care_day_finding
fields terminated by '|';
analyze table rate_care_day_finding;
