# Pi Harness Integration

**Date:** 2026-06-02
**Status:** Draft

## Problem

Superpowers was designed for Claude Code and has grown adapters for Codex, Cursor, Gemini CLI, OpenCode, and Copilot CLI. Pi is not supported. While Pi implements the Agent Skills standard and can discover Superpowers skill files, several critical gaps prevent Superpowers from working correctly on Pi:

1. **No bootstrap mechanism** — Pi doesn't support Claude Code's session-start hooks, so the `using-superpowers` content never reaches the agent at session start.
2. **Missing tools** — Superpowers skills reference `Skill` (dedicated skill loader), `TodoWrite` (task tracking), and `Task` (subagent dispatch with status tracking). Pi has no equivalents for the first two, and its `subagent` tool differs from Claude Code's `Task`.
3. **Tool name mismatches** — Skills use Claude Code tool names like `Read`, `Edit`, `Write`, `Grep`, `Glob`. Pi uses different names (`read`, `edit`, `write`, `bash` with rg/grep, `bash` with find/glob). Existing platform adapters map these via reference docs but Pi has none.
4. **Missing reference docs** — Every other platform has a `references/<platform>-tools.md` mapping file. Pi does not.

## Goals

1. Full feature parity: every Superpowers workflow works on Pi as it does on Claude Code
2. Zero-config installation via `pi install git:github.com/falaqin/superpowers-pi`
3. Extensions auto-installed and auto-loaded; skills auto-discovered
4. Acceptance test: "Let's make a react todo list" must auto-trigger `brainstorming`
5. Testing infrastructure equivalent to `tests/claude-code/` but for Pi's `--print` mode

## Non-Goals

- Adapting Superpowers for Pi extensions/SDK (this is about Pi as a consumer of Superpowers, not about building Pi with Superpowers)
- Changes to skill content that don't relate to Pi compatibility
- Pi-specific skill content beyond tool name mappings and reference docs
- Claude Code, Codex, or other harness compatibility regression (they continue to work)

## Architecture Overview

The integration has four layers:

| Layer | What it does | Where it lives |
|-------|-------------|----------------|
| **Bootstrap** | `CLAUDE.md` / `AGENTS.md` that Pi loads as project context at session start. Tells the agent about Superpowers, references the extension and skills. | Repo root |
| **Extension** | A TypeScript extension (`superpowers-bootstrap.ts`) that registers missing tools, injects bootstrap content on `before_agent_start`, and provides tool name mappings. | `.pi/extensions/` |
| **Skills** | Existing Superpowers skills with Pi-specific `<pi-note>` blocks and a new Pi tool mapping reference doc. | `skills/` |
| **Testing** | Pi-specific test suite that runs Pi in `--print` mode and verifies skill behavior. | `tests/pi/` |

## Design

### 1. Package Structure

The repo becomes a Pi-installable package through conventional directory layout:

```
superpowers-pi/
├── .pi/
│   └── extensions/
│       └── superpowers-bootstrap.ts    # Extension: tools + bootstrap injection
├── skills/                             # Existing Superpowers skills
│   ├── using-superpowers/
│   ├── brainstorming/
│   ├── ...
│   └── using-superpowers/
│       └── references/
│           └── pi-tools.md             # NEW: Pi tool mapping reference
├── hooks/                              # Retained for non-Pi harnesses
├── docs/
├── tests/
│   ├── claude-code/                    # Existing
│   └── pi/                             # NEW
│       ├── test-helpers.sh
│       ├── test-brainstorming.sh
│       ├── test-subagent-driven-dev.sh
│       └── test-tdd.sh
├── CLAUDE.md                           # Bootstrap (replaces current content)
├── AGENTS.md → CLAUDE.md               # Symlink
└── CONTRIBUTING.md                     # Current contributor guidelines moved here
```

Pi auto-discovers skills from `skills/` at the repo root and extensions from `.pi/extensions/`. No manifest or configuration file needed.

Installation:

```bash
pi install git:github.com/falaqin/superpowers-pi
```

### 2. Extension (`superpowers-bootstrap.ts`)

The extension uses Pi's extension API to fill the gaps. It does four things:

#### 2a. Registers `superpowers_skill` tool

Wraps Pi's `read` with Superpowers semantics. When a skill says "invoke the Skill tool," the agent has this tool available.

```typescript
pi.registerTool({
  name: "superpowers_skill",
  description: "Invoke a Superpowers skill by name. Loads the full skill content and presents it for the agent to follow.",
  parameters: {
    type: "object",
    required: ["skill"],
    properties: {
      skill: {
        type: "string",
        description: "Name of the skill to invoke (e.g., 'brainstorming', 'test-driven-development')"
      }
    }
  },
  handler: async ({ skill }) => {
    // Read SKILL.md from the skills directory and return its content
    // Announce which skill is being used
    // Handle skill-specific conventions (e.g., brainstorming checklist)
  }
});
```

#### 2b. Registers `todowrite` tool

Provides task tracking that Superpowers skills expect. Writes todos to a markdown file in the session directory.

