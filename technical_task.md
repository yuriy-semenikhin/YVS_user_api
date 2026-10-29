# Technical Task: Multi-Service User Authentication API

## 1. Purpose

Create an API for user registration, login, and session tracking across multiple independent services.

Provide a service registration request form and an admin section for approving registrations and generating initial service tokens.

The project starts with this technical task only. No existing code, infrastructure, or classes are supplied.

## 2. Instructions for Codex

* **Do not generate application code unless explicitly instructed.**
* Keep the implementation simple and proportionate to the requirements.
* Record confirmed decisions separately from proposals and unresolved questions.
* Do not introduce additional functionality or architectural layers without an identified need.
* Maintain project documentation and conversation records as described below.

## 3. Technologies and Constraints

* Use the latest stable PHP release available when implementation begins. Record the exact version in the project documentation.
* Write object-oriented PHP.
* Use MySQL for data storage and MySQLi for database access.
* Do not use PDO.
* The hosting environment does not support database transactions or stored procedures. The implementation must work without them.
* Initially, the API serves the owner’s personal services, with no more than one concurrent user.
* Keep database access methods reusable and business logic organized into relevant classes.

## 4. Services

Each service stores:

| Field                    | Purpose                                   |
| ------------------------ | ----------------------------------------- |
| `id`                     | Unique service identifier                 |
| `name`                   | Service name                              |
| `status`                 | Pending or approved                       |
| `service_token`          | Current alphanumeric authentication token |
| `previous_service_token` | Previous token retained during rotation   |
| `token_issued_at`        | Time the current token was generated      |

Approved services can:

* Register a user.
* Authenticate a user.
* Check a user session.
* Count active user sessions.

Every authenticated API request requires the service ID and a valid service token.

## 5. Service Registration and Administration

### Service request form

Submitting the service name creates a pending registration request.

Pending services cannot perform authenticated API operations.

### Admin section

Provide:

* Administrator login.
* A list of pending registration requests.
* Registration approval and generation of the first service token.

Approval assigns the service ID and generates the initial token. Display these credentials to the administrator for configuring the service.

The initial administrator account creation method remains to be specified.

## 6. Service Token Rotation

Rotate service tokens when they are older than three hours and return the replacement as `new_token`.

When a service connects using its previous token, request confirmation of the replacement.

**Proposed confirmation sequence:**

1. A request using the current token proceeds normally.
2. If that token is older than three hours and no replacement awaits confirmation:

   * Retain it as `previous_service_token`.
   * Generate a replacement as `service_token`.
   * Update `token_issued_at`.
   * Return the replacement as `new_token`.
3. A request using `previous_service_token` proceeds and receives:

   * The existing replacement as `new_token`.
   * `token_confirmation_required: true`.
4. A subsequent request using the replacement confirms receipt. Clear `previous_service_token`.
5. Reject tokens matching neither stored token.

Keep only one unconfirmed replacement at a time. Under this proposal, the previous token remains valid until the replacement is used.

## 7. Users

Each user stores:

| Field                     | Purpose                                             |
| ------------------------- | --------------------------------------------------- |
| `id`                      | Unique alphanumeric user identifier                 |
| `service_id`              | Service where the user registered                   |
| `password_hash`           | Stored password hash                                |
| `last_session_cleanup_at` | Time expired sessions were last checked and removed |

Users belong to individual services. Accounts and sessions are not shared across unrelated services.

A user may have multiple active sessions.

Verify service ownership for every user operation.

Use `password_hash()` to store passwords and `password_verify()` to verify them.

## 8. User Sessions

Each session stores:

| Field              | Purpose                                  |
| ------------------ | ---------------------------------------- |
| `user_id`          | Session owner                            |
| `session_id`       | Unique, unpredictable session credential |
| `last_activity_at` | Most recent successful session activity  |

### Session expiry

* Sessions expire after 15 days without activity.
* A successful session check updates `last_activity_at`.
* An expired session cannot renew itself. The user must authenticate again.
* Check expiry whenever a session is validated, independently of record cleanup.

### Expired record cleanup

When processing an operation for a known user, if `last_session_cleanup_at` is unset or older than 24 hours:

1. Remove that user’s expired session records.
2. Update `last_session_cleanup_at`.

Exclude expired sessions from active-session counts even before their records are removed.

### Unknown or expired sessions

Return `authentication_required` when a supplied session is unknown, expired, or does not belong to the specified user.

The calling service prompts for a password and submits a login request.

## 9. API Structure

* Use JSON requests and responses over HTTPS.
* Place versioned endpoints under `/api/v1/`.
* Send service credentials through headers:

  * `Authorization: Bearer <service_token>`
  * `X-Service-ID: <service_id>`
* Use `Content-Type: application/json` for JSON request bodies and responses.
* Send passwords and session credentials in request bodies, never URLs.
* Use consistent response fields and appropriate HTTP status codes.
* Return timestamps in UTC using ISO 8601.

### Proposed endpoints

| Method | Endpoint                                 | Purpose                                 |
| ------ | ---------------------------------------- | --------------------------------------- |
| POST   | `/api/v1/users`                          | Register a user                         |
| POST   | `/api/v1/sessions`                       | Authenticate and create a session       |
| POST   | `/api/v1/sessions/check`                 | Validate a session and refresh activity |
| GET    | `/api/v1/users/{user_id}/sessions/count` | Count a user’s active sessions          |

Session checking uses POST because it updates activity.

### Register a user

**Input:** `password`

**Behaviour:**

* Generate a unique alphanumeric user ID.
* Hash the password.
* Associate the user with the authenticated service.

