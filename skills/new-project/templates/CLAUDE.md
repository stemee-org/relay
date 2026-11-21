# {{project}}

{{One or two sentences: what this does and for whom. With a reference: what it is, pinned (repo `branch` @ `commit`), and that it stays read-only.}}

## Stack
- {{e.g. TypeScript · Next.js · Tailwind · Postgres}}
- Package manager: {{pnpm}} — never mix package managers.

## Commands
{{List only commands that exist. One that a task still has to create is written as «created by T<n>».}}
- Install: `{{pnpm install}}`
- Run: `{{pnpm dev}}` → http://localhost:{{3000}}
- Test: `{{pnpm test}}`
- Lint: `{{pnpm lint}}`
- Format: `{{pnpm format}}`
- Type-check: `{{pnpm typecheck}}`
- Build: `{{pnpm build}}`

## Conventions
- {{Language of documents; headings of the templates stay in English because the skills use them. Code, comments and names in English.}}
- {{Naming, folder rules, error handling, data fetching: only what is not obvious from the code. Link the ADR behind each.}}
- Config comes from env vars; every new one goes in `.env.example` with a placeholder.

## Rules
- Run test, lint and type-check before saying a task is done. If one fails, fix it; don't skip it.
- New behaviour gets a test; a bug fix gets a regression test that failed before the fix.
- Every task starts from the team, without being asked. Before changing a file the main session acts as orchestrator and shows the team table in chat (subtask, model, effort, why), then waits for the go-ahead. It holds for any work that changes the repo, even a few files: there the table has one row («orchestrator, no subagent») and is shown anyway. Not for questions and read-only sessions.
- The orchestrator is the best model available: {{Fable 5.2, or Opus 5.5 with effort `high` or `xhigh`}}. A session cannot change its own model: on another one it says so first, before the table, and asks whether to go on.
- For a feature bigger than a few files, also write a short plan (`/plan`) and get it approved before coding: the table shown in chat is its `Team` section. Practice and models table: `CONTRIBUTING.md` («How a task is built»).
- {{With a reference: one task at a time is ported, reading the original and applying the ADRs; never copy whole folders without a task in `docs/PLAN.md`.}}
- Don't edit by hand: {{generated files (→ the command that regenerates each)}}, lockfiles, {{applied migrations}}.
- Never write real secrets into any file.
- Git: never push to `main`. Every change, documents included, starts on a branch `<name>/<task-id>-<short-desc>` and goes through a pull request; merging it is a separate decision, to be asked; once merged, its branch is deleted. Commits `<type>: <what>` (feat, fix, docs, refactor, test, chore); a pull request title has the same form with the task at the end: `feat: … (T18)`. Never force-push.
- Every task ends committed, documents and handover included. Every commit explains itself: the subject says what changes; the body says why, what was chosen and what was discarded, how it was verified and what is still unverified. Same for the pull request description: the reader was not in the session.

## Docs
- The skills of the working cycle come from the plugin `relay` (`CONTRIBUTING.md`, «Plugins»): `/start-session`, `/replan`, `/plan`, `/adr`, `/write-prompt`, `/end-session`.
- Start of session: run `/start-session` (or read `docs/STATUS.md` + latest `docs/handover/`).
- End of session: run `/end-session` (verification, handover, status, commit, pull request).
- The plan changes with `/replan` (add, change, split, merge or drop a task, or place work that came up halfway): never by editing a row alone.
- Plan and task ownership: `docs/PLAN.md`; what each task is and why: its card in `docs/tasks/`. Never start a task claimed by someone else.
- Why things are the way they are: `docs/decisions/`. Don't reverse a decision without a new ADR (`/adr`).
- Each fact lives in one doc; link, don't copy.

## Agent skills
What the skills of the `mattpocock-skills` plugin look for. Written by the kit: `/setup-matt-pocock-skills` is not to be run here.

### Issue tracker
Tasks live in this repo: board in `docs/PLAN.md`, one card per task in `docs/tasks/`. See `docs/agents/issue-tracker.md`.

### Domain docs
Single-context: `docs/GLOSSARY.md` and the ADRs in `docs/decisions/`. See `docs/agents/domain.md`.

## Gotchas
- Notes that only matter in one part of the repo go in that folder's `CLAUDE.md`; here stay those of the whole repo.
- {{Filled in over time: one line per non-obvious pitfall.}}
