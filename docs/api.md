# API contract planning

Source: [task section 9](../technical_task.md#9-api-structure), supplemented by
our password-age and count decisions. Paths and detailed contracts below remain
proposals; transport requirements are specified.

Use backend-only JSON over HTTPS under `/api/v1/`. Require `Authorization: Bearer
<service_token>` and `X-Service-ID: <service_id>`. Send passwords and session
credentials in JSON bodies, never URLs. Return UTC ISO 8601 timestamps.

| Proposed operation | Input | Successful response fields |
| --- | --- | --- |
| POST `/api/v1/users` | password | status, user_id |
| POST `/api/v1/sessions` | user_id, password | status, session_id, expires_at, password_change_suggested |
| POST `/api/v1/sessions/check` | user_id, session_id | status, expires_at, password_change_suggested |
| GET `/api/v1/users/{user_id}/sessions/count` | user_id in path | status, active_sessions |

Registration generates an alphanumeric ID, stores the password hash and its set
date, and binds the user to the authenticated service. No automatic session on
registration is the task's proposal. Login preserves other active sessions.
Successful session checks refresh activity; counting never does.

Per-user counts are the current delegated default: a narrower query, not a
measured performance guarantee. Service-wide metrics are not required now.

`password_change_suggested` is the documented response default for the confirmed
six-month advisory. It never blocks login or session access. See
[authentication](authentication.md) for the threshold and scope.

Return consistent statuses from the task: `ok`, `authentication_required`,
`invalid_credentials`, `invalid_service_token`, `invalid_request`,
`user_not_found`, `server_error`. Use appropriate HTTP codes; HTTP 401 for invalid
user sessions is the existing default. A service shows the login prompt; the API
makes no password-request callback. Enforce ownership on every operation.

Successful authenticated responses may include `new_token` and
`token_confirmation_required`. The [rotation proposal](services.md) confirms by
using the replacement, not a separate confirmation endpoint.

Previously suggested logout, password-change, bulk-revocation and administrative
reset endpoints remain optional additions with unspecified contracts, not part
of the four proposed core routes. No provider routes or mixed login methods now.
