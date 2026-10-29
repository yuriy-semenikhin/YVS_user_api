# Project principles

Current sources: [technical task](technical_task.md) and explicit user corrections
recorded in the [project log](PROJECT_LOG.md). Proposals remain proposals.

1. Generate no application code without explicit instruction. Database design and MySQL DDL are now explicitly authorized; PHP application
   implementation is not yet requested.
2. Keep implementation simple for the owner's personal services and stated low
   concurrency; add no architecture or features without a demonstrated need.
3. Use object-oriented PHP, MySQL and MySQLi; no PDO. Choose and record the latest
   stable PHP version when implementation starts.
4. Do not depend on transactions or stored procedures: hosting does not support them.
5. Isolate every user and session by service. Backend service credentials must
   never become browser credentials.
6. Support local passwords only now. Store password hashes and password_set_at;
   suggest a change after six months without enforcing it. External login is
   future scope only; those future accounts must not have a local password.
7. Sessions expire after 15 days of inactivity; validate expiry independently of
   cleanup, which is checked per user after 24 hours.
8. Keep knowledge portable using project-relative links, focused maps and a compact
   root index. Load only sources relevant to the task.
9. Preserve original conversations separately from summaries. Mark missing history
   explicitly; never reconstruct missing wording. Keep secrets out of shared records.
10. Keep confirmed requirements, assistant defaults, proposals and open decisions
    distinct. Update affected maps and the project log when they change.

11. Combine the saved specification with explicit conversation decisions; omissions
    in the saved task do not erase password-age or local-only scope decisions.
12. The existing DB_class import remains unchanged until implementation is requested.
    Follow its simple domain-class usage pattern; safe SQL handling is required,
    but a prepared-statement rewrite is not mandated.
13. Count active sessions per user within a service as the delegated default;
    service-wide metrics are outside current scope. This is not a benchmark claim.
14. Pending service requests require administrator approval before credentials
    allow API access. Admin bootstrap remains open.

The saved task proposes token confirmation and endpoint contracts; they are not
finalized. See [open decisions](PROJECT_LOG.md#outstanding-decisions).
Earlier [design notes](docs/legacy-design-notes.md) are historical, not authoritative.

Schema revision 001 is generated, not deployed. Its engine assumption, field
definitions, normalized relationships and index rationale are in
[the database design](docs/database.md). Assume restricted free hosting: MyISAM,
control-panel import, no privileged features or background jobs. Actual execution
is unverified; do not require further server details to advance this design.