```typescript
pi.registerTool({
  name: "todowrite",
  description: "Track and update task progress. Use this to create and manage a checklist of tasks during complex workflows.",
  parameters: {
    type: "object",
    required: ["todos"],
    properties: {
      todos: {
        type: "array",
        items: {
          type: "object",
          properties: {
            content: { type: "string" },
            status: { type: "string", enum: ["pending", "in_progress", "completed", "cancelled"] },
            priority: { type: "string", enum: ["high", "medium", "low"] }
          }
        }
      }
    }
  },
  handler: async ({ todos }) => {
    // Write todos to ~/.pi/agent/sessions/<session>/todos.md
    // Return the formatted todo list for the agent to display
  }
});
```

#### 2c. Injects `before_agent_start` bootstrap

On session start, injects the `using-superpowers` core content plus Pi-specific instructions:

```typescript
pi.on("before_agent_start", (context, systemPrompt) => {
  const bootstrap = `
## Superpowers Active

You have Superpowers installed. This means you have access to a comprehensive set of skills that guide your behavior. Before doing anything, check if a skill applies.

### Key tools available to you:
- \`superpowers_skill\` — invoke any Superpowers skill. ALWAYS use this for skills — never read skill files directly.
- \`todowrite\` — track tasks during complex workflows
- \`subagent\` — dispatch subagents for parallel work and code review

### If you think there is even a 1% chance a skill applies, invoke it.
  `;
  // Pi's before_agent_start callback signature should be confirmed against pi SDK docs
  return bootstrap;
});
```

#### 2d. Injects subagent reference docs on subagent creation

When a skill (like `subagent-driven-development`) dispatches subagents, it includes a reference to Superpowers skill docs so subagents follow the same conventions:

```typescript
// Hook into subagent creation to inject Superpowers context
// This ensures subagents dispatched by subagent-driven-development
// also follow skill conventions
```

### 3. Bootstrap File (CLAUDE.md / AGENTS.md)

The current `CLAUDE.md` contains contributor guidelines with a "94% PR rejection rate" warning. This is useful for contributors to the Superpowers repo but not what a Pi user needs injected into every session.

**What changes:**
- `CLAUDE.md` becomes the Superpowers bootstrap for Pi
- Contributor guidelines move to `CONTRIBUTING.md`
- `AGENTS.md` remains a symlink to `CLAUDE.md`

The new bootstrap content:

1. Identifies itself as the Superpowers bootstrap for Pi
2. Tells the agent about `superpowers_skill` and `todowrite` tools
3. Includes essential behavioral instructions from `using-superpowers` (check skills before responding, red flags table, skill invocation rules)
4. References the full skills directory for detailed workflows

**Caveat:** Pi's `AGENTS.md` / `CLAUDE.md` loading is not as reliable as session-start hooks. Some sessions may not pick it up. The extension's `before_agent_start` injection is the primary mechanism; the file acts as a fallback and a visible reference.

### 4. Skill Adaptations

Superpowers skills need minimal changes. The approach is additive — add Pi-specific annotations without changing existing content:

#### 4a. Tool Name Mapping (pi-tools.md)

New reference doc at `skills/using-superpowers/references/pi-tools.md`:

| Skill references | Pi equivalent |
|-----------------|---------------|
| `Read` (file reading) | `read` |
| `Write` (file creation) | `write` |
| `Edit` (file editing) | `edit` |
| `Bash` (run commands) | `bash` |
| `Grep` (search file content) | `bash` with `grep -r` or `rg` |
| `Glob` (search files by name) | `bash` with `find` or `ls` |
| `Skill` tool (invoke a skill) | `superpowers_skill` |
| `TodoWrite` (task tracking) | `todowrite` |
| `Task` tool (dispatch subagent) | `subagent` (see below) |
| `Task` with status tracking | `subagent` with `action: "status"` |
| Multiple `Task` calls (parallel) | `subagent` with `tasks: [...]` |

#### 4b. Subagent Dispatch Mapping

Superpowers skills use Claude Code's `Task` tool with these patterns:

| Claude Code `Task` | Pi `subagent` equivalent |
|-------------------|--------------------------|
| `Task(subagent_type="reviewer", ...)` | `subagent({ agent: "reviewer", task: "..." })` |
| `Task(subagent_type="implementer", ...)` | `subagent({ agent: "implementer", task: "..." })` |
| Parallel `Task` calls | `subagent({ tasks: [{agent, task}, ...] })` |
| Check task status | `subagent({ action: "status", id: "..." })` |

#### 4c. `<pi-note>` blocks in skill files

Where a skill references a Claude Code-specific concept that has no Pi equivalent, add a `<pi-note>` block:

```markdown
<pi-note>
Pi does not have a native `Task` tool. Use the `subagent` tool instead.
See `references/pi-tools.md` for the full mapping.
</pi-note>
```

Skills that need Pi notes:
- `subagent-driven-development` — Task dispatch and status tracking
- `dispatching-parallel-agents` — Parallel Task calls
- `requesting-code-review` — Reviewer subagent dispatch
- `executing-plans` — References to Task tool and TodoWrite
- `using-git-worktrees` — References to native worktree tools (Claude Code: `EnterWorktree`, Pi: none)

### 5. Bootstrap Mechanism Details

The `using-superpowers` skill currently uses a `<SUBAGENT-STOP>` block to prevent subagents from re-triggering skills. Pi needs the same guard. The extension should:

1. On `before_agent_start`, inject the bootstrap content
2. When a subagent is dispatched, either skip bootstrap injection (if subagent is for code review) or include it (if subagent is doing independent implementation)
3. Respect `<SUBAGENT-STOP>` semantics from the skill files

### 6. Testing

The existing test suite in `tests/claude-code/` verifies skills by running Claude Code in headless mode and parsing session transcripts. The Pi test suite does the same with Pi's `--print` mode.

**New test directory:**

```
tests/pi/
├── test-helpers.sh              # Pi-specific test utilities
│   # - Starts Pi in --print mode with controlled input
│   # - Parses Pi session transcript format
│   # - Asserts skill invocations, tool calls, output patterns
├── test-brainstorming.sh        # Acceptance test: "Let's make a react todo list"
│   # - Verifies brainstorming auto-triggers before any code is written
│   # - This is the key acceptance test per PR template requirements
├── test-subagent-driven-dev.sh  # Multi-step workflow: plan → implement → review → finish
├── test-tdd.sh                  # Red-green-refactor loop on Pi
├── test-systematic-debugging.sh # Bug diagnosis and fix workflow
└── test-bootstrap.sh            # Verifies CLAUDE.md and extension injection
```

#### Test Helper Design

```bash
# test-helpers.sh

