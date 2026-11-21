# Contributing

{{Who works here: names, each with their own Claude Code or not.}} What is not written in this repo the others do not know: every session starts from the documents and ends by updating them.

## Before you start
1. Pull `main`.
2. Read `docs/STATUS.md` and the latest file in `docs/handover/` (or run `/start-session` in Claude Code).
3. Create the branch `<name>/<task-id>-<short-desc>` (without a task: `<name>/<short-desc>`).
4. Claim your task in `docs/PLAN.md` (owner + branch) before starting. Work that is not on the board gets a task first (`/replan`).

## While working
- Never push to `main`: work on a branch, one task at a time, and open a pull request. Also for a change of documents only.
- Small commits; message style: `<type>: <what>` (feat, fix, docs, refactor, test, chore).
- Don't change files owned by someone else's in-progress task without talking to them. Someone else's unmerged branch is not deleted without asking.
- Made a decision others should know about? Write an ADR (`/adr`).
- {{With a reference: porting = read the original, apply the ADRs and the corrections named in the task, add the tests. A defect found in the reference is fixed here and written in the handover.}}

## How a task is built
The default way of working, not something to ask for. One session orchestrates, a team of subagents writes, and whoever is working sees the team before it starts. A «task» is any work that changes the repo; a question or a read-only session is not.

1. **Read first.** {{The original in the reference and}} the state of the repo (code, ADRs, handovers that name the task), before writing the plan.
2. **The team is shown in chat, always.** Before changing a file the orchestrator writes the team table in chat: wave, subtask, model, effort, why. Then waits for the go-ahead. A task of a few files has one row («orchestrator, no subagent»): shown anyway, so the choice not to delegate is visible.
3. **A task bigger than a few files also has a plan.** In `docs/plans/` (`/plan`): the table shown in chat is its `Team` section. The plan is approved before code is written.
4. **The main session orchestrates**, on the best model available: {{Fable 5.2, or Opus 5.5 with effort `high` or `xhigh`}}. A session cannot change its own model: on another one it says so first and asks whether to go on. It keeps plan, shared dependencies (manifests, lockfiles), verification, commits, documents and pull request. Model and effort are passed explicitly on each `Agent` call.
5. **Subagents write, they don't commit.** Two working at once never touch the same files; one that needs another's result waits for it.
6. **A subagent's work is verified, not trusted.** At the end of each wave the orchestrator reads the diff and runs test, lint and type-check, then commits.
7. **The last wave checks.** Independent review of the diff (`code-reviewer`), security review if the task touches input, access or payments (`security-auditor`), a run of the real app if what the user sees changes. What stays unverified is written in the handover and in the pull request.

### Models and efforts
One subagent per independent piece of work, none for a piece that is a few tool calls: the task decides the number. Most of the team is Opus at different efforts; smaller models are for searching and routine work. Never `max` or `low`.

| Work | Model | Effort |
| --- | --- | --- |
| Searching, listing, reading many files, checking links or documents | `haiku` or `sonnet` | default |
| Routine code, tests from a clear specification, documents, translations | `sonnet` | default |
| Standard implementation of a well-specified piece | `opus` | `medium` |
| Non-trivial implementation, refactoring, regression test for a defect | `opus` | `high` |
| {{The hard core of this project: e.g. the engine, parsers, migrations, money, security}} | `opus` | `xhigh` |
| Final review of the whole diff (`code-reviewer`, `security-auditor`) | `opus` | `high` or `xhigh` |

## Before you finish
- Tests, lint and type-check pass.
- After the push, check the CI on the pull request.
- Write a handover in `docs/handover/` (`/end-session` does this and the next two steps).
- Update `STATUS.md` and your task's row in `PLAN.md`.
- Commit and push on the work branch, then a pull request to `main` (`/end-session`). Title in the form of commits, with the task in parentheses at the end. Description with the sections «What changes», «Why this way», «How it was done», «Verified» and «Not verified». Have it reviewed before merging unless told otherwise.
- Once the pull request is merged, its branch is deleted, on GitHub and on your machine: what it held is on `main`, and a branch left behind looks like work still open. GitHub does it by itself when «Automatically delete head branches» is on; `/start-session` removes the ones it finds. A branch with commits that are not on `main` is not merged: it stays.

## Plugins
`.claude/settings.json` enables them: Claude Code offers to install them to whoever opens the repo. ADRs and the documents of this repo come before any plugin skill; what a plugin skill produces is stored in these documents (`docs/plans/`, `docs/tasks/` and the task board, `docs/GLOSSARY.md`, an ADR), never in a parallel set of files. The lists below are checked against `claude plugin details <plugin>`, not written from memory.

- **`relay@stemee-org`** (by hand: `claude plugin marketplace add stemee-org/relay`, then `claude plugin install relay@stemee-org`). The skills of the working cycle; this repo holds no copy of them, so they update with the plugin.

  | When | Skill |
  |---|---|
  | A session starts | `/start-session`: reads the documents, asks which tasks, loads the skills of the other two plugins |
  | The plan must change, or work came up halfway | `/replan`: tasks and every document that depends on them |
  | A task bigger than a few files | `/plan` |
  | A hard-to-reverse choice | `/adr` |
  | A whole task goes to another session | `/write-prompt` |
  | A session ends | `/end-session`: verification, review, handover, status, commit, pull request |

- **`mattpocock-skills@claude-plugins-official`** (by hand: `claude plugin install mattpocock-skills@claude-plugins-official`). Its engineering skills read `docs/agents/issue-tracker.md` and `docs/agents/domain.md`, which point them at this repo's tasks, glossary and ADRs; `/setup-matt-pocock-skills` is not run here, because it would move them. `/start-session` loads the ones the chosen task needs. Where they meet «How a task is built»:

  | When | Skill |
  |---|---|
  | An idea or a task is still vague | `/grill-with-docs` (or `/grill-me`): the answers land in the task card, the glossary or an ADR |
  | A feature has to become tasks | `/to-tickets`: cards in `docs/tasks/` and rows on the board (a single change to the plan: `/replan`) |
  | Writing code | `tdd`; `diagnosing-bugs` for a defect; `prototype` for a throwaway answer to a design question |
  | A new word or a structural choice | `domain-modeling`, `codebase-design` |
  | Last wave | `code-review`, beside the `code-reviewer` agent |

- **`ponytail@ponytail`** (by hand: `claude plugin marketplace add DietrichGebert/ponytail`, then `claude plugin install ponytail@ponytail`). On in every session: before writing code it looks for what already exists (the codebase, the standard library, the platform, an installed dependency) and writes only what the task needs. It never cuts what the rules of this repo require: tests, validation, the handover and the documents stay. `/start-session` loads it before the first line of code; `/ponytail-review` joins the last wave; `/ponytail-audit` ranks the defects of a whole repo, useful on a codebase adopted in place. `/ponytail off` turns it off for a session. In Claude Code it shows a band above the prompt and keeps each task's cost and time in `~/.config/ponytail/band/` on your machine; nothing is sent anywhere unless you set a webhook.

{{Stack plugins chosen in `/new-project`, one bullet each in the same form: when it is used, what it needs, the line to install it by hand. Then one line for those declined and why. None: «No stack plugin».}}

## Area owners
The owner is the person to hear before changing the area, not the only one who may touch it. {{If derived from a reference's history: a proposal until confirmed.}}

| Area | Owner |
|---|---|
| {{e.g. frontend, backend, data}} | {{name}} |
| Documents (`docs/`, `CLAUDE.md`) | whoever closes the session |
