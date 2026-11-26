---
name: start-multi-session
description: Start several work sessions at once, run from one tab - this session becomes the orchestrator, chooses with the user which tasks can go in parallel, writes one prompt per task for the user to paste in separate tabs, then follows every session from here (questions, files touched, pull requests, CI runs, order of merges). Use when the user wants to work on several tasks in parallel, says "multi session", "open more tabs", "parallel sessions", or invokes /start-multi-session.
---
One tab talks to the user, the others work. This session is the orchestrator: it chooses the tasks with the user, writes one prompt per task, and from then on it is the only tab the user has to read. The other tabs (the worker sessions) each build one task on their own branch, in their own folder, and report here.

The orchestrator writes no code of the tasks. It keeps what no single worker can see: who owns which files, which pull requests are open and in what state, how many CI runs the round is spending, the order of merges, and `docs/STATUS.md`.

It works on a repo set up with the documentation-first method (`/new-project`). If `docs/STATUS.md`, `docs/PLAN.md` and `docs/tasks/` are not there, say so, offer `/new-project` and stop. For a single task, `/start-session` is the right skill: say so and use that.

## 1. The orchestrator's model
Name the model this session runs on. The orchestrator must be Fable 5.2 with effort `high`; where Fable is not available, Opus 5.5 with effort `xhigh`. A session cannot change its own model: on another one, say so first, tell the user to switch (`/model`) and go on only when they have switched or said to go on anyway.

## 2. Read the documents
Step 1 of `/start-session`, whole (`../start-session/SKILL.md`, beside this skill): the documents, then what is not on `main` yet (unmerged branches, open pull requests, leftover branches of merged ones), then the summary in under 10 lines. A task claimed on any branch is claimed.

Then two things this skill needs:
- Whether sessions can talk to each other: `ListAgents` and `SendMessage` (load them with `ToolSearch` if they are only deferred). If they are not available, say it now: the round can still be run, but the orchestrator follows the workers only through git and GitHub, and the user carries the messages by hand. Ask whether to go on like that.
- What CI costs here: read `.github/workflows/` (which events start a run, which commands it runs) and whether `main` requires a branch to be up to date before merging (`gh api repos/{owner}/{repo}/branches/main/protection --jq .required_status_checks.strict`; an error means no such rule). Both go in step 6.

## 3. Choose the tasks and split them
1. Candidates: the tasks nothing blocks (every task in «Blocked by» is `done`) and nobody has claimed. If what the user wants is not on the board, `/replan` first.
2. For each candidate read its card in `docs/tasks/`, what it links (ADRs, its plan in `docs/plans/`) and enough of the code to say which files it will touch. This list is the task's **file set**: paths or globs, written down, not guessed from the title.
3. Decide which can run at the same time. Two tasks run in parallel only if:
   - neither is in the other's «Blocked by», directly or through another task of the round;
   - their file sets do not overlap. Files every task touches (manifests, lockfiles, migrations with a running number, generated files, shared configuration) count: name them and give each to one session only, or to none (step 7, «Shared files»).

   Two tasks that overlap go in the same session, one after the other, or one of them waits for the next round. Do not split a task into two sessions. Overlap is also what costs CI later: two branches that touch the same file conflict at the merge, and every conflict is one more push.
4. The number of sessions comes from the tasks, between 2 and 5. More than 5 is more than one person can follow from one tab: the rest waits.
5. Show the split and wait for the go-ahead:

   | Session | Task | Branch | File set | Model and effort | Why now |
   |---|---|---|---|---|---|

   Model and effort of each worker as `/write-prompt` chooses them (its step 2): the worker is the orchestrator of its own task, with its own subagents. Under the table: the shared files and who has them, the tasks left out with the reason, and the CI runs the round should cost (one per pull request, see step 6).
6. With the go-ahead, ask once the decisions the workers would otherwise each ask in their own tab:
   - whether a worker may push its branch and open the pull request when its checks pass here, without asking again (merging is never included);
   - whether a worker may start right after showing its team, or must wait for a go-ahead given here.

