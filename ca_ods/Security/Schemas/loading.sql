CREATE SCHEMA [loading]
    AUTHORIZATION [NEBULA2\POC_DBO];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[loading] TO [NETID\uw_poc_no_irb];

