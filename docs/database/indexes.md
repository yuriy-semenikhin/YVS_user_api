# Index design and query shapes

All indexes in revision 001 are listed below. They enforce uniqueness or support
an identified access path; no speculative reporting indexes are added.

| Table/index | Columns | Reason |
| --- | --- | --- |
| services PRIMARY | service_pk | Stable compact internal lookup and conditional approval/update |
| uq_services_public_id | service_id | Resolve X-Service-ID and prevent public ID collision; multiple pending NULL IDs allowed |
| ix_services_pending | status, requested_at, service_pk | Pending list ordered by request time with deterministic tie-breaker |
| users PRIMARY | user_id | Login/ownership lookup by public ID; prevents duplicate user IDs |
| ix_users_service | service_pk | Service-to-user relationship inspection and future integrity maintenance |
| sessions PRIMARY | session_hash | Exact bearer digest lookup and global digest uniqueness |
| ix_sessions_user_activity | user_id, last_activity_at | One user's active count, expired deletion and session listing |
| administrators PRIMARY | administrator_id | Resolve authenticated administrator identity |
| uq_administrators_username | username | Unique admin login and exact lookup |

No token index is needed on services: every API call supplies a unique service_id,
so resolve that one row then compare its tokens. No separate users(service_pk,
user_id) index is needed: user_id is globally unique, and ownership is checked on
the row. Do not index password hashes, password age or cleanup timestamp: none is
searched globally. No standalone session user_id index: it is already the leftmost
part of ix_sessions_user_activity. Composite indexes support their leftmost
prefixes as described by [MySQL](https://dev.mysql.com/doc/refman/8.0/en/multiple-column-indexes.html).

## Activity bounds

Use one server-controlled UTC now for an operation and compute cutoff = now minus
15 days. Active means last_activity_at > cutoff; expired means <= cutoff, including
exactly 15 days. Use the same boundary for validation, counts and cleanup.

Query shapes (placeholders are explanatory, not executable SQL or a requirement
to change the existing database helper):

- Count: WHERE user_id = value AND last_activity_at > cutoff.
- Cleanup: WHERE user_id = value AND last_activity_at <= cutoff.
- Validate/refresh: WHERE session_hash = digest AND user_id = value AND
  last_activity_at > cutoff, after checking the owning user/service.
- Pending list: WHERE status = 'pending' ORDER BY requested_at, service_pk.

Do not wrap last_activity_at in DATE_ADD in the WHERE condition; put the computed
cutoff on the other side so the range is usable. Date arithmetic for a returned
expires_at is fine. Counts never update activity.

The session index changes on activity refresh, an intentional write cost for fast
per-user ranges. The small service-status index aids ordered review; it is not a
claim that low-selectivity indexes always beat scans. With a tiny dataset the
optimizer may reasonably scan. Verify EXPLAIN and real data before adding indexes.
