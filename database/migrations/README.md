# Schema migrations

[001_initial_schema.sql](001_initial_schema.sql) creates the four initial tables
in a selected empty database. No credentials, seed accounts or transaction support
are required. MyISAM is the selected restricted-hosting baseline. Follow the
[installation guide](../../docs/database/installation.md) before importing.

Generated and statically reviewed; not executed on a MySQL server. Future changes
need new numbered migrations, not edits to a migration already applied on a server.
