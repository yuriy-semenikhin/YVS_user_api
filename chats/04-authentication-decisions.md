# Authentication decisions

Historical record; later corrections supersede earlier proposals.
See [history index](CHAT_HISTORY.md) for current outcomes and related records.

## 2026-09-18 — Future external-provider login

User (verbatim):

> for further designs, the api might support loging in with google, facebook or other APIs.

Assistant action summary: recorded this as a future design requirement, not an
implementation request. Updated principles and architecture/API/database notes
to separate internal users from login identities, allow provider-only accounts,
preserve service isolation, and reuse internal sessions across login methods.
Account linking will require proof of control rather than email matching.
Provider-specific protocols and callback contracts remain for future design.
No implementation code or provider integration was added.

## 2026-09-18 — Password age reminder

User (verbatim):

> user password, should have date registered. if older then 6 months, suggest changing, not enforce.

Assistant action summary: added a local credential timestamp `password_set_at`,
set when the password is created and reset when it is replaced. Chose six calendar
months in UTC as the advisory threshold. Planned `password_change_suggested` on
successful password login and session validation; no password-age enforcement
or session revocation. Accounts without passwords have no advisory. Updated
principles and API/database plans; no implementation code changed.

## 2026-09-18 — Correction to password reminder exemption

User (verbatim):

> not "Accounts without passwords"
> but "Accounts using confirmed APIs"

Assistant action summary: corrected the current principles and API/database notes.
The exemption applies to accounts using confirmed external login providers,
including those with a local password. Interpreted confirmation as a verified
external login identity linked to the account, rather than simply a configured
provider. This supersedes the preceding password-reminder exemption description.
No implementation code changed.

## 2026-09-18 — Exclusive authentication methods

User (verbatim):

> local password is not created when they have external service. othervise you create an overcomplicated service open to manipulation.

Assistant action summary: corrected principles and architecture/API/database
plans so accounts use either local-password authentication or a confirmed
external provider, never both. External accounts have no generated, placeholder,
or fallback local password. Removed planned account linking/unlinking; switching
authentication methods is outside scope. This supersedes earlier descriptions of
mixed login methods and external accounts also holding local passwords.
The six-month advisory applies only to local-password accounts. No code changed.

## 2026-09-18 — Current scope: local passwords only

User (verbatim):

> for now we have ONLY local passwords.

Assistant action summary: made local-password-only scope explicit in principles,
README, and architecture/API/database plans. Current users store their password
hash and password_set_at on the user record. Provider integrations, credential
tables, method selectors, callbacks, and linking infrastructure are not part of
the current implementation. Earlier provider discussions remain future
considerations only. No implementation code changed.

