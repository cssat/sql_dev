CREATE SCHEMA [prtl]
    AUTHORIZATION [dbo];














GO
GRANT EXECUTE
    ON SCHEMA::[prtl] TO [NEBULA2\POC_DBO];


GO
DENY UPDATE
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[prtl] TO [NETID\uw_poc_no_irb];

