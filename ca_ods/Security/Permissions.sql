GRANT SELECT
    ON SCHEMA::[dbo] TO [NEBULA2\POC_CA];


GO
GRANT REFERENCES
    ON SCHEMA::[dbo] TO [NEBULA2\POC_CA];


GO
GRANT EXECUTE
    ON SCHEMA::[dbo] TO [NEBULA2\POC_DBO];


GO



GO
DENY UPDATE
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY TAKE OWNERSHIP
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY INSERT
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY DELETE
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY ALTER
    ON SCHEMA::[dbo] TO [NETID\uw_poc_no_irb];


GO
DENY SELECT
    ON SCHEMA::[INFORMATION_SCHEMA] TO [NETID\uw_poc_no_irb];

