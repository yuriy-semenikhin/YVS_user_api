# Security requirements

Use HTTPS, cryptographically random service/session credentials, PHP password
hashing/verification, input validation and service/user/session ownership checks.
Keep deployment credentials outside source and shared documentation. Do not expose
internal database errors through JSON responses or log passwords/bearer tokens.
Use UTC for expiry decisions. Password age is an advisory only.

Admin authentication is separate from service/user authentication. Protect its
state-changing forms with CSRF checks and its cookies with appropriate secure
settings. Concrete admin bootstrap and session settings remain open.

Handle SQL values and identifiers safely without mandating a database abstraction
or prepared-statement rewrite. The imported helper remains unchanged until
implementation is requested. Its current error/configuration behavior must be
addressed before deployment.

Do not assume a fixed rotation grace period. Revision 001 stores service tokens
recoverably for replacement delivery and session tokens as SHA-256 digests. See
[the documented database-read exposure tradeoff](database/normalization.md).
Rotation implementation follows the conditional writes in the database design;
the protocol itself remains a [proposal](services.md). Rate limiting and security audit logs were earlier recommended
additions; keep their scope proportionate when implementation is designed.
