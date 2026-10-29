# Earlier design notes — superseded where conflicting

Historical assistant defaults, not the current requirements. The saved technical
task and PRINCIPLES.md take precedence. In particular, transaction dependencies,
ten-minute rotation grace and extra admin features are not confirmed requirements.

YVS User API — project principles
Updated: 2026-09-18

1. Do not generate code unless the user specifically instructs it.
2. Use PHP for the API and MySQL for persistent storage. Provide an admin
   interface for managing registered services. Keep the architecture simple.
3. technical_task.md is the original brief. This file holds current decisions;
   later explicit user instructions take precedence. Record their context in
   small topic files indexed by chats/CHAT_HISTORY.md. Use maps/PROJECT_MAP.md
   to find focused source maps; keep indexes short and read only relevant files.
4. The user authorizes reasonable execution choices without asking about every
   detail. Defaults below are design decisions, not implemented features.

Current implementation scope
- Support ONLY local-password accounts for now. Every current user has a local
  password hash and password_set_at. The six-month advisory applies to all
  current accounts based on their password age.
- External-provider login is a future consideration only. Do not add provider
  integrations, provider credential tables, authentication-mode selectors, or
  provider-specific API/UI flows to the current implementation.
- Future-provider notes below are constraints for a later extension, not current
  requirements. Keep current implementation simple.

Identity and trust
- One user belongs to exactly one service. No shared accounts across services.
- Use a generated, globally unique alphanumeric user ID as the initial password-login
  identifier. Username/email login and password recovery are outside initial
  scope unless added explicitly; do not assume an email address exists.
- Service credentials authenticate service backends only. Never expose them to
  browsers. Require HTTPS and scope every user/session operation to the
  authenticated service, regardless of any service ID supplied in a payload.
- Hash passwords with PHP's password hashing/verification APIs, preferably
  Argon2id where supported. Never store recoverable passwords.
- Generate opaque credentials using a cryptographically secure random source
  with at least 256 bits of entropy; hex encoding meets the alphanumeric rule.
  Store credential hashes for lookup/verification, not raw bearer credentials,
  except the protected, short-lived rotation delivery copy described below.

Service credential rotation (chosen default)
- Keep service credentials distinct from user session credentials.
- Rotate lazily on the first authenticated request when the current credential
  is at least three hours old. Atomically create a new current credential and
  retain exactly one previous credential for a fixed ten-minute grace period.
- Return the replacement under new_token with token_confirmation_required.
  During grace, requests using the previous credential receive the same
  replacement and confirmation instruction; they never create another token.
- The backend must persist the replacement before explicitly confirming it
  through a dedicated endpoint authenticated with that replacement.
- Confirmation deletes the delivery copy and records acknowledgement. The
  previous credential remains usable until the original grace deadline so
  in-flight requests and other backend workers can finish; confirmation does
  not extend grace. Confirmed old-token requests get a switch-token instruction.
- Until confirmation, retain the replacement encrypted using an application
  key kept outside the database, solely for retry-safe delivery. Delete this
  copy on confirmation or grace expiry. Never log credentials.
- Once grace expires, reject the previous credential. If delivery failed and
  the backend has no replacement, an administrator must reset its credential.
- Use transactions/locking to prevent concurrent requests from issuing
  competing replacements. Administrative reset revokes both credentials.
- This is a response-based handshake; the API makes no callback to a service.

User sessions
- Allow multiple sessions per user; no arbitrary hard cap initially.
- A session expires after 15 days without successful session activity. Login
  starts activity; successful validation of that session refreshes its activity.
  Counting sessions and failed requests never refresh activity.
- Check expiry on every session validation. Expired sessions cannot be revived.
- If the user's last cleanup is at least 24 hours old (or absent), remove that
  user's expired sessions and update the cleanup timestamp atomically. This
  timestamp is separate from each session's last activity.
