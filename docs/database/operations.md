# Writes, invariants and failure handling

No transactions, stored procedures, triggers or scheduled events are required.
The DDL enforces keys/types; PHP must enforce relationships and state invariants.
This is a design contract for later code, not already-implemented behavior.

## Approval and token updates

Create a pending row, then approve using one conditional UPDATE: set public ID,
current token, status, issue/approval times and increment token_version where the
row is still pending and version is the value previously read. Return credentials
only after the write succeeds. On duplicate public ID generate a fresh ID and retry.
A competing approval must re-read state, not overwrite approved credentials.

The schema supports the saved proposal: rotate only if the current token is older
than three hours and previous_service_token IS NULL. A single conditional UPDATE
sets previous/current token, issue time and increments token_version, guarded by
service_pk, approved status, expected current token and expected version. A losing
request re-reads the row; it must not return its unpersisted candidate token.

A previous-token request returns the persisted replacement and confirmation flag.
Using that replacement clears previous_service_token and increments token_version,
conditional on the observed pair/version. Do not confirm and immediately rotate
again in the same request if a long-pending replacement is already old. A later
request can rotate. No fixed grace deadline or separate confirmation endpoint is
assumed. The protocol remains proposed, but these columns support it.

Version is internal state, not an API credential. Every credential-state mutation
must increment it. Conditional single-row writes prevent ordinary request races;
MyISAM does not offer transaction rollback or crash-safe multi-step guarantees.

## Ownership, insertion and deletion

Authenticate an approved service first, then verify the user's service_pk for
every operation, including sessions/counts. Before inserting a user or session,
verify its parent exists and is valid. Primary keys reject collisions; generate a
new random ID/token and retry only the relevant collision, not arbitrary DB errors.

Service/user hard deletion and reassignment are outside core scope. Do not expose
them without a deletion strategy: there are no foreign keys/cascades in this
nontransactional schema. Manual changes can create orphans. Maintenance must stop
application writes, remove children before parents and check for orphan records.
Admin credential creation is a separate bootstrap task; do not insert raw passwords.

## Session activity and cleanup

Refresh a session only with a conditional update that includes its token digest,
user and unexpired timestamp predicate. This prevents cleanup/expiry races from
reviving an expired session. Do not shorten activity when requests arrive out of
order; use the later of stored activity and the request's trusted time.

Second-precision valid checks can leave last_activity_at unchanged; zero changed
rows alone must not be treated as invalid authentication. Distinguish matched rows
from changed rows or re-read and revalidate the exact session before responding.

When cleanup is due, capture one cutoff, delete expired rows for this user, then
update last_session_cleanup_at only on successful deletion. A crash between these
steps causes harmless repeated cleanup. Avoid moving the cleanup timestamp backward
on competing requests. Counts exclude expired rows even if cleanup fails. Treat a
database failure as server_error, not as an invalid password or successful cleanup.

Write a replacement password hash and password_set_at together. Compute the
six-calendar-month advisory in PHP with the documented month-end rule. Never
revoke sessions or reject a password solely because this reminder is due.
