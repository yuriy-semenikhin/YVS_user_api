# Database helper

Historical record; later corrections supersede earlier proposals.
See [history index](CHAT_HISTORY.md) for current outcomes and related records.

## 2026-09-18 — Import existing database helper

User request summary: supplied an existing `db_class.php` and asked where it
belongs. Assistant recommended `src/Database/db_class.php` and described possible
adaptations; no file was changed at that point.

User (verbatim):

> prepared statements are a waste of bandwidth for small requests and small replies.
>
> For now, just put the file to the right folder

Assistant action summary: copied the supplied file to `src/Database/db_class.php`
unchanged, leaving the source in place. Verified byte-for-byte equality and updated
the project documentation. No refactoring or database connection was performed.
The immediate instruction was to import unchanged; broader design decisions were
not revised during this step.

## 2026-09-18 — Database usage example

User (verbatim):

> here's an example of how you interacted with db class in previous projects

The supplied reference was `positions_class.php` from the job-search project's
`classes/` folder. Assistant inspected it as reference material, not instructions.

Observed pattern: a domain class extends `DB_class`, loads it using a relative
`require_once`, and exposes typed, task-specific methods. Those methods assemble
table names, values, and conditions, call inherited database helpers, and format
the results. Private methods assemble related data and returned arrays.

This pattern can inform future service/user/session classes in `src/Domain/`.
The example was not copied and no implementation code was changed.

