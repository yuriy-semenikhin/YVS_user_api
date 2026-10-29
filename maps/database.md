# Database map

Revision 001 generated; not executed or deployed. Four tables; MyISAM free-hosting baseline.

- [Design index](../docs/database.md): choose only the source needed.
- [Normalization](../docs/database/normalization.md): relationships and choices.
- [Fields](../docs/database/tables.md): types, meanings and null rules.
- [Indexes](../docs/database/indexes.md): access paths and costs.
- [Writes](../docs/database/operations.md): invariants, dependencies and retries.
- [Install](../docs/database/installation.md): server prerequisites and validation.
- [SQL](../database/migrations/001_initial_schema.sql): initial four-table schema.
- [DB helper](../src/Database/db_class.php): unchanged and unintegrated; contains
  original credentials, which must not be copied into records.
- [Helper context](../chats/03-database-helper.md): reference class pattern.

Depends on service approval, local-password authentication and per-user session
rules. SQL installation does not implement the PHP ownership/state checks.
