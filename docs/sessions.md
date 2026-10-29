# Sessions and cleanup

Each session has user_id, unpredictable session_id and last_activity_at. Enforce
both service ownership of the user and session ownership by that user.

Sessions expire after 15 days of inactivity. Login starts activity; a successful
session check refreshes it. Expired sessions cannot revive themselves. Counting,
failed validation and cleanup do not extend activity. Validate expiry every time,
regardless of whether the record has been removed.

When processing an operation for a known, service-owned user, if
last_session_cleanup_at is unset or older than 24 hours, remove that user's expired
records and then update the cleanup timestamp. This is request-driven cleanup,
not a required scheduler. On deletion failure do not mark cleanup successful.
No transactions or stored procedures may be required.

Count the user's unexpired sessions within the authenticated service, even before
cleanup. Multiple sessions are allowed; no hard cap was requested.

Unknown, expired or mismatched sessions return authentication_required. The
calling service prompts for local-password login. Session checks may also return
the advisory described in [authentication](authentication.md).
