CREATE SCHEMA [annual_report]
    AUTHORIZATION [NETID\schmitzr];





GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[annual_report] TO [NETID\uw_poc_no_irb];

