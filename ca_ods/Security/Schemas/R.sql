CREATE SCHEMA [R]
    AUTHORIZATION [NEBULA2\mienkoja];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[R] TO [NETID\uw_poc_no_irb];