# Run Pi in print mode with stdin input
run_pi_session() {
  local prompt="$1"
  local workdir="${2:-$(mktemp -d)}"
  # pi --print --model <model> --cwd "$workdir" "$prompt"
  # Capture and parse transcript
}

# Assert a skill was invoked in the session transcript
assert_skill_invoked() {
  local transcript="$1"
  local skill_name="$2"
  # grep for "invoking brainstorming" or equivalent
}

# Assert a tool was called
assert_tool_called() {
  local transcript="$1"
  local tool_name="$2"
}
```

#### Acceptance Test (test-brainstorming.sh)

The critical test from the PR template:

> Open a clean session and send exactly: "Let's make a react todo list"
> A working integration auto-triggers the `brainstorming` skill before any code is written.

```bash
#!/usr/bin/env bash
# Acceptance test: brainstorming must auto-trigger on "Let's make a react todo list"

source "$(dirname "$0")/test-helpers.sh"

transcript=$(run_pi_session "Let's make a react todo list")

# Assert brainstorming was invoked before any code was written
assert_skill_invoked "$transcript" "brainstorming"

# Assert no code was written before brainstorming
# (check transcript for edit/write calls before skill invocation)
assert_no_code_before_skill "$transcript"

echo "✅ PASS: brainstorming auto-triggers on Pi"
```

#### Files from docs/testing.md

The existing `docs/testing.md` describes Claude Code tests. The Pi test suite follows the same structure:

- `test-helpers.sh` — shared utilities
- Individual test scripts per skill
- Session transcript parsing for assertions
- CI-compatible exit codes (0 = pass, non-zero = fail)

### 7. Installation & Distribution

Users install with one command:

```bash
pi install git:github.com/falaqin/superpowers-pi
```

This works because Pi auto-discovers:
- **Skills:** from `skills/` at repo root
- **Extensions:** from `.pi/extensions/` directory
- **No manifest required** — Pi uses conventional directory layout

The extension auto-loads on next session start. No manual configuration needed.

For users who want to customize (e.g., different model, disable certain skills), they can edit their `.pi/config.json` after installation.

## Open Questions

1. **Pi extension `before_agent_start` API signature** — Need to confirm exact callback signature from Pi SDK docs before implementing the extension. The current design assumes `(context, systemPrompt) => string` but this needs verification.

2. **Subagent context injection** — Need to confirm Pi's subagent system allows injecting additional context per dispatch. If not, the reference docs may need to be loaded via `reads` parameter instead.

3. **`--print` mode for testing** — Need to confirm Pi's `--print` mode supports stdin input and outputs a parseable transcript. The test design depends on this.

4. **Skill auto-discovery from git repos** — Need to confirm Pi's `install git:` command discovers skills from a `skills/` directory at repo root. This is the conventional layout but needs verification.

5. **Extension hot-reload** — If the extension needs updates after initial install, need to confirm `pi update` or `pi install --force` can re-install the extension.

## Risks

| Risk | Mitigation |
|------|-----------|
| Pi's `AGENTS.md` loading is unreliable | Extension `before_agent_start` injection is the primary mechanism |
| Subagent API differences require skill content changes | `<pi-note>` blocks keep Pi-specific guidance separate from core content |
| Tests may be flaky due to model non-determinism | Use pattern matching on transcripts, not exact string comparison |
| Extension API may change between Pi versions | Pin Pi version compatibility in docs; test on latest stable |
