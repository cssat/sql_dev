CREATE SCHEMA [retention]
    AUTHORIZATION [NETID\schmitzr];





GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[retention] TO [NETID\uw_poc_no_irb];

