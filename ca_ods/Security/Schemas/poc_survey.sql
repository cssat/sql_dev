CREATE SCHEMA [poc_survey]
    AUTHORIZATION [NEBULA2\POC_DBO];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[poc_survey] TO [NETID\uw_poc_no_irb];

