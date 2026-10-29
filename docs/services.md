# Services and token handling

Source: [task sections 4–6](../technical_task.md#4-services).

A form accepts a service name and creates a pending request. Pending services
cannot use authenticated API operations. Admin approval assigns the operational
service ID and creates the initial alphanumeric token for backend configuration.
Distinguish any pending-request row key from that operational identity in schema design.

Require service ID and token on authenticated operations. Service credentials
are distinct from user session credentials. Rotate lazily when a token is older
than three hours and return `new_token`.

## Current proposal, not finalized

- If no replacement awaits confirmation, preserve the old token, generate one
  replacement, update its issue time and return it.
- A previous-token request proceeds and receives the same `new_token` plus
  `token_confirmation_required: true`; do not generate competing replacements.
- A request using the replacement confirms receipt and clears the previous token.
- Reject tokens matching neither value. Under this proposal, previous-token
  validity has no fixed grace deadline while confirmation is outstanding.

This saved proposal supersedes the earlier assistant's ten-minute grace and
separate confirmation endpoint as the current design candidate. Do not silently
combine the two protocols. Finalization and safe update/retry behavior without
transactions remain open. Schema revision 001 stores exact service tokens recoverably for retry delivery;
see [storage tradeoff](database/normalization.md). Conditional token_version
updates support competing requests without transactions, as described in
[database writes](database/operations.md). PHP integration remains pending.

Core admin scope: login, pending list, approval and initial credential display.
Bootstrap remains open. Earlier suggestions for disabling services, resetting
credentials, revocation and audit management are optional extensions, not
implemented or required by the saved core task.
