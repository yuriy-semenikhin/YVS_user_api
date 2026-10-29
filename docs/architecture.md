# Architecture

Current design combines the [saved task](../technical_task.md) with the
[discussion decisions](../PRINCIPLES.md). No runnable application exists.

Use object-oriented PHP with MySQLi and MySQL, no PDO, transactions or stored
procedures. Initial usage is the owner's personal services with at most one
concurrent user; this does not preclude overlapping backend requests. Keep
update/retry handling proportionate and avoid unnecessary layers.

Service backends call the JSON API. A service request form creates pending
registrations; separately authenticated administrators approve them and generate
initial credentials. Users belong to exactly one service and use local passwords.

| Location | Responsibility |
| --- | --- |
| `public/` | Sole web root: entry points and static assets |
| `src/Http/` | Request validation, service authentication, JSON responses |
| `src/Domain/` | Service, user and session operations |
| `src/Database/` | Reusable MySQLi helper |
| `src/Admin/` and `templates/` | Admin workflows and views |
| `config/` | Configuration loading; no hardcoded deployment secrets |

The imported `DB_class` is unchanged and not integrated. The supplied example
uses domain classes extending it, calling inherited helpers from typed operation
methods and formatting results in private methods. Use this simple pattern as
the design reference; no additional repository layer is required by the task.

External-provider login is future scope only; do not build provider infrastructure
now. Future confirmed-provider accounts must have no local password.
