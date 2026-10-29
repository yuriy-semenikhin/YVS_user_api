# Database design

Revision 001 defines four tables for local-password authentication. SQL is generated,
not deployed. [Saved task](../technical_task.md) plus [principles](../PRINCIPLES.md)
remain the requirements; this document records the selected schema design.

| Focused source | Contents |
| --- | --- |
| [Normalization and choices](database/normalization.md) | Relationships, 1NF–3NF, storage and tradeoffs |
| [Table dictionary](database/tables.md) | Every field, type, null rule and meaning |
| [Indexes and access](database/indexes.md) | Every index and the queries it supports |
| [Writes and invariants](database/operations.md) | Approval, rotation, expiry and failure handling |
| [Installation](database/installation.md) | Server prerequisites, import and validation |
| [Initial SQL](../database/migrations/001_initial_schema.sql) | Four CREATE TABLE statements |

Hosting baseline: assume restricted free shared hosting. Target MyISAM without
transactions or foreign-key enforcement. Use ordinary tables/indexes only; no
procedures, triggers, events, administrative privileges or background jobs.
Install into a database created through the hosting control panel. Actual server
compatibility is untested, but further server details are not needed to proceed
with this conservative design. See [installation](database/installation.md).

Current PHP helper remains unchanged and unintegrated. No provider tables,
transaction dependencies, stored procedures, triggers, events, views or default
administrator credentials are introduced. The schema supports the saved token
proposal without finalizing its API contract.
