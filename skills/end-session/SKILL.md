---
name: end-session
description: Close a work session - verify the task, write the handover, update status and plan, commit, and open the pull request. Use when the user says they are done, wrapping up or stopping for now, asks for a handover, or asks to ship the task.
---
The session ends with everything in the commits: the next session is a stranger and reads only the repo. Two cases, same skill:

- **The task is finished**: all the steps below.
- **Stopping halfway**: steps 1, 4 and 5, and the push of the branch if the user wants it. No pull request. The handover's «State right now» says exactly what is half-done and what the next move is.

It works on a repo set up with the documentation-first method (`/new-project`). If `docs/STATUS.md`, `docs/PLAN.md` and `docs/handover/` are not there, say so and stop.

## 1. Where we are
- The branch: work is on `<name>/<task-id>-<short-desc>`, never on `main`. If changes sit on `main`, move them to a branch first (`git switch -c …`); never push `main`.
- `git status` and `git log --oneline origin/main..HEAD`: what was done this session, what is uncommitted.
- What was verified and what was not. Say it as it is: it goes in the handover and in the pull request.

## 2. Verify
Run the Test, Lint and Type-check commands from `CLAUDE.md`. If one fails, fix it and run it again; do not go on with a failure, and do not skip one because the change «is only documents».

## 3. Review
Skip this step when the diff holds no code.
- The `code-reviewer` agent on the task's diff (`git diff origin/main...HEAD`); `security-auditor` too if the task touches input, access or payments.
- If the plugins are installed (`CONTRIBUTING.md`, «Plugins»): `ponytail:ponytail-review` and `mattpocock-skills:code-review` on the same diff. A missing plugin is said, not imitated.
- Fix the real problems; tell the user about the rest.

## 4. Documents
1. A new file `docs/handover/<YYYY-MM-DD>-<author>-<topic>.md` from the template in `docs/handover/README.md`. Never edit someone else's handover.
2. `docs/STATUS.md`, overwritten with the state as it is now (one screen), linking the new handover.
3. The task's row in `docs/PLAN.md`: status, branch. If the work taught something about the task that the next reader needs, one dated line under `Notes` of its card in `docs/tasks/`.
4. If the session found work that is not on the board, or the scope of a task changed: `/replan`, not a hand edit of the board.
5. If a decision was made: `/adr`. If a non-obvious pitfall came up: one line in `Gotchas` of the `CLAUDE.md` of the folder it concerns (the root one if it concerns the whole repo).

## 5. Commit
- Show `git status` and a summary of the diff. No `.env`, secret or debug leftover is staged; the handover, `docs/STATUS.md` and the task's row are in the commits. A task is not closed while its documents are outside them.
- Subjects in the form `<type>: <what>` (small logical commits if the change has distinct parts). The body says why, what was chosen and what was discarded, how it was verified and what is still unverified.

## 6. Pull request
Pushing and opening a pull request are outward-facing: ask first, unless the user already said to.
- Push the branch and open the pull request from `.github/pull_request_template.md`. Title in the form of commits with the task at the end (`feat: … (T18)`); description written for a reader who was not in the session.
- Check the CI on the pull request.
- Set the task's row in `docs/PLAN.md` to `in review` with the link, commit and push that too.
- Never merge: merging is a separate decision, to be asked. The row becomes `done` when the pull request is merged. When the user does ask for the merge, the branch goes with it: `gh pr merge <n> --merge --delete-branch`, then `git switch main && git pull --ff-only`.

## 7. Report
In a few lines: what is in the pull request, what was verified and what was not, what the next session should take.
