# Project log

Chronological summaries; these do not replace original conversations. All entries
below are dated 2026-09-18; exact message timestamps are unavailable.

- Initial review: service-specific users, backend service access and 15-day sliding
  sessions clarified. [Initial summary](chats/01-initial-design.md).
- Scaffold created, then database helper imported unchanged at user request.
  [Structure](chats/02-project-structure.md), [database context](chats/03-database-helper.md).
- Authentication clarified: local passwords only now; six-month advisory, no forced
  change. Future external-provider accounts must not have local passwords.
  [Authentication summary](chats/04-authentication-decisions.md).
- Documentation clarified: small selective maps and indexes reduce context loading.
  [Navigation summary](chats/05-documentation-navigation.md).
- Saved expanded technical task located: section 11 requires root PRINCIPLES.md,
  PROJECT_MAP.md, PROJECT_LOG.md, focused maps and separate original conversations.
  Added those documents; preserved earlier summaries and labelled history gaps.
  [Available transcript excerpt](chats/2026-09-18-documentation-conversation.md).
- Saved task explicitly prohibits transaction/stored-procedure dependencies and
  introduces pending service registration and approval. Earlier conflicting
  assistant defaults are superseded. No application code was changed.

- Documentation reconciliation: retained the saved task unchanged and integrated
  its requirements with prior discussion in focused design documents. Preserved
  local-only passwords, password_set_at/advisory, per-user count default and the
  imported helper/class pattern. Removed obsolete transaction, fixed-grace and
  provider-schema requirements from current docs. Earlier extra admin/API features
  are labelled optional. [Conversation excerpt](chats/2026-09-18-documentation-conversation.md).

- Database task: user authorized a normalized design document, full field and index
  explanations, and MySQL server installation SQL. Generated revision 001 with
  services, users, user sessions and administrators; no server connection or PHP
  edits. Selected provisional MyISAM for the no-transactions hosting constraint;
  asked for server/version support. Design sources are small and indexed.
  [Request record](chats/2026-09-18-documentation-conversation.md),
  [schema design](docs/database.md). Static checks passed; no local MySQL runtime
  is available, so execution remains unverified.

- Hosting clarification: user instructed us to assume the worst for free hosting.
  Adopted MyISAM as the baseline, control-panel import as the primary route, and
  no dependency on shell, remote access, privileged features or scheduled jobs.
  Retained the existing simple DDL; no server deployment performed.

## Outstanding decisions

- Token confirmation sequence and endpoint contracts remain proposals explicitly
  labelled in the saved task. Earlier ten-minute grace/confirmation-endpoint defaults
  must not be silently combined with the new proposal.
- Initial administrator bootstrap remains open. Hosting is treated as restricted
  free hosting without requiring further server details; actual execution is unverified.
  Revision 001 chooses recoverable service tokens and hashed session tokens;
  conditional token-version writes are designed but not implemented in PHP.
- Password-change/logout/bulk-revocation and extra admin tools were suggested earlier;
  contracts and inclusion remain optional, not core requirements.
- Per-user session counts are the current delegated default; the saved task's open
  count-scope question is resolved in current docs on that basis.
- Saved task's "no existing code" statement is superseded by the actual explicitly
  requested DB_class import. The imported helper is unchanged and unintegrated.
- Full original conversation export is not stored; topic summaries are not transcripts.
