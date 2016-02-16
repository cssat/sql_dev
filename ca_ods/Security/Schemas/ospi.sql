CREATE SCHEMA [ospi]
    AUTHORIZATION [NEBULA2\POC_DBO];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[ospi] TO [NETID\uw_poc_no_irb];