## 4. Prepare the ground
1. Rename this session with `mcp__ccd_session_mgmt__set_session_title` (`session_id: "self"`), e.g. `Orchestrator · T09 T11 T12`. This name is the address the workers write to: it goes in every prompt, exactly. If the tool is not available, read this session's name from `ListAgents` and use that.
2. One folder per worker, so that no two sessions share a checkout: `git fetch origin`, then for each task `git worktree add .claude/worktrees/<task-id> -b <name>/<task-id>-<short-desc> origin/main`. If `git check-ignore .claude/worktrees` says nothing, add `.claude/worktrees/` to `.git/info/exclude` (local, nothing to commit).
3. This session stays in the main checkout, on `main`, and changes no file there.

The claim in `PLAN.md` is made by each worker, on its branch, as its first commit. It is not pushed alone.

## 5. Write the prompts
One prompt per session, each in its own fenced block, in the language of the project's documents, headed by the task id and the model to choose when opening the tab. Write each as `/write-prompt` writes it (`../write-prompt/SKILL.md`, steps 3 and 4: team, goal, constraints, order of work, verification), with one more section at the top, **Multi-session**:

- **Who you are.** One of N worker sessions; the orchestrator is the session named `<exact name>`. The user reads only that tab: nothing is asked here, everything goes there.
- **First moves.** Rename the session `<task-id> · <short-desc>` (`mcp__ccd_session_mgmt__set_session_title`); move into the worktree `<absolute path>` (`EnterWorktree` with `path`, or work with that folder as the root: this prompt asks for a worktree explicitly); install dependencies there if the project needs them (`CLAUDE.md`); claim the task in `docs/PLAN.md` and commit. `/start-session` is not run: this prompt replaces it. The skills of its step 3 are loaded as usual.
- **Your files.** The file set, copied in full. Every other session's file set, by task, as files not to touch. A file outside your set that you need: stop that piece, write to the orchestrator and wait for the answer; go on with what does not depend on it.
- **Shared files.** Who has them. If not you: describe the change you need (the dependency, the configuration line) in a message to the orchestrator instead of making it.
- **Documents.** You write your handover and your row in `docs/PLAN.md`. You do not write `docs/STATUS.md`: the orchestrator does, once, for the whole round. `/end-session` is followed with this exception and with the rules on CI below.
- **CI: one push.** The rules of step 6 for the worker, copied in full, with the commands CI runs here.
- **Messages to the orchestrator** (`SendMessage`, to the name above; to answer one of its messages, copy its `from`). The first line says task and matter in one sentence. Send one when:
  - you have started: branch, worktree, team table;
  - you have a question the documents do not answer, or a decision that belongs to the user;
  - you need a file outside your set, or a change to a shared file;
  - the plan of the task is ready for approval (`/plan`);
  - you are ready to push: what passed here, what could not be run here;
  - the pull request is open: number, files changed, what was verified and what was not;
  - a CI run failed: the failing step and whether you reproduced it here;
  - you stop halfway: what is half-done and the next move.

  If the orchestrator is not listed or does not answer, go on with what needs no answer and say in your tab what is waiting. Silence is never a yes.
- **What the user already decided**: the two answers of step 3.6, in the user's words. Without the first, ask the orchestrator before pushing. Never merge.

Then tell the user, in three lines: open one tab per prompt in this repo, choose the model written above it, paste. Say they can come back here as soon as the tabs are running.

## 6. CI: one run per pull request
With several sessions the CI runs multiply by themselves: every push starts one, and every merge invites all the other branches to update and run again. The target is **one run per pull request**; each run beyond that has a reason the orchestrator can name. A run is spent only on work that has already passed on this machine.

**For each worker** (these go in its prompt):
- Commit as often as you like, push once. No push for the claim, no draft pull request, no push to «see what CI says».
- Before that push, in your worktree: `git fetch origin && git merge origin/main`, then every command CI runs (Test, Lint, Type-check and Build of `CLAUDE.md`, checked against `.github/workflows/`). All pass here, or nothing is pushed.
- Everything rides on that push: the handover, the reviews of `/end-session` step 3 with their fixes, and the row in `PLAN.md` already set to `in review`. The pull request is found from its branch: no second push to add its link.
- A run fails: read the log (`gh run view <id> --log-failed`), reproduce it here, fix everything it shows, run every check again, then one push. A failure you cannot reproduce here is told to the orchestrator before a second attempt: guessing by pushing is what the budget forbids.
- After the pull request is open, no push without a word from the orchestrator. Review comments are answered together, in one push.