**Response:** `status`, `user_id`

Under this proposal, registration does not automatically create a session.

### Authenticate and create a session

**Input:** `user_id`, `password`

**Behaviour:**

* Verify the user belongs to the authenticated service.
* Verify the password.
* Create a new session.
* Preserve the user’s other active sessions.

**Response:** `status`, `session_id`, `expires_at`

### Check a session

**Input:** `user_id`, `session_id`

**Behaviour:**

* Verify service and session ownership.
* Check expiry.
* Update activity only if the session is valid and unexpired.

**Response:** `status`, `expires_at`

An unknown or expired session returns `authentication_required`.

### Count active sessions

**Input:** `user_id` in the endpoint path.

**Behaviour:**

* Verify the user belongs to the authenticated service.
* Count that user’s unexpired sessions.

**Response:** `status`, `active_sessions`

This proposal counts sessions per user within one service. A service-wide count is not currently defined.

### Response statuses

| Status                    | Meaning                                                                        |
| ------------------------- | ------------------------------------------------------------------------------ |
| `ok`                      | Operation completed successfully                                               |
| `authentication_required` | Session is missing, unknown, invalid, or expired                               |
| `invalid_credentials`     | User login credentials are invalid                                             |
| `invalid_service_token`   | Service credentials are invalid or the service is not approved                 |
| `invalid_request`         | Input is missing or malformed                                                  |
| `user_not_found`          | User is unavailable within the authenticated service for a non-login operation |
| `server_error`            | An internal failure prevented completion                                       |

Successful authenticated responses may additionally include `new_token` and `token_confirmation_required` when required by token rotation.

## 10. Implementation Requirements

* Generate service tokens and session credentials using cryptographically secure randomness.
* Validate incoming data and handle SQL values safely.
* Keep database credentials in configuration, outside shared documentation.
* Do not expose internal database errors through API responses.
* Keep service and user access isolated.
* Use UTC consistently for timestamp storage and expiry calculations.
* Avoid unnecessary frameworks, dependencies, and abstraction layers.

## 11. Project Documentation

All project documentation must reside inside the project directory and use relative links.

### `AGENTS.md`

Store instructions for coding agents:

* Do not generate application code unless explicitly instructed.
* Read `PRINCIPLES.md` and use `PROJECT_MAP.md` to locate relevant components.
* Load only maps needed for the current task.
* Consult the project log and original discussions when prior decisions matter.
* Keep proposals and unresolved questions distinct from confirmed requirements.
* Update affected documentation when requirements or implementation change.
* Preserve complete available conversation records independently of summaries.
* Flag missing history rather than reconstructing it.

### `PRINCIPLES.md`

Record agreed design decisions and their reasons.

Initial principles:

1. Do not generate application code unless explicitly instructed.
2. Keep the implementation simple and proportionate to the stated usage.
3. Use object-oriented PHP and MySQLi.
4. Do not depend on transactions or stored procedures.
5. Isolate users and sessions by service.
6. Keep project knowledge portable between machines and users.
7. Organize maps for selective loading and reduced AI context usage.
8. Preserve original discussions separately from summaries.

### `PROJECT_MAP.md`

The main project index, containing:

* A concise system overview.
* Components and their responsibilities.
* Links to focused component maps.
* Links to principles, the project log, and the conversation index.

Keep this file compact.

### `maps/`

Maintain smaller maps covering relevant areas, such as:

* API operations.
* Services and token handling.
* User authentication.
* Sessions and cleanup.
* Administration.
* Database structure.

Each map identifies relevant responsibilities, interfaces, dependencies, and actual file paths once implemented.

Load only the maps relevant to the current task. Avoid duplicating the full specification in each map.

### `PROJECT_LOG.md`

Maintain a chronological summary of:

* Confirmed decisions and reasons.
* Requirement changes.
* Implementation progress.
* Unresolved questions.
* References to original conversations.

The log supplements conversation transcripts; it does not replace them.

### `chats/`

Keep complete project conversation records for reference.

* Store each conversation in a separate file.
* Maintain an index.
* Preserve wording, speaker roles, message order, and timestamps where available.
* Append later discussions without discarding earlier records.
* Never replace transcripts with summaries.
* Import conversation exports when complete history is not directly accessible.
* Explicitly mark incomplete or missing history; do not invent messages.

## 12. Portability

The project must remain understandable when transferred to another machine or user.

* Keep documentation, maps, logs, and conversation records within the project.
* Use relative links and project-relative paths.
* Do not rely on an agent’s private memory or access to earlier chats.
* Record setup and environment requirements as implementation proceeds.
* Keep live credentials outside shared project records.

## 13. Acceptance Scenarios

Once implementation is authorized, verify that:

* Pending services cannot use authenticated API operations.
* Admin approval generates initial service credentials.
* Services can register and authenticate their own users.
* Services cannot access another service’s users or sessions.
* A user can maintain multiple sessions.
* Successful session checks extend expiry by 15 days from the latest activity.
* Expired sessions cannot authenticate or renew themselves.
* Unknown and expired sessions request authentication.
* Scheduled per-user cleanup removes expired records.
* Session counts exclude expired sessions regardless of cleanup timing.
* Token rotation follows the agreed confirmation sequence.
* Relevant project components can be located without loading every map.
* Complete available conversation records remain accessible alongside summaries.

## 14. Outstanding Decisions

Confirm before implementing the affected behaviour:

* The proposed token confirmation sequence.
* The proposed endpoint paths, inputs, and responses.
* Whether session counts are per user only or also per service.
* How the initial administrator account is created.

**Current stage: technical task refinement. Application code generation is not authorized.**
