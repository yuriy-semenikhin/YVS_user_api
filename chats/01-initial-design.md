# Initial design

Historical record; later corrections supersede earlier proposals.
See [history index](CHAT_HISTORY.md) for current outcomes and related records.

## 2026-09-18 — Review request

User:

> read technical task and give your feed back or questions.

Assistant response summary:

- Read the brief; found no `principles.txt`; generated no code.
- Asked about account/service ownership, login identifiers, backend versus
  browser access, service-token rotation and confirmation, sliding versus fixed
  session expiry, scope and limits of session counts, invalid-session responses,
  administrator authentication/actions, and portable history format.
- Recommended password hashing, service isolation, expiry checks on every
  validation independently of cleanup, logout/revocation/rate limits, consistent
  errors, and UTC timestamps.

## 2026-09-18 — User clarifications and execution freedom

User (verbatim):

```text
Overall this is high level tasks which implies certain freedom of execution.

1\) one user 1 service, because services could be unrelated

2\) yes and yes, beckend only.

3\) you get to decide

4\) last activity

5\) which one is faster

6\) yes, but you are free to chose a better option

7\) Feel free to add missing option you feel might be necessary

For chat history, we have a main file, but we need a record in case we need clarify something at later date or even a different machine that has no access to current chats.
```

Interpretation and assistant decisions (summary):

- Users are service-specific; only service backends use service credentials.
- User sessions expire after 15 days of inactivity.
- The user delegates token rotation and reasonable missing design choices.
- Choose a per-user active-session count because it scopes the indexed query
  more narrowly; this is not a measured performance guarantee.
- Choose lazy three-hour rotation, a fixed ten-minute previous-token grace
  period, explicit confirmation, and retry-safe replacement delivery.
- Choose structured HTTP 401 authentication responses rather than callbacks.
- Add administrator authentication, disable/reset/revocation, password hashing,
  rate limiting, and audit logging to the design.
- Use generated user IDs for initial login; username/email and recovery remain
  outside initial scope. These are delegated defaults, not explicit user answers.
- Create principles.txt, PROJECT_MAP.md, and this portable record. Preserve the
  original task. Do not generate implementation code without explicit instruction.

The complete current decisions are in `principles.txt`. Nothing described as a
planned feature has been implemented or performance-tested.

