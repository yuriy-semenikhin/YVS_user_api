# User authentication

Confirmed through discussion: one user belongs to one service; current accounts
use ONLY local passwords. Use a generated unique alphanumeric user ID for login.
Store passwords using `password_hash()` and verify with `password_verify()`.

Store `password_set_at` when the password is created and reset it when replaced.
This is the current password's age, not the age of the user account. Suggest a
change after six months; do not enforce expiry, deny login, restrict access or
revoke sessions merely because of password age.

Existing delegated defaults: interpret six months as calendar months in UTC,
clamping the anniversary to the target month's last valid day. Suggest only after
that anniversary. Return `password_change_suggested` on successful login and
session validation; replacement clears it. A password-change endpoint's details
remain unspecified; the timestamp rule does not finalize that contract.

Future consideration only: Google, Facebook or other confirmed external login
providers. Such accounts must have NO local or fallback password and no password
reminder. Do not add provider tables, adapters, linking, or method-selection flows
now. Never support mixed local/provider login for the same account under this plan.

Context: [authentication discussions](../chats/04-authentication-decisions.md).
