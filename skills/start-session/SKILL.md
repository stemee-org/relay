---
name: start-session
description: Start a work session - read the project's documents to see what was done and what is next, ask which tasks to take, then load the plugin skills the work needs (mattpocock-skills for the technical parts, ponytail for the code). Use at the beginning of a session or when asked "where are we" / "catch me up".
---
Three moves, in this order: read the documents, ask which tasks, load the skills. No code is read or written before the user has chosen.

It works on a repo set up with the documentation-first method (`/new-project`): `docs/STATUS.md`, `docs/PLAN.md`, `docs/handover/`, `docs/tasks/`. If those documents are not there, say so, offer `/new-project` to create them, and stop: do not guess the state of the project from the code.

## 1. Read the documents
Only the Markdown documents, not the codebase: the code is read later, for the task that was chosen.

1. `docs/STATUS.md`, the newest file in `docs/handover/`, and `docs/PLAN.md` (goal, milestones, task board). `CLAUDE.md` is already loaded. If the current branch is behind, read the copies on `main`: `git show origin/main:docs/STATUS.md`.
2. What the documents on `main` cannot know. Work that is not merged lives on other branches and in open pull requests, and a task claimed there is claimed:
   - `git fetch --all --prune`, `git status`, `git log --oneline -10`: uncommitted work, branch mismatch, branch behind `origin/main`.
   - Open pull requests: `gh pr list --state open --json number,title,headRefName,author,isDraft,updatedAt`.
   - Branches with unmerged work: for every `origin/*` branch except `main`, `git log --oneline origin/main..<branch>` (skip those with no commits ahead), with author and date of the last commit (`git log -1 --format='%an %ar' <branch>`).
   - What those branches say about the plan: `git diff origin/main...<branch> -- docs/PLAN.md docs/STATUS.md` (three dots: only their changes). A task claimed or moved forward there counts as claimed, even if `main` still says `todo`.
   - Recently merged pull requests (`gh pr list --state merged -L 5`): if `PLAN.md` or `STATUS.md` still call one of them open, say so.
3. Summarize in under 10 lines: what was done, what is in progress (by whom, with the branch or pull request), what comes next. List each unmerged branch in one line.

## 2. Ask which tasks
1. Ask the user which task or tasks they want to do. Propose those that nothing blocks (every task in «Blocked by» is `done`) and nobody has claimed, each with one line on why it comes now. If what they want is not on the board, or a task needs to change first, that is `/replan`: do it before claiming.
2. For each task chosen, read its card in `docs/tasks/` and what it links (ADRs, its plan in `docs/plans/`). If it is claimed by someone else, on `main` or on any branch from step 1, stop and tell the user.
3. Claim it in `PLAN.md` (owner and branch) on its own branch from `origin/main`. Several tasks are taken one at a time, each on its own branch, unless the user says otherwise.
4. Rename the session with `mcp__ccd_session_mgmt__set_session_title` (`session_id: "self"`): the task id plus a short description, e.g. `T09 · login form`; with no task chosen (only a catch-up), what the session is for, e.g. `Catch-up 2026-11-14`. Never leave the default "New session". Load the tool with `ToolSearch` (`select:mcp__ccd_session_mgmt__set_session_title`) if it is only deferred; if it is not available at all, say so and move on.

## 3. Load the skills for the work
The two plugins of this repo (`CONTRIBUTING.md`, «Plugins») do the heavy lifting: `mattpocock-skills` for the technical parts, `ponytail` for the code. Load a skill with the `Skill` tool before the part of the work it covers and follow what it says; never apply it from memory.

1. Check both are there: their skills appear in the list of available skills as `mattpocock-skills:<name>` and `ponytail:<name>`. If one is missing, say so with the line to install it (`CONTRIBUTING.md`, «Plugins») and go on without it: do not imitate it.
2. Technical parts, from `mattpocock-skills`. Pick by what the task needs, and say in one line which ones you loaded and why:

   | The task needs | Load |
   |---|---|
   | To be pinned down: the card leaves real choices open | `grilling` (the user can also run `/grill-with-docs`) |
   | A design: where a module's boundary goes, what its interface is | `codebase-design` |
   | A new word, or a decision to record | `domain-modeling`, then `/adr` |
   | Behaviour to build or change | `tdd` |
   | A defect or a regression | `diagnosing-bugs` |
   | An answer only a throwaway experiment gives | `prototype` |
   | Facts from documentation or other primary sources | `research` |
   | Review, in the last wave | `code-review`, beside the `code-reviewer` agent |

3. Code, with `ponytail`: load `ponytail:ponytail` before the first line of code is written or changed, and keep to it for the whole task: look for what already exists (this codebase, the standard library, the platform, an installed dependency) and write only what the task needs. Before the pull request, `ponytail:ponytail-review` on the diff. Ponytail reaches subagents on its own; name the `mattpocock-skills` skill a writer must load in its prompt, because subagents do not look for it.
4. Stack plugins: `CONTRIBUTING.md`, «Plugins», may list others chosen for this project (guides for browser code, a real browser to check a page, current library documentation). Use each one for the part of the work its line names, before that part and not after; one that is listed but not installed is said, not imitated.
5. The project comes first: ADRs, `CLAUDE.md` and the task's card win over any plugin skill, and what a skill produces goes in the project's documents (`docs/agents/` says where), never in files of its own. Ponytail does not cut what the rules require: tests, validation, the handover and the documents stay.

## 4. Show the team, then start
Before changing any file, without being asked (`CONTRIBUTING.md`, «How a task is built»):
- Name the model this session runs on. The orchestrator must be the best one available (named in `CLAUDE.md`, «Rules»): if it is another model, say so first and ask whether to go on.
- Print a table with wave, subtask, model, effort and why, and next to it the skills loaded in step 3. If the task has a plan in `docs/plans/`, the table is its `Team` section; otherwise propose one from the table in `CONTRIBUTING.md` («Models and efforts»). A task of a few files gets a single row («orchestrator, no subagent»): show it anyway.
- Wait for the user's go-ahead. A task bigger than a few files with no plan yet goes through `/plan` first.

While working: something that is not in the task's card goes through `/replan`, which decides with the user whether it belongs to this task or is a new one. The session closes with `/end-session`.
