# YVS User API

A planned PHP/MySQL authentication service for independent service backends,
with an administrator interface for service management. Current authentication
scope is local passwords only; external-provider login is a future consideration.

Status: documentation, an imported unchanged database helper, and a generated
[initial MySQL schema](database/migrations/001_initial_schema.sql). The schema is
not deployed or execution-tested; the helper is not integrated. No runnable PHP
application, dependencies or test suite yet. See the [database design](docs/database.md).

## Start here

1. Read [project principles](PRINCIPLES.md) for current decisions and constraints.
2. Read the [original task](technical_task.md) for the initial requirements.
3. Use the [project map](PROJECT_MAP.md) to locate components.
4. Read [conversation history](chats/CHAT_HISTORY.md) for decisions and their context.
5. See the [documentation index](docs/README.md) for implementation planning.

Implementation code requires an explicit user instruction. Framework, PHP/MySQL
versions, dependencies, and hosting choices remain undecided.
