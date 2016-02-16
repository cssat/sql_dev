CREATE SCHEMA [camis]
    AUTHORIZATION [NEBULA2\POC_DBO];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[camis] TO [NETID\uw_poc_no_irb];

