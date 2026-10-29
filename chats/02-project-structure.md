# Project structure

Historical record; later corrections supersede earlier proposals.
See [history index](CHAT_HISTORY.md) for current outcomes and related records.

## 2026-09-18 — Main project structure

User (verbatim; trailing HTML space entity normalized):

> let's start by generating the main project structure.
> .md files and appropriate folders

Assistant action summary:

- Created a documentation-only scaffold for public HTTP entry points, PHP source,
  configuration, database migrations/fixtures, templates, tests, operational
  commands, and private runtime storage. Each directory has a purpose README.
- Added a root README and AGENTS.md pointing future contributors to principles.txt.
- Added architecture, API, database, security, and deployment planning documents.
- Updated PROJECT_MAP.md; preserved principles.txt and the original technical task.
- No implementation code, dependencies, database schema, or runnable tests added.

## 2026-09-18 — Dedicated chat and map folders

User (verbatim):

> I noticed that you have not created folders for storing chats or maps.

Assistant action summary: created `chats/` and `maps/` with README indexes.
Moved the existing history to `chats/CHAT_HISTORY.md` and the project map to
`maps/PROJECT_MAP.md`, preserving previous entries. Updated current instructions,
principles, and navigation links to the new locations. Earlier history entries
retain the paths used at that time. No implementation code changed.
