CREATE SCHEMA [rodis]
    AUTHORIZATION [NEBULA2\schmitzr];






GO



GO



GO



GO



GO



GO



GO
DENY UPDATE
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY EXECUTE
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[rodis] TO [NETID\uw_poc_no_irb];

