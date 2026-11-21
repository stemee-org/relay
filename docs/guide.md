# A guide to relay

**English** · [Italiano](guida.md)

How to use each command, what to expect and what stays in the repo. To install it and for an overview: [README](../README.md).

- [The cycle](#the-cycle)
- [`new-project`: setting up the repo](#new-project-setting-up-the-repo)
- [`start-session`: opening a session](#start-session-opening-a-session)
- [`replan`: changing the plan](#replan-changing-the-plan)
- [`plan`, `adr`, `write-prompt`](#plan-adr-write-prompt)
- [`end-session`: closing a session](#end-session-closing-a-session)
- [Tasks](#tasks)
- [Working with several people](#working-with-several-people)
- [Frequent questions](#frequent-questions)

## The cycle
```
/relay:new-project            once
        │
        ▼
/relay:start-session  ──►  work on the task  ──►  /relay:end-session
        ▲                        │                       │
        │                        ▼                       │
        │                 /relay:replan                  │
        │            (the plan must change)              │
        └──────────────── next session ◄─────────────────┘
```

Three rules hold everything together:

- **What is not in the repo does not exist.** A session begins by reading the documents and ends by updating them.
- **Each piece of information has one home.** The other documents link to it.
- **Nothing fake.** No command that does not exist, no date nobody fixed, no decision nobody took.

## `new-project`: setting up the repo
```
/relay:new-project [folder or name] [reference]
```

Examples:

```
/relay:new-project                               in the current folder, from scratch
/relay:new-project billing                       in a new folder
/relay:new-project . ../prototype                rebuilding a prototype
/relay:new-project . https://github.com/org/repo taking an existing repo as inspiration
```

The **reference** is anything the project is meant to rebuild, copy or do better than: a prototype, an older version, someone else's product, a specification, some PDFs. It is only read, never changed.

### What happens
1. **It creates the documents**, without asking anything. In a repo that already has some of them it overwrites nothing: it lists the ones it left as they were and merges them later, by hand.
2. **It installs the supporting plugins** (`mattpocock-skills` and `ponytail`) for that repo only, and enables them for whoever opens it. If the installation fails it leaves you the commands to type and goes on.
3. **It reads the whole reference**, then asks the **technical questions**. It asks only what reading does not answer, and every question has three parts: what it found, what it recommends, what the answer changes. For example:

   > In `api/import.py` the SQL queries are built by joining strings. I recommend parameterised queries: it is the first thing a security review would stop. If you agree, it becomes a fix inside the import task, not a task of its own.

   The questions cover: the relationship with the reference, what goes into the first milestone, stack, structure, data, access, external services, quality bar, people.
4. **It records the decisions** (one ADR for each hard-to-reverse choice), the glossary and the architecture.
5. **It proposes the stack plugins**, if the stack calls for any, telling you what each one runs or sends out: see [the frequent questions](#frequent-questions). It installs only those you accept.
6. **It shows the list of tasks and waits.** For each one: title, why it exists, what works at the end, what blocks it. You can ask to merge, split, drop or reorder. This is the point where the skill stops and waits.
7. **It writes the cards**, fills in the rest of the documents, checks that nothing is left incomplete and commits on the branch `<name>/T00-docs-setup`.

At the end it tells you which documents it wrote, which decisions it recorded, how many questions are still open and which task to take first.

### What it does not do
It writes no product code. It does not push or open a pull request without asking. It does not make things up: a stack choice that is still open becomes a «proposed» ADR and a task to decide it.

### Running it again
It can be run again on the same repo: it skips what is already there and resumes from the first incomplete point.

## `start-session`: opening a session
```
/relay:start-session
```

1. **It reads the documents**: status, latest handover, plan. Only the Markdown files, not the code. It also looks at unmerged branches and open pull requests, because a task claimed there does not show on `main` yet, and deletes the branches of pull requests already merged.
2. **It summarises** in under ten lines: what was done, what is in progress and whose it is, what comes next.
3. **It asks which tasks you want to do**, proposing those that nothing blocks and nobody has claimed. For the one chosen it reads the card, puts your name on it in the plan and creates the branch.
4. **It loads the skills** that work needs and tells you which:

   | The task needs | Skill loaded |
   |---|---|
   | To be pinned down | `grilling` |
   | A design: a module's boundaries and interface | `codebase-design` |
   | A new term or a decision | `domain-modeling`, then `/relay:adr` |
   | Behaviour to build or change | `tdd` |
   | A defect | `diagnosing-bugs` |
   | A throwaway experiment | `prototype` |
   | Facts from documentation | `research` |
   | Code, always | `ponytail`, before the first line |
   | What a stack plugin covers | The one the project chose: see `CONTRIBUTING.md` |

5. **It shows the team**: which parts the main session does and which the subagents do, on which model. It waits for your go-ahead before touching a file.

If what you want to do is not in the plan, the skill sends you to `/relay:replan` first. If a supporting plugin is not installed it says so and goes on without it.

It also works just to catch up: «where are we?» stops at the summary.

## `replan`: changing the plan
```
/relay:replan [what changes]
```

Examples:

```
/relay:replan add PDF export for invoices
/relay:replan T12 is too big, split it
/relay:replan drop T09, we no longer need it
/relay:replan T15 must come before T11
/relay:replan while working on T07 it turned out amount validation is missing
```

### The cases
| Case | What happens |
|---|---|
| **Add** | A new card and a new row. First it checks that no existing task already covers it |
| **Change** | The card's sections change, with a dated line saying what and why |
| **Split** | The original keeps its id with a narrower scope, the rest takes a new id |
| **Merge** | One id survives and its card says which task it absorbed |
| **Reorder** | The blockers between tasks change; it checks that no cycle appears |
| **Drop** | Row and card go; one line stays in the non-goals with the reason |
| **In flight** | A piece of work that came up in the middle of a task: see below |

For a piece **in flight** the skill decides with you where it belongs:

- Without it the task in progress cannot be called done → it is part of the task, and the card is corrected.
- It can wait → it is a new task. The task in progress is not widened in silence.
- It must be done first → it is a new task that blocks the one in progress.

### What happens
1. It works out which case it is and asks only what is missing.
2. It reads the plan, the cards involved and every place in the documents that names those tasks, on unmerged branches too.
3. It works out the impact: board, cards, other tasks' blockers, milestones, decisions, glossary, architecture, status.
4. **It shows the before and the after**, with the list of documents touched, and waits for your go-ahead.
5. It writes everything together, checks consistency and commits.

### Rules that do not bend
- An id is never reused, not even that of a dropped task.
- A task already `done` is not rewritten: what it left out is a new task.
- Someone else's task is not changed without hearing them.
- A change that goes against a recorded decision needs a new decision first (`/relay:adr`).
- Every change leaves in the card the date, the reason and who asked.

A change that concerns only the task in progress is committed on its branch. Any other goes on a branch of its own and through a pull request, because the plan on `main` is what the others read.

## `plan`, `adr`, `write-prompt`
**`/relay:plan`**: before a task that touches more than a few files. It reads the architecture, the decisions and the code involved, asks you what it would otherwise have to guess, and writes `docs/plans/<task>-<name>.md`: goal, what is out of scope, approach, team, small verifiable steps, tests. It waits for approval before any code is written.

**`/relay:adr`**: when a hard-to-reverse choice is made (library, data model, authentication, hosting). It creates a numbered file in `docs/decisions/` with context, decision, alternatives and consequences. An accepted decision is not edited: it is superseded by a new one.

**`/relay:write-prompt [task] [opus|fable]`**: when you want to hand a whole task to another session. It writes the prompt, ready to paste, for an orchestrator model with its team of subagents. It only writes the prompt: it does not run the task.

## `end-session`: closing a session
```
/relay:end-session
```

Two cases, one skill.

**The task is finished:**

1. It checks the branch: never `main`.
2. It runs test, lint and type-check. If one fails it fixes it and tries again.
3. It has the diff reviewed: the `code-reviewer` agent, `security-auditor` if the task touches input, access or payments, plus the reviews of the supporting plugins if installed.
4. It writes the handover and updates the status and the task's row. If unplanned work came up it sends you to `/relay:replan`.
5. It commits: the message says what changes, why, what was discarded, how it was verified and what is still unverified.
6. **It asks** whether to push and open the pull request. Then it checks the CI and marks the task `in review`.

**You stop halfway:** it writes the handover and the status, commits, and pushes only if you ask. No pull request. The handover says exactly what is half-done and what the next move is.

In no case does it merge the pull request: that is a separate decision. When you do ask for the merge, the branch is deleted with it.

## Tasks
The board in `docs/PLAN.md` has one row per task: id, title, milestone, what blocks it, whose it is, branch, status. A task can be taken when every task that blocks it is `done`.

Each task also has a card in `docs/tasks/`:

| Section | Says |
|---|---|
| Title | What works when it is done |
| Why | Why it exists and why at this point: what it unblocks, which decision it comes from |
| What to build | The behaviour at the end, seen by whoever uses it |
| From the reference | Where the original is; what is kept, what changes and why, what is dropped |
| Done when | Checks someone can run or see |
| Out of scope | What you would expect here and is somewhere else |
| Notes | Decisions that apply, open questions, changes with their date |

A badly written task:

> **T07 · Invoices backend.** Port the invoice code from the prototype. Done when it works.

The same task written well:

> **T07 · A customer can create an invoice and see its total**
>
> **Why.** It is the first feature and it cuts through database, API and page: T08–T12 copy its shape, so a mistake here is cheapest to fix now. Amounts follow ADR 0006 (integers in cents).
>
> **What to build.** A logged-in customer adds lines to a new invoice, saves it and sees net, tax and total; reopening it shows the same numbers.
>
> **From the reference.** `server/invoices.js`. Keep: rounding per line. Change: amounts become integer cents, because the prototype's floats lose a cent on some totals. Drop: the CSV export, which nobody used.
>
> **Done when.** ☐ The totals match the worked cases in the plan. ☐ A line with a negative quantity is refused with a message that names it. ☐ Test, lint and type-check pass.
>
> **Out of scope.** PDF download (T08).

The test of a card: someone who was not in the session, with the card alone, can say why the task exists, can start it without asking, and can tell when to stop.

## Working with several people
- **A task has one owner**, written in the plan before starting. `start-session` also looks at unmerged branches, so a task a colleague claimed counts as claimed even if `main` still says `todo`.
- **Everyone works on their own branch** (`<name>/<task>-<description>`) and opens a pull request. Never push to `main`.
- **A merged branch is deleted.** Once the pull request is on `main` the branch goes, on GitHub and on your machine, so that every branch still there means work in progress. `new-project` turns on GitHub's automatic deletion; `start-session` removes the ones left behind.
- **Handovers, decisions and plans are one file per entry**: no conflicts, and nobody edits someone else's file.
- **Whoever opens the repo gets the plugins**: `.claude/settings.json` enables them and Claude Code offers to install them.

## Frequent questions
**Does it work on a repo that already has code?**
Yes. The kit is added around the code without moving anything; the documents describe what exists and the plan starts from today's defects.

**What language are the documents in?**
You choose it during the questions. Section headings stay in English, because the skills look for them; code, comments and names are in English.

**Do I have to use `mattpocock-skills` and `ponytail`?**
No. If they are missing, `start-session` and `end-session` say so and go on without them. To stop them being offered to whoever opens the repo, remove them from `enabledPlugins` in `.claude/settings.json`.

**Which other plugins does it propose?**
Three, each only if the stack calls for it. `modern-web-guidance` for code that runs in a browser: guides only, nothing runs. `playwright` to check pages in a real browser: it starts a local server with `npx`, so it needs Node. `context7` for current library documentation: the library names and the questions go to a hosted service, so it is not for a project whose dependencies are confidential. Any other plugin can be added by asking; the skill first reads what it adds and warns if it repeats something already there.

**Does `ponytail` switch itself on in all my projects?**
No: `new-project` installs it for that repo only.

**Can I change a skill for my project?**
The skills live in the plugin, not in the repo, so they update by themselves but cannot be adjusted in place. A project's own rules go in `CLAUDE.md` and `CONTRIBUTING.md`, which come before any skill. For a different skill: clone this repo, change it and install it with `./install.sh claude`.

**I use Codex or another agent.**
Clone the repo and run `./install.sh codex`: it links the skills into the agent's folder. This has not been tested end to end yet.

**How do I update the plugin?**
It updates with the marketplace. By hand: `/plugin marketplace update stemee-org`.

**I ran `/setup-matt-pocock-skills`. Is that a problem?**
It moves the glossary, the decisions and the tickets to places other than the kit's. The kit already contains what that setup writes (`docs/agents/`), pointed at its own documents: there is no need to run it.

**What does the check script look at?**
`scaffold.sh --check <repo>` lists the `{{…}}` placeholders left, the tasks on the board with no card, the cards with no row, and the cards that do not say why, what or when the task is done. `new-project` and `replan` run it; if it prints nothing, everything is in order.
