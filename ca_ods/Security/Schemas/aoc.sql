CREATE SCHEMA [aoc]
    AUTHORIZATION [dbo];




GO
DENY UPDATE
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[aoc] TO [NETID\uw_poc_no_irb];

