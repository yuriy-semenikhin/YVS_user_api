# Deployment planning

No deployable application exists. Use the latest stable PHP release when
implementation begins and record its exact version; require MySQLi and MySQL.
Hosting does not support transactions or stored procedures. No framework or
additional runtime dependency is selected.

Serve only public/ and keep source, templates, configuration, documentation and
runtime logs outside public access. Exclude public-folder README notes from a
production artifact or deny access to them. Supply database credentials through
private configuration; do not use the imported helper's original project settings.

Specify HTTPS configuration, PHP extensions, schema setup, private runtime write
permissions, and initial administrator bootstrap during implementation. Add
operational commands only when needed. Request-driven per-user cleanup does not
require a background scheduler. No installation/startup commands exist yet.

Hosting assumption: restricted free shared hosting. Primary database installation
is through the host's control panel/phpMyAdmin; shell and remote MySQL access
are optional, not requirements. Use the MyISAM schema without foreign keys,
transactions, procedures, triggers, events or background workers. Any PHP version
selection must also respect the host's available runtime; record a limitation
if the latest stable release is unavailable rather than claiming it is installed.