**For the orchestrator:**
- Before proposing any merge, try the round as a whole here, at no run: `git worktree add --detach .claude/worktrees/_round origin/main`, merge into it the round's branches in the order you would propose, run the checks once, remove it. A conflict or a failure that only shows together goes back to the session concerned, with the output, before anything is merged.
- After a merge, the other branches are **not** all told to update. A branch gets `origin/main` and a new push only if it conflicts with the new `main`, if the trial above failed with it, or if `main` requires branches up to date (step 2). In that last case one at a time: only the next in the order, right before its turn.
- Fixes for one pull request are gathered and sent together: review remarks, a file outside the set, a change to a shared file. One message, one push.
- Count the runs: `gh run list --branch <branch> --json databaseId,conclusion,event`. The board shows the number per pull request; a second run is explained in the row, and the final report says how many the round spent against how many pull requests it opened.

## 7. Follow the sessions
From here the loop runs until every task is in a pull request, merged or stopped. No worker is trusted on its word: what it says is checked against git and GitHub.

**Who is there.** When the user says the tabs are open, `ListAgents`: every worker must be listed under its name. For each, `SendMessage` with `notify_when_idle: true`, so that a notice arrives when it stops; subscribe again after each notice. Never poll in a loop, never send «are you done?». A worker that is not listed, or a message that is held or refused on the other side, is said to the user: they open that tab once and let it through.

**At every message or notice**, for the session it concerns:
- Files: `git -C <worktree> status --short` and `git diff --name-only origin/main...<branch>`, against its file set. A file outside the set: ask that session why, then either extend its set (if no other session has the file) or have the change undone. A file two sessions have both changed: stop the second one on that file, decide who goes first, tell both. This is done while the work is local, when fixing it costs no run.
- Pull requests: `gh pr list --state open --json number,title,headRefName,isDraft,mergeable,statusCheckRollup` and, for a new one, `gh pr view <n> --json files`. A failing check or a conflict goes back to its session with the output, not with a summary of it.
- Questions: answer from the documents (card, ADRs, `CLAUDE.md`) what they answer. What is the user's to decide is asked here, several questions together when they arrive together, and the answer is sent back in the user's words. A go-ahead is passed on only if the user gave it for that thing.

**Shared files.** A change a worker asks for on a file it does not own goes to the session that owns it, with the reason, before that session pushes. If no session owns it, it becomes a task (`/replan`).

**The board.** Keep one table in chat and print it again whenever a row changes or the user asks «where are we»:

| Session | Task | State | Branch | Pull request | Checks | CI runs | Outside its file set | Waiting for |
|---|---|---|---|---|---|---|---|---|

**What the user says here** about a task is sent to its session with `SendMessage`, as they said it. Work that is on no card goes through `/replan`, in this session, before any worker starts it.

**Order of merges.** When pull requests are open and the trial of step 6 passed, propose the order: first the one others depend on, then the smallest, last the one that touches the most. Never merge without being asked. When the user asks: `gh pr merge <n> --merge --delete-branch`, `git worktree remove .claude/worktrees/<task-id>`, `git pull --ff-only` in the main checkout. Then look at the pull requests still open (`mergeable`) and apply step 6: most of the time nobody has to do anything.

## 8. Close the round
When every task is merged, in review or stopped:
1. `docs/STATUS.md`, once, for the whole round: the state as it is now, linking every handover of the round. It rides on a push that has to happen anyway, when there is one: write the text and send it to the worker whose branch is last in the order and still has a push to make. Otherwise it goes on a branch of its own, `<name>/status-<YYYY-MM-DD>` from `origin/main`: commit, then push and pull request only after asking. It is the one run of the round that carries no code, and the report says so.
2. The worktrees of merged tasks are removed (`git worktree list` shows none left over); those of tasks stopped halfway stay, and the report says where they are.
3. Report in a few lines: per task, the pull request and its state, what was verified and what was not; the CI runs spent against the pull requests opened, with the reason for each extra one; what waits for the next round.
