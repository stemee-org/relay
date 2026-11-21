# The method

Several people, each with their own Claude Code, work on one repo at different times. What is not written in the repo, the others do not know. So every session starts from the documents and ends by updating them. It works the same for one person: the next session is always a stranger.

## Principles
- **One fact, one home.** Link, don't copy. A fact written twice goes stale in one of the two places.
- **Current state beats history.** `STATUS.md` is overwritten; handovers keep the history.
- **One file per entry for anything several people write** (ADRs, handovers, plans): no merge conflicts, nobody edits someone else's entry.
- **Claim before you start.** A task has one owner, written in `PLAN.md` before work begins.
- **The plan changes on purpose.** A task is added, changed or dropped with `/replan`, which moves every document that depends on it and writes down why.
- **Short beats complete.** A document nobody reads protects nothing.
- **Written from reading is not confirmed.** What a session inferred is marked as such until a person confirms it.
- **A task explains itself.** Someone who was not there can say why it exists, start it and tell when to stop, from the card alone.
- **Nothing fake.** No command that does not exist, no date nobody fixed, no decision nobody took.

## The documents
| File | Answers | Changes |
|---|---|---|
| `CLAUDE.md` | What a session must know and cannot see in the code: stack, commands, conventions, rules, gotchas | When a rule or a pitfall appears. Loaded every session: keep it short |
| `<part>/CLAUDE.md` | Notes that only matter inside one part of the repo | Same; loaded only when working there |
| `README.md` | What this is and how to start, for people | Rarely |
| `CONTRIBUTING.md` | How we work: branches, the team practice, models, area owners, plugins | When the practice changes; say who asked and when |
| `docs/PLAN.md` | Goal, non-goals, milestones, task board, open questions | Claiming or finishing a task |
| `docs/tasks/` | One card per task: why it exists, what to build, when it is done. The board row holds what changes (owner, status, blockers), the card what does not | When a task is created or its scope changes |
| `docs/agents/` | Where plugin skills find tasks, glossary and ADRs | When those move |
| `docs/STATUS.md` | What is true right now, one screen | End of every session, overwritten |
| `docs/ARCHITECTURE.md` | How the system fits together, folder level | When the structure changes |
| `docs/GLOSSARY.md` | The project's words, one meaning each | When a term appears |
| `docs/decisions/` | Why X and not Y (ADRs) | One new file per decision; accepted records are never edited, only superseded |
| `docs/handover/` | What happened in each session, what is half-done, what to watch out for | One new file per session |
| `docs/plans/` | The plan of a feature bigger than a few files, approved before coding | One file per task |
| `docs/proposals/`, `docs/reviews/` | Created when first needed: proposals as presented (what is decided moves to an ADR); review material per task | — |

Non-goals in `PLAN.md` matter as much as goals: they stop a session from starting what was already ruled out. Each one links the ADR that ruled it out, when there is one.

## Rules the kit installs
- Test, lint and type-check pass before a task is called done. New behaviour gets a test; a bug fix gets a regression test that failed before the fix.
- A feature bigger than a few files gets a plan (`/plan`) approved before coding.
- A decision is reversed only by a new ADR.
- Generated files, lockfiles and applied migrations are not edited by hand; the hook `protect-files.sh` enforces it from `.claude/protected-paths`.
- No real secret in any file; config from env vars, each one in `.env.example` with a placeholder.
- Git: never push to `main`. Every change, documents included, starts on `<name>/<task-id>-<short-desc>` and goes through a pull request; merging is a separate decision. Never force-push.
- Every task ends committed, documents and handover included. A commit explains itself: the subject says what changes; the body says why, what was chosen and what was discarded, how it was verified and what is still unverified. The same for the pull request: the reader was not in the session.
- A new pitfall becomes one line in `Gotchas` of the right `CLAUDE.md`, when it is found.

## Team
Every task starts from the team, without being asked.
- The main session is the orchestrator and runs on the best available model. A session cannot change its own model: on another one it says so first and asks whether to go on.
- Before changing a file it prints the team table in chat (wave, subtask, model, effort, why) and waits for the go-ahead. A task of a few files has one row («orchestrator, no subagent») and it is shown anyway, so the choice not to delegate is visible. Questions and read-only sessions are exempt.
- Subagents write, never commit; two working at once never share files. The orchestrator keeps plan, shared dependencies, verification, commits, documents and pull request.
- A subagent's work is verified, not trusted: at the end of each wave the orchestrator reads the diff and runs test, lint and type-check, then commits.
- The last wave checks: independent review of the diff (`code-reviewer`), a security review when the task touches input, access or payments (`security-auditor`), a run of the real app when what the user sees changes. What stays unverified is written in the handover and in the pull request.
- Model and effort are sized on the piece of work, from the table in `CONTRIBUTING.md`, and passed explicitly on each `Agent` call.

## The session loop
`/start-session` (reads the documents and what is not yet on `main`, asks which tasks, loads the plugin skills the work needs: `mattpocock-skills` for the technical parts, `ponytail` for the code, plus the stack plugins the project chose) → claim → team table → `/plan` if the task is big → work in waves → `/end-session` (verify, review, handover, status, commit, pull request). `/replan` whenever the plan must change or work comes up halfway: tasks, cards and every document that depends on them move together. `/adr` whenever a hard-to-reverse choice is made. `/write-prompt` to hand a whole task to another session.

These skills live in one plugin, `relay`, enabled by the kit's `.claude/settings.json`: the repo holds no copy of them, so a fix reaches every project.

## What experience added
These were learned the hard way; keep them when adapting the kit.
- Look past `main` at the start of a session: a task claimed on an unmerged branch is claimed.
- A merged branch is deleted. Every branch that exists then means work not yet on `main`, which is what the line above relies on.
- Look at the open issues of the repo before writing the plan, not after.
- A rule that changes names who asked and when, in `CONTRIBUTING.md`; the old wording goes.
- Skills and documents drift apart: when a rule changes, grep the project's agents and documents for the old one. This is also why the skills are in a plugin and not copied into each repo.
- The first CI is generic and gets replaced by the scaffold task; say in the handover what it will do on the first push.
- Tests that measure time fail under load: list them in `Gotchas` so nobody hunts a bug that is not there.
