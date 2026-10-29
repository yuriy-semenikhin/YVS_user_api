# Table dictionary — revision 001

See [SQL](../../database/migrations/001_initial_schema.sql). All DATETIME values
are UTC, with second precision. NULL means absent/not yet occurred, not an empty
string or zero date. Application validation supplements NOT NULL and uniqueness.

## yvs_services

One row starts as a pending request and is approved in place.

| Field | SQL type | Null/default | Description |
| --- | --- | --- | --- |
| service_pk | INT UNSIGNED | No; auto increment | Internal request/relationship key, never the public API ID |
| service_id | CHAR(32), ascii_bin | Yes; NULL | Public random hex ID assigned upon approval; unique when present |
| name | VARCHAR(160) | No | Display name; duplicates allowed because names are not identities |
| status | ENUM pending/approved | No; pending | Explicit authorization state |
| service_token | VARBINARY(64) | Yes; NULL | Exact current hex bearer token; set on approval |
| previous_service_token | VARBINARY(64) | Yes; NULL | Prior token while replacement awaits confirmation |
| token_issued_at | DATETIME | Yes; NULL | Current credential issue time |
| token_version | INT UNSIGNED | No; 0 | Monotonic compare-and-swap counter preventing stale credential updates |
| requested_at | DATETIME | No | Request creation time |
| approved_at | DATETIME | Yes; NULL | Approval time, independent of later token rotation |

Pending: only internal key, name, status and request time; public ID, token and
approval fields remain NULL, version 0. Approved: public ID/current token/issue
and approval times required, version at least 1. Previous token is optional and
must differ from current. PHP enforces these cross-field conditions.

## yvs_users

| Field | SQL type | Null/default | Description |
| --- | --- | --- | --- |
| user_id | CHAR(32), ascii_bin | No | Public generated hex user ID and primary key |
| service_pk | INT UNSIGNED | No | Owning approved service's internal key; logical relationship |
| password_hash | VARBINARY(255) | No | Complete PHP password hash; every current account has one |
| password_set_at | DATETIME | No | Time current password was created/replaced |
| registered_at | DATETIME | No | Account creation time; unchanged when password changes |
| last_session_cleanup_at | DATETIME | Yes; NULL | Last completed cleanup, NULL before first cleanup |

Do not move an existing user between services. A password replacement updates
hash and password_set_at together. The six-month suggestion is computed, never
an expiry field. Provider login is deferred and has no columns here.

## yvs_user_sessions

| Field | SQL type | Null/default | Description |
| --- | --- | --- | --- |
| session_hash | BINARY(32) | No | SHA-256 digest of issued session_id; unique primary key |
| user_id | CHAR(32), ascii_bin | No | Owner; logical relationship to yvs_users |
| last_activity_at | DATETIME | No | Login time initially; subsequent successful checks refresh it |

The API session_id is the raw random token, not a separate stored column.
Compute expires_at as last_activity_at plus 15 days. No service_pk copy, fixed
expiry field, revoked flag or session counter. Deletion can invalidate a session
if a logout operation is later added; no deletion endpoint is implemented here.

## yvs_administrators

| Field | SQL type | Null/default | Description |
| --- | --- | --- | --- |
| administrator_id | INT UNSIGNED | No; auto increment | Private administrator identity |
| username | VARCHAR(64), ascii_bin | No | Unique lowercase ASCII login; enforce allowed characters in PHP |
| password_hash | VARBINARY(255) | No | PHP password hash; no seeded/default password |
| created_at | DATETIME | No | Administrator creation time |

No service_id: administrators operate the service approval interface. Initial
bootstrap is still to be specified; the install script creates no accounts.
The discussed password-age advisory applies to API users; no admin reminder
policy has been requested. Browser sessions use private PHP session storage.