- Return HTTP 401 with a stable authentication_required error for unknown,
  expired, or revoked user sessions. The service presents its login interface;
  the API never requests a password through a callback or reveals account
  existence in authentication errors.
- Count active sessions for one user within the authenticated service by
  default. This is a narrower query than service-wide counting; actual speed
  depends on data and indexes and must be measured, not assumed.
- Count only unexpired, non-revoked sessions even before cleanup. Index for
  user-scoped expiry lookups. Service-wide metrics are not required initially.
- Provide logout of the current session and revocation of all a user's sessions.
  Password changes require authentication and revoke existing sessions.

Administration and operational defaults
- Use separately authenticated administrators; no public admin registration.
  Bootstrap the first administrator through a deployment procedure.
- Provide service registration, listing, disable/enable, credential reset, and
  scoped user-session revocation. Disabling a service immediately blocks its
  API access and revokes its credentials and user sessions; re-enabling requires
  fresh credentials and user logins.
- Protect admin forms against CSRF; use secure, HttpOnly, SameSite cookies and
  a short admin idle timeout, separate from the user-session lifetime.
- Rate-limit login, registration, and invalid credential attempts. Use parameterized
  SQL, validate inputs, enforce database constraints, and avoid secret-bearing logs.
- Audit administrative/security actions without storing passwords or tokens.
- Use UTC consistently and a server-controlled clock for expiry decisions.
- Return JSON with consistent error codes; distinguish invalid service credentials
  from missing user authentication without leaking account details.
- Finalize endpoint contracts, schema, deployment settings, and meaningful security
  and concurrency tests when implementation is explicitly requested.

Portable project history
- Keep project history in the repository as plain Markdown, available on other
  machines without access to this chat. Preserve decisions, rationale, questions,
  and changes of direction. Mark summaries as summaries; never invent quotations.
- Preserve user messages verbatim when available, excluding any future secrets.
  Do not treat repository chat history as permission to store credentials.

Future external-provider login (2026-09-18)
- Allow future sign-in through Google, Facebook, or other identity providers.
  This is a design extension point, not authorization to implement integrations now.
- Keep the internal user identity independent of its login methods. A user still
  belongs to exactly one service, even when an external identity is used.
- Each account uses either local password authentication or a confirmed external
  provider. External-provider accounts must not have a local password or a local
  password creation/reset fallback. Do not generate placeholder passwords.
- Keep the chosen authentication method explicit and enforce mutually exclusive
  credential storage. Mixed local/provider authentication is not supported.
- Identify external identities by provider, verified stable subject identifier,
  and applicable issuer/client scope, within the owning service; not by email alone.
- Do not merge accounts by matching email. Account linking, unlinking, and
  switching authentication methods are outside scope; do not add these flows
  implicitly.
- All successful login methods issue the same internal user sessions and follow
  the same activity, expiry, revocation, and service-isolation rules.
- Keep provider-specific verification separate from user/session domain rules.
  Service credentials remain backend-only; future browser redirects and callback
  flows will require their own explicit design.
- Choose provider protocols, credentials, scopes, callback handling, and validation
  rules against official provider documentation when an integration is requested.

Password age advisory (2026-09-18)
- Store password_set_at in UTC on the local password credential when a password
  is first created; reset it whenever the password is replaced. This is distinct
  from the user's registration date.
- If the current password is older than six calendar months, suggest changing it.
  This is advisory only: do not reject login, expire the password, revoke sessions,
  or restrict account access because of password age.
- Calculate the six-month anniversary in UTC, clamping to the target month's last
  valid day where needed. The advisory applies strictly after that anniversary.
- Return password_change_suggested as a boolean on successful password login and
  successful session validation so services can display an optional reminder.
  Computing this flag must not itself refresh activity or revoke sessions.
- Accounts using confirmed external login providers have no local password and
  receive no password-age advisory; return false. A confirmed provider means a
  verified external login identity for the account, not merely a provider
  configured for the service.
- For other accounts, evaluate the age of their local password. A successful
  password replacement clears the advisory.
