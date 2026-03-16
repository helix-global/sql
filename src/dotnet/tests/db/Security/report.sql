CREATE SCHEMA [report]
    AUTHORIZATION [dbo];


GO
GRANT UPDATE
    ON SCHEMA::[report] TO [A2];


GO
GRANT SELECT
    ON SCHEMA::[report] TO [IPG-DOMAIN\mefimov];


GO
GRANT SELECT
    ON SCHEMA::[report] TO [A2];


GO
GRANT INSERT
    ON SCHEMA::[report] TO [A2];


GO
GRANT EXECUTE
    ON SCHEMA::[report] TO [A2];

