# Tests

No test runner or executable tests exist. Verify the task's acceptance scenarios
plus local-password age reminders, service isolation and imported-helper integration.

- unit/: expiry and six-month advisory boundaries; proposed rotation rules once finalized.
- integration/: MySQL constraints, ownership and repeatable updates without transactions.
- functional/: service request/approval, registration, login, checks and per-user counts.

Cleanup is request-driven. Verify expired sessions are excluded before cleanup,
and reminders never deny login. Keep checks proportionate to the stated usage.
