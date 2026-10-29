# Schema installation

## Before importing

Revision 001 targets MySQL 5.7-compatible DDL and later, with utf8mb4 and MyISAM.
This is a conservative syntax target, not a claim about the actual host version.
Assume restricted free hosting: no shell, remote database access, privileged server
settings, transaction support, foreign keys, procedures, triggers or events.
Use the hosting database panel/phpMyAdmin as the primary installation path.

Version and engine checks (`SELECT VERSION(), DATABASE();`, `SHOW ENGINES;`) are
optional diagnostics, not information the user must supply before design can
continue. If importing reports an unsupported feature, retain the exact error and
adjust only that compatibility issue. Do not silently skip failed statements.

Shared hosting often requires creating/selecting a database in its control panel.
The SQL deliberately contains no CREATE DATABASE, USE, host, credentials or grants.
It creates four yvs_-prefixed tables in the database you select. Table names must
not already exist. It makes no connection to the original helper's database.

## Import

1. Select the intended empty application database in phpMyAdmin (or equivalent).
2. Import [001_initial_schema.sql](../../database/migrations/001_initial_schema.sql).
3. Verify four tables exist: yvs_services, yvs_users, yvs_user_sessions,
   yvs_administrators. Check SHOW CREATE TABLE and SHOW INDEX for each against the
   script and [index dictionary](indexes.md).
4. Record the actual server version and engine in deployment documentation. Do not
   insert a default admin password; bootstrap remains a separate implementation step.

Optional CLI alternative only if the host provides shell/remote MySQL access:

```sh
mysql --host=YOUR_HOST --user=YOUR_USER --password YOUR_DATABASE < database/migrations/001_initial_schema.sql
```

The client prompts for the password. Keep it out of the command text/history.
The script sets UTC, utf8mb4 and strict/no-engine-substitution SQL modes for that
connection. Future application connections must likewise use UTC and strict
validation/settings; import-time settings do not configure other connections.
These are session settings, not global server changes. If the host denies them,
review the exact error before adapting the import. PHP must validate values and
supply UTC timestamps explicitly rather than relying on configurable server defaults.
No timezone-table installation is needed for the numeric UTC offset.

## Failure and repeat runs

This is a one-time initial migration, not a repair or upgrade script. CREATE TABLE
has no IF NOT EXISTS so existing mismatched objects cannot be silently accepted.
On failure stop importing; do not use mysql --force. Earlier tables may already
exist because there is no rollback. Inspect what was created and resume only the
missing statements after correcting the cause. Do not drop existing data to retry.
No DELETE, DROP, automatic seed or live server action occurs in this migration.

## Verification status and later checks

Locally checked table/field/index consistency and links. No MySQL client/server is
available in the current workspace, so SQL execution and server compatibility
have NOT been verified. Do not describe this schema as deployed or tested on MySQL.

On a disposable database, later integration tests must verify duplicate-ID and
username rejection, pending/approved state handling, exact 15-day expiry bounds,
per-user counts, cross-service denial, repeat cleanup, rotation version conflicts,
and six-month advisory behavior. PHP-enforced rules cannot be validated by DDL alone.
