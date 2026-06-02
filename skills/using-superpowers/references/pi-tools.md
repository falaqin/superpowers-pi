# Pi Tool Mapping

Skills use Claude Code tool names. When you encounter these in a skill, use your platform equivalent:

| Skill references | Pi equivalent |
|-----------------|---------------|
| `Read` (file reading) | `read` |
| `Write` (file creation) | `write` |
| `Edit` (file editing) | `edit` |
| `Bash` (run commands) | `bash` |
| `Grep` (search file content) | `grep` |
| `Glob` (search files by name) | Use `bash` with `find` (no dedicated Glob tool in Pi) |
| `Skill` tool (invoke a skill) | `superpowers_skill` (registered by superpowers-bootstrap extension) |
| `TodoWrite` (task tracking) | `todowrite` (registered by superpowers-bootstrap extension) |
| `WebSearch` | `web_search` |
| `WebFetch` | `webfetch` / `fetch_content` |
| `Task` tool (dispatch subagent) | `subagent` (see [Subagent support](#subagent-support)) |
| Multiple `Task` calls (parallel) | `subagent` with PARALLEL mode |
| `EnterPlanMode` / `ExitPlanMode` | Not available in Pi; work directly in session |
| `AskUserQuestion` | `ask_user_question` |
| Code search / docs | `code_search`, `context7_query-docs` |

## Subagent support

Pi supports subagents via the `subagent` tool. Use single-agent mode for individual tasks, PARALLEL mode for concurrent dispatch, and CHAIN mode for sequential pipelines.

When a skill says to dispatch a named agent type, use `subagent` with the full prompt from the skill's prompt template:

| Skill instruction | Pi equivalent |
|-------------------|---------------|
| `Task` tool (superpowers:implementer) | `subagent` with the filled `implementer-prompt.md` template |
| `Task` tool (superpowers:spec-reviewer) | `subagent` with the filled `spec-reviewer-prompt.md` template |
| `Task` tool (superpowers:code-reviewer) | `subagent` with the filled `code-reviewer.md` template |
| `Task` tool (superpowers:code-quality-reviewer) | `subagent` with the filled `code-quality-reviewer-prompt.md` template |
| `Task` tool (general-purpose) with inline prompt | `subagent` with your inline prompt |

### Prompt filling

Skills provide prompt templates with placeholders like `{WHAT_WAS_IMPLEMENTED}` or `[FULL TEXT of task]`. Fill all placeholders and pass the complete prompt as the task to the subagent.

### Parallel dispatch

Pi supports parallel subagent dispatch. When a skill asks you to dispatch multiple independent subagent tasks in parallel, use the `subagent` tool with PARALLEL mode. Keep dependent tasks sequential, but do not serialize independent subagent tasks just to preserve a simpler history.

## Additional Pi tools

These Pi-specific tools may be available depending on installed extensions:

| Tool | Purpose |
|------|---------|
| `lsp_diagnostics` | Language server diagnostics (proactive error checking) |
| `lsp_navigation` | Code navigation (definitions, references, hover) |
| `ast_grep_search` / `ast_grep_replace` | AST-aware code search and replacement |
| `memory` / `memory_search` | Persistent memory across sessions |
| `session_search` | Search past conversation context |
| `skill` (Pi built-in) | List, view, create, update skills (meta-operations) |
| `context7_resolve-library-id` / `context7_query-docs` | Documentation lookup for libraries |
| `list_currencies` / `convert_currency` | Currency utilities |
