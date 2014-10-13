use test_annie;
truncate table rate_referrals;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals.txt'
into table rate_referrals
fields terminated by '|'
IGNORE 1 LINES;


analyze table rate_referrals;



  
truncate table rate_referrals_order_specific;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals_order_specific.txt'
into table rate_referrals_order_specific
fields terminated by '|';
analyze table rate_referrals_order_specific;

  

  
truncate table rate_referrals_scrn_in;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals_scrn_in.txt'
into table rate_referrals_scrn_in
fields terminated by '|';
analyze table rate_referrals_scrn_in;




truncate table rate_referrals_scrn_in_order_specific;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_referrals_scrn_in_order_specific.txt'
into table rate_referrals_scrn_in_order_specific
fields terminated by '|';
analyze table rate_referrals_scrn_in_order_specific;


  
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


truncate table rate_care_day_maltreatment;
LOAD DATA LOCAL INFILE '/data/pocweb/rate_care_day_maltreatment.txt'
into table rate_care_day_maltreatment
fields terminated by '|';
analyze table rate_care_day_maltreatment;
