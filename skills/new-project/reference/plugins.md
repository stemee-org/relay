# Stack plugins

`mattpocock-skills` and `ponytail` are installed in every project. The plugins below are proposed only when the stack calls for them: a plugin that is on costs context in every session, and two that cover the same ground contradict each other.

## Which to propose
Propose a row only when its condition is true of the stack as decided (the ADRs, not a guess). All three come from `claude-plugins-official`, which needs no marketplace line.

| When the project has | Plugin | What it brings | What the user must know before saying yes |
|---|---|---|---|
| Code that runs in a browser (HTML, CSS, client-side JavaScript) | `modern-web-guidance@claude-plugins-official` | Guides on current web platform practice, read before writing that code | Skills only; nothing runs and nothing is sent |
| Pages worth checking in a real browser, or end-to-end tests | `playwright@claude-plugins-official` | Tools to open a page, click, fill forms and take screenshots | Starts a local server with `npx @playwright/mcp@latest`: needs Node, and downloads the package on first use |
| Libraries or frameworks that change faster than a model's memory | `context7@claude-plugins-official` | Documentation and examples for the version in use | The library names and questions asked go to a hosted service (`mcp.context7.com`). Anonymous by default. Not for a project whose dependencies are confidential |

## How
1. Ask once, in one question that lists the matching rows with the last column, after the stack is decided. No matching row, no question. A stack still open: the task that decides it has «the stack plugins are chosen (this file)» among its `Done when`.
2. For each one accepted: `claude plugin install <plugin> --scope project`, add it to `enabledPlugins` in `.claude/settings.json`, and write its bullet in `CONTRIBUTING.md`, «Plugins», from `claude plugin details <plugin>`: when it is used, what it needs, the line to install it by hand. A failed install is handled as in step 2 of the skill: leave the line to type, note it in the handover, go on.
3. Record what was declined and why in the same section, in one line, so that the next session does not ask again.

## Another plugin
The user may name one that is not in the table. Before installing it:
- Find it in a marketplace and read `claude plugin details`: what it adds (skills, hooks, MCP servers), what it runs and what it sends out. Tell the user; never describe it from memory.
- Check it against what is already here. A plugin that brings its own planning, task tracking, test-first loop or code review overlaps `relay`, `mattpocock-skills` or the review agents: two sources for one practice means sessions that follow different rules. Say so and recommend against it; the user decides.
- A plugin with hooks is on in every session of the repo, for everyone who opens it: that is a team decision, written in `CONTRIBUTING.md`.

Not proposed, for that reason: `superpowers` (brainstorming, test-first, debugging and plans of its own), `feature-dev`, `code-review`, `pr-review-toolkit`, `security-guidance` (the last wave already has `code-reviewer`, `security-auditor` and the two plugins' reviews).
