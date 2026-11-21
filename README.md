# relay

**English** · [Italiano](README.it.md)

A Claude Code plugin that makes a project work documentation-first: every session starts from the repo's documents and ends by updating them. As in a relay race, the documents are the baton.

## What it is for
A coding agent does not remember the previous session, and a colleague does not know what you did yesterday with yours. Whatever is not written in the repo is lost: work gets redone, a decision already taken is reopened, two people pick the same task.

`relay` solves this with three things:

- **One place for each piece of information.** What is being built, which tasks are left, why a choice was made, what happened in the last session: each has its own document.
- **Tasks that explain themselves.** Every task has a card that says why it exists, what must work at the end and when it is done. Someone who was not there can start it without asking.
- **A fixed cycle.** Seven commands cover the life of the project: setting it up, opening a session, changing the plan, closing the session.

It is meant for people working with Claude Code, alone or several on the same repo, on a new project or on one to rebuild from a prototype.

## Installation
In Claude Code:

```
/plugin marketplace add stemee-org/relay
/plugin install relay@stemee-org
```

Then `/reload-plugins`, or open a new session. You need `git` and, for pull requests, the `gh` CLI.

## The first ten minutes
1. Open Claude Code in the project folder (it can be empty) and run:
   ```
   /relay:new-project
   ```
   If you have a prototype or other material to start from, name it: `/relay:new-project . ../my-prototype`.
2. The skill creates the documents, installs the supporting plugins, reads the material and asks you a few technical questions.
3. It shows you the list of proposed tasks. Correct it until you are happy, then give the go-ahead: it writes the cards and commits.
4. From then on, every working session is:
   ```
   /relay:start-session      choose the task
   …you work…
   /relay:end-session        handover, commit, pull request
   ```
5. When a new task is needed or one must change: `/relay:replan`.

## The commands
| When | Command | What it does |
|---|---|---|
| Once, at the beginning | `/relay:new-project` | Sets up the repo: documents, plugins, technical questions, tasks |
| At the start of every session | `/relay:start-session` | Reads the documents, asks which tasks to take, loads the skills the work needs |
| When the plan changes | `/relay:replan` | Adds, changes, splits, merges or drops tasks, and updates the documents that depend on them |
| Before a big task | `/relay:plan` | Writes the feature plan and gets it approved |
| At every hard-to-reverse choice | `/relay:adr` | Records the decision and the alternatives discarded |
| To hand a task to another session | `/relay:write-prompt` | Writes the prompt for an orchestrator with its team |
| At the end of every session | `/relay:end-session` | Verification, review, handover, status, commit, pull request |

No command writes to `main` or merges a pull request: pushing and opening a pull request happen only after asking.

**How to use each command, with examples: [docs/guide.md](docs/guide.md).**

## What is in the repo after `/relay:new-project`
```
CLAUDE.md                 what every session must know: stack, commands, rules
CONTRIBUTING.md           how we work: branches, team, plugins
docs/
  PLAN.md                 goal, milestones, task board
  tasks/                  one card per task
  STATUS.md               what is true right now, on one screen
  handover/               one file per session: what was done, what is left
  decisions/              the decisions (ADRs): why X and not Y
  plans/                  the plans of big features
  ARCHITECTURE.md         how the system fits together
  GLOSSARY.md             the project's words, one meaning each
.claude/                  permissions, two hooks, three review agents
.github/                  generic CI, issue and pull request templates
```

## The other plugins
`/relay:new-project` also installs and enables for the repo:

- [`mattpocock-skills`](https://github.com/mattpocock/skills), for the technical parts: test-driven development, diagnosing defects, designing modules.
- [`ponytail`](https://github.com/DietrichGebert/ponytail), for the code: it looks for what already exists and writes only what is needed.

Depending on the stack, it also proposes [`modern-web-guidance`](https://github.com/GoogleChrome/modern-web-guidance) (code that runs in a browser), `playwright` (checking pages in a real browser) and `context7` (current library documentation). It asks once and installs only what you accept.

`/relay:start-session` loads their skills when the task calls for them. The project's documents and decisions still come before any skill.

## State
Version 0.4.0. The scaffold, the task check and the installation are tested by `tests/run.sh`, which runs in CI on every pull request. Not tested yet: a real project from start to finish, and use inside Codex.

The method was born while rebuilding stemee from a prototype (November 2026): the kit is the one used there, cleaned of what was specific to that project.

## For those who want to change it
- `skills/<name>/SKILL.md`: the seven skills. Each has one copy, here: the kit does not copy them into repos.
- `skills/new-project/reference/`: the method (`method.md`), how a reference is read (`from-reference.md`), the technical questions and what makes a good task (`tasks.md`), the plugins proposed by stack (`plugins.md`).
- `skills/new-project/templates/`: the kit copied into the project. The `dot-` prefix becomes a dot (`dot-claude/` → `.claude/`).
- `skills/new-project/scripts/scaffold.sh`: copies the kit; with `--check` it lists what is still to fill in.
- `tests/run.sh`: the tests. Run `./tests/run.sh` before every commit.

Whoever changes a rule of the method changes it in `method.md`, in the templates that repeat it and in the skills that apply it: `grep` for the old wording before committing. The documentation exists in English and Italian: a change goes in both (`README.md` and `README.it.md`, `docs/guide.md` and `docs/guida.md`).

## Code of conduct
Taking part in this project means following its [code of conduct](CODE_OF_CONDUCT.md). Unacceptable behaviour can be reported to relay@stemee.eu.

## Licence
[MIT](LICENSE).
