# Project map

PHP/MySQLi API for service-scoped local-password accounts and sliding sessions,
plus service registration requests and admin approval. Status: documentation and
scaffold plus generated schema revision 001 (not deployed); the imported database
helper is not integrated.

Start with [principles](PRINCIPLES.md). Load only the relevant map.

| Component map | Responsibility |
| --- | --- |
| [API](maps/api.md) | Request/response contracts and HTTP handling |
| [Services](maps/services.md) | Registration, approval and token rotation |
| [Authentication](maps/authentication.md) | Local passwords and future-scope context |
| [Sessions](maps/sessions.md) | Activity, expiry, cleanup and counts |
| [Database](maps/database.md) | Schema, table dictionary, indexes and installation |
| [Operations](maps/operations.md) | Admin, deployment and verification |
| [Documentation](maps/documentation.md) | Records and navigation |

[Technical task](technical_task.md) · [Project log](PROJECT_LOG.md) ·
[Conversation index](chats/CHAT_HISTORY.md)
