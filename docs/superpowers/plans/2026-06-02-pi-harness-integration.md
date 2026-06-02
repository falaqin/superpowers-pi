# Pi Harness Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add full Pi harness support to Superpowers so all workflows (brainstorming → plans → subagent-driven-dev → finishing) work reliably on the Pi coding agent.

**Architecture:** A TypeScript extension registers missing tools (`superpowers_skill`, `todowrite`) and injects the `using-superpowers` bootstrap at session start via Pi's `before_agent_start` event. The existing `CLAUDE.md` contributor guidelines move to `CONTRIBUTING.md` and `CLAUDE.md` becomes the Superpowers bootstrap for Pi. A new `pi-tools.md` reference file documents tool name mappings. Minor updates to `using-superpowers/SKILL.md` and `README.md` complete the integration.

**Tech Stack:** TypeScript (via jiti), Pi Extension API, TypeBox schemas, bash (setup/test scripts), Python (session analyzer)

---

### Task 1: Move Contributor Guidelines to CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`
- Modify: `CLAUDE.md`

- [ ] **Step 1: Copy CLAUDE.md content to CONTRIBUTING.md**

The current `CLAUDE.md` contains contributor guidelines. The entire content moves to the new file. Read the current CLAUDE.md:

```bash
cat CLAUDE.md
```

- [ ] **Step 2: Create CONTRIBUTING.md with the full content**

```bash
cp CLAUDE.md CONTRIBUTING.md
```

Verify:

```bash
wc -l CONTRIBUTING.md
```

Expected: same line count as CLAUDE.md

- [ ] **Step 3: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: move contributor guidelines to CONTRIBUTING.md"
```

---

### Task 2: Write Bootstrap CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`
- (AGENTS.md is already a symlink to CLAUDE.md, which auto-updates)

- [ ] **Step 1: Write the new bootstrap CLAUDE.md**

Write the file with this content:

```markdown
# Superpowers for Pi

You have Superpowers — a complete software development methodology that transforms
how you work. Superpowers skills auto-trigger at the right moments so you don't
need to do anything special. You just work better.

## Tools Provided by Superpowers

This Pi session has the Superpowers extension loaded. It provides two additional tools:

- **`superpowers_skill`** — Invoke a Superpowers skill by name. Use this instead of `read` to load
  skill content. When a skill applies to your task, invoke it. The tool loads the full SKILL.md
  content for you to follow.
- **`todowrite`** — Track tasks through multi-step workflows. Superpowers skills use checklists;
  use this tool to create and update them.

## The Rule

**Invoke relevant skills BEFORE any response or action.** Even a 1% chance a skill might apply
means you should invoke `superpowers_skill` to check. If the skill turns out to be wrong for the
situation, you don't need to use it.

## Skill Priority

When multiple skills could apply:
1. **Process skills first** — brainstorming, systematic-debugging. These determine HOW to approach.
2. **Implementation skills second** — test-driven-development, subagent-driven-development. These guide execution.

"Let's build X" → `superpowers_skill("brainstorming")` first, then implementation skills.
"Fix this bug" → `superpowers_skill("systematic-debugging")` first, then domain skills.

## Available Skills

Your session has these Superpowers skills available:

- **brainstorming** — Use before any creative work: creating features, building components, adding functionality, or modifying behavior
- **writing-plans** — Create detailed implementation plans from approved specs
- **subagent-driven-development** — Execute plans by dispatching subagents with two-stage review
- **executing-plans** — Execute plans in batches with human checkpoints
- **test-driven-development** — RED-GREEN-REFACTOR: write failing test first, then minimal code
- **systematic-debugging** — 4-phase root cause debugging process
- **verification-before-completion** — Verify work before claiming it's done
- **dispatching-parallel-agents** — Run independent subagent tasks concurrently
- **requesting-code-review** — Pre-review checklist and reviewer dispatch
- **receiving-code-review** — How to respond to code review feedback
- **using-git-worktrees** — Isolated workspaces for feature development
- **finishing-a-development-branch** — Structured merge/PR/cleanup workflow
- **writing-skills** — Create and test new Superpowers skills
- **using-superpowers** — How to find and use skills (loaded automatically at session start)

## Red Flags

These thoughts mean STOP — you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Load current version. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
```

- [ ] **Step 2: Verify AGENTS.md symlink still works**

```bash
cat AGENTS.md | head -1
```
Expected: first line of the new bootstrap

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: replace CLAUDE.md with Superpowers bootstrap for Pi"
```

---

### Task 3: Write pi-tools.md Tool Mapping Reference

**Files:**
- Create: `skills/using-superpowers/references/pi-tools.md`

- [ ] **Step 1: Create the reference file**

Write the file with this content:

````markdown
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
````

- [ ] **Step 2: Commit**

```bash
git add skills/using-superpowers/references/pi-tools.md
git commit -m "feat: add Pi tool mapping reference"
```

---

### Task 4: Write superpowers-bootstrap.ts Extension

**Files:**
- Create: `.pi/extensions/superpowers-bootstrap.ts`
- Ensure: `.pi/extensions/` directory exists

- [ ] **Step 1: Create .pi/extensions/ directory**

```bash
mkdir -p .pi/extensions
```

- [ ] **Step 2: Write the extension file**

Write `.pi/extensions/superpowers-bootstrap.ts` with this content:

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

// ── Skill path resolution ──────────────────────────────────────────────

/**
 * Find the plugin root directory (where skills/ lives).
 * Walks up from the extension file to find the directory containing skills/.
 */
function findPluginRoot(extensionDir: string): string {
  // The extension lives at <plugin_root>/.pi/extensions/superpowers-bootstrap.ts
  // Plugin root is two levels up
  const candidate = path.resolve(extensionDir, "..", "..");

  // Verify skills/ exists
  const skillsDir = path.join(candidate, "skills");
  if (fs.existsSync(skillsDir) && fs.statSync(skillsDir).isDirectory()) {
    return candidate;
  }

  // Fallback: if run from Pi's symlinked extensions dir, walk from cwd
  // Pi might have installed the package elsewhere
  throw new Error(
    "Could not find Superpowers skills directory. " +
    "Ensure the superpowers-pi package is installed correctly."
  );
}

/**
 * Find a skill's SKILL.md by searching Pi's skill discovery directories.
 */
function resolveSkillPath(skillName: string): string | null {
  const searchDirs: string[] = [];

  // Global Pi skill directories
  searchDirs.push(path.join(os.homedir(), ".pi", "agent", "skills"));
  searchDirs.push(path.join(os.homedir(), ".agents", "skills"));

  // Walk up from cwd for project-local .pi/skills and .agents/skills
  let dir = process.cwd();
  while (true) {
    searchDirs.push(path.join(dir, ".pi", "skills"));
    searchDirs.push(path.join(dir, ".agents", "skills"));
    const parent = path.dirname(dir);
    if (parent === dir) break;
    dir = parent;
  }

  for (const skillsDir of searchDirs) {
    if (!fs.existsSync(skillsDir)) continue;

    // Check direct subdirectory: skills/<name>/SKILL.md
    const directPath = path.join(skillsDir, skillName, "SKILL.md");
    if (fs.existsSync(directPath)) return directPath;

    // Recurse into category subdirectories: skills/<category>/<name>/SKILL.md
    try {
      const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        const nestedPath = path.join(skillsDir, entry.name, skillName, "SKILL.md");
        if (fs.existsSync(nestedPath)) return nestedPath;
      }
    } catch {
      // Directory not readable, skip
    }
  }

  return null;
}

/**
 * Build a human-readable list of available Superpowers skills for the bootstrap.
 */
function buildSkillList(skillsDir: string): string {
  if (!fs.existsSync(skillsDir)) return "";

  const lines: string[] = [];
  try {
    const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillMd = path.join(skillsDir, entry.name, "SKILL.md");
      if (!fs.existsSync(skillMd)) continue;

      // Read the frontmatter to extract name and description
      const content = fs.readFileSync(skillMd, "utf-8");
      const match = content.match(/^---\n([\s\S]*?)\n---/);
      if (match) {
        const frontmatter = match[1];
        const nameMatch = frontmatter.match(/^name:\s*(.+)$/m);
        const descMatch = frontmatter.match(/^description:\s*(.+)$/m);
        const name = nameMatch ? nameMatch[1].trim() : entry.name;
        const desc = descMatch ? descMatch[1].trim() : "";
        lines.push(`- **${name}** — ${desc}`);
      } else {
        lines.push(`- **${entry.name}**`);
      }
    }
  } catch {
    // Skills dir not readable
  }

  return lines.join("\n");
}

// ── Extension ───────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // One-time initialization: resolve plugin root and cache bootstrap content
  const extensionDir = __dirname || path.dirname(new URL(import.meta.url).pathname);
  let pluginRoot: string;
  let usingSuperpowersContent: string;
  let skillList: string;

  try {
    pluginRoot = findPluginRoot(extensionDir);
    const skillsDir = path.join(pluginRoot, "skills");
    const usingSuperpowersPath = path.join(skillsDir, "using-superpowers", "SKILL.md");

    if (fs.existsSync(usingSuperpowersPath)) {
      usingSuperpowersContent = fs.readFileSync(usingSuperpowersPath, "utf-8");
    } else {
      usingSuperpowersContent = "";
    }

    skillList = buildSkillList(skillsDir);
  } catch (err) {
    // Extension loads in a context where skills aren't co-located.
    // The bootstrap injection will still work with CLI-managed skills.
    pluginRoot = process.cwd();
    usingSuperpowersContent = "";
    skillList = "";
  }

  // ── Tool: superpowers_skill ──────────────────────────────────────

  pi.registerTool({
    name: "superpowers_skill",
    label: "Superpowers Skill",
    description:
      "Invoke a Superpowers skill by name. Loads the full SKILL.md content " +
      "for the agent to follow. Use whenever there is even a 1% chance a " +
      "skill might apply to the current task. Skills include: brainstorming, " +
      "test-driven-development, systematic-debugging, subagent-driven-development, " +
      "writing-plans, executing-plans, requesting-code-review, receiving-code-review, " +
      "using-git-worktrees, finishing-a-development-branch, " +
      "dispatching-parallel-agents, verification-before-completion, writing-skills.",
    parameters: Type.Object({
      name: Type.String({
        description:
          "Skill name, e.g. 'brainstorming', 'test-driven-development', " +
          "'subagent-driven-development'",
      }),
    }),
    async execute(_toolCallId, params) {
      const skillName = params.name;
      const skillPath = resolveSkillPath(skillName);

      if (!skillPath) {
        return {
          content: [
            {
              type: "text",
              text:
                `Skill "${skillName}" not found. Available skills are discovered ` +
                `from ~/.pi/agent/skills/, ~/.agents/skills/, and project .pi/skills/ ` +
                `or .agents/skills/ directories. Check that the skill is installed.`,
            },
          ],
          details: { skillName, found: false },
        };
      }

      const content = fs.readFileSync(skillPath, "utf-8");

      return {
        content: [
          {
            type: "text",
            text:
              `## Using Superpowers Skill: ${skillName}\n\n` +
              `**Skill loaded from:** ${skillPath}\n\n` +
              content,
          },
        ],
        details: { skillName, path: skillPath, found: true },
      };
    },
  });

  // ── Tool: todowrite ──────────────────────────────────────────────

  pi.registerTool({
    name: "todowrite",
    label: "Todo Write",
    description:
      "Create and update a structured task list for tracking progress through " +
      "multi-step workflows. Each task has a unique id, a status " +
      "(pending, in_progress, or completed), and content describing the task. " +
      "Use this whenever a Superpowers skill has a checklist — create one todo " +
      "per checklist item.",
    parameters: Type.Object({
      todos: Type.Array(
        Type.Object({
          id: Type.String({ description: "Unique task identifier" }),
          status: Type.String({
            description: "One of: pending, in_progress, completed",
          }),
          content: Type.String({ description: "Task description" }),
        })
      ),
    }),
    async execute(_toolCallId, params) {
      const todosDir = path.join(process.cwd(), ".pi");
      const todosPath = path.join(todosDir, "todos.json");

      // Ensure .pi/ directory exists
      if (!fs.existsSync(todosDir)) {
        fs.mkdirSync(todosDir, { recursive: true });
      }

      // Read existing todos if any, merge with new ones
      let existing: Record<string, unknown> = {};
      if (fs.existsSync(todosPath)) {
        try {
          existing = JSON.parse(fs.readFileSync(todosPath, "utf-8"));
        } catch {
          // Corrupted file, start fresh
        }
      }

      // Write the new todo list
      const todosData = {
        updated: new Date().toISOString(),
        todos: params.todos,
      };
      fs.writeFileSync(todosPath, JSON.stringify(todosData, null, 2), "utf-8");

      // Return formatted current state
      const statusEmoji: Record<string, string> = {
        pending: "⬜",
        in_progress: "🔄",
        completed: "✅",
      };

      const lines = params.todos.map(
        (t: { id: string; status: string; content: string }) => {
          const emoji = statusEmoji[t.status] || "❓";
          return `${emoji} [${t.status}] ${t.content}`;
        }
      );

      return {
        content: [
          {
            type: "text",
            text:
              `## Tasks\n\n` +
              lines.join("\n") +
              `\n\nSaved to ${todosPath}`,
          },
        ],
        details: todosData,
      };
    },
  });

  // ── Bootstrap injection ──────────────────────────────────────────

  pi.on("before_agent_start", async (event, _ctx) => {
    // Build the bootstrap context based on what's available
    const parts: string[] = [];

    parts.push(
      "<EXTREMELY_IMPORTANT>",
      "You have superpowers.",
      "",
      "**Below is the full content of your 'superpowers:using-superpowers' " +
      "skill — your introduction to using skills. For all other skills, use " +
      "the 'superpowers_skill' tool:**",
      ""
    );

    if (usingSuperpowersContent) {
      parts.push(usingSuperpowersContent);
    } else {
      parts.push(
        "The using-superpowers skill content could not be loaded from disk. " +
        "Use the `superpowers_skill` tool to load individual skills by name. " +
        "Available skills are listed in your context."
      );
    }

    if (skillList) {
      parts.push("", "## Available Superpowers Skills", "", skillList);
    }

    parts.push("</EXTREMELY_IMPORTANT>");

    const bootstrapMessage = parts.join("\n");

    return {
      // Inject as a persistent message the model sees
      message: {
        customType: "superpowers-bootstrap",
        content: bootstrapMessage,
        display: true, // visible in session history
      },
    };
  });
}
```

- [ ] **Step 3: Commit**

```bash
git add .pi/extensions/superpowers-bootstrap.ts
git commit -m "feat: add superpowers-bootstrap Pi extension"
```

---

### Task 5: Update using-superpowers/SKILL.md

**Files:**
- Modify: `skills/using-superpowers/SKILL.md`

- [ ] **Step 1: Add Pi to "How to Access Skills" section**

The current section (around line 30) reads:

```markdown
**In Claude Code:** Use the `Skill` tool...
**In Copilot CLI:** Use the `skill` tool...
**In Gemini CLI:** Skills activate via the `activate_skill` tool...
**In other environments:** Check your platform's documentation for how skills are loaded.
```

Add a Pi entry after the Gemini CLI line:

```markdown
**In Gemini CLI:** Skills activate via the `activate_skill` tool. Gemini loads skill metadata at session start and activates the full content on demand.

**In Pi:** Use the `superpowers_skill` tool. Skills are auto-discovered from `~/.pi/agent/skills/`, `~/.agents/skills/`, and project `.pi/skills/` or `.agents/skills/` directories. The extension registers `superpowers_skill` and `todowrite` tools.

**In other environments:** Check your platform's documentation for how skills are loaded.
```

- [ ] **Step 2: Add Pi to "Platform Adaptation" section**

The current section (around line 36) reads:

```markdown
Non-CC platforms: see `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.
```

Update to:

```markdown
Non-CC platforms: see `references/copilot-tools.md` (Copilot CLI), `references/codex-tools.md` (Codex), or `references/pi-tools.md` (Pi) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.
```

- [ ] **Step 3: Verify no other changes were made**

```bash
git diff skills/using-superpowers/SKILL.md
```

Expected: only the two Pi-related additions

- [ ] **Step 4: Commit**

```bash
git add skills/using-superpowers/SKILL.md
git commit -m "feat: add Pi to using-superpowers skill docs"
```

---

### Task 6: Update README.md with Pi Installation Section

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add Pi installation section to README**

Add after the GitHub Copilot CLI section (before "The Basic Workflow"):

```markdown
### Pi

Install the package with a single command:

```bash
pi install git:github.com/falaqin/superpowers-pi
```

This installs all Superpowers skills and the `superpowers-bootstrap` extension that
registers missing tools and loads the Superpowers workflow at session start.

Or install manually by cloning and running the setup script:

```bash
git clone https://github.com/falaqin/superpowers-pi
cd superpowers-pi
./setup.sh
```

Restart Pi or run `/reload` after installation.
```

- [ ] **Step 2: Update the Quickstart section header**

The first line of the README quickstart says:

```markdown
Give your agent Superpowers: [Claude Code](#claude-code), [Codex CLI](#codex-cli)...
```

Add Pi to the list:

```markdown
Give your agent Superpowers: [Claude Code](#claude-code), [Codex CLI](#codex-cli), [Codex App](#codex-app), [Factory Droid](#factory-droid), [Gemini CLI](#gemini-cli), [OpenCode](#opencode), [Cursor](#cursor), [GitHub Copilot CLI](#github-copilot-cli), [Pi](#pi).
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add Pi installation section to README"
```

---

### Task 7: Update package.json with Pi Package Metadata

**Files:**
- Modify: `package.json`

- [ ] **Step 1: Add pi key and pi-package keyword**

The current `package.json`:

```json
{
  "name": "superpowers",
  "version": "5.1.0",
  "type": "module",
  "main": ".opencode/plugins/superpowers.js"
}
```

Update to:

```json
{
  "name": "superpowers-pi",
  "version": "5.1.0",
  "type": "module",
  "main": ".opencode/plugins/superpowers.js",
  "keywords": ["pi-package"],
  "pi": {
    "extensions": [".pi/extensions"],
    "skills": ["./skills"]
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
node -e "JSON.parse(require('fs').readFileSync('package.json','utf-8')); console.log('Valid JSON')"
```

Expected: Valid JSON

- [ ] **Step 3: Commit**

```bash
git add package.json
git commit -m "feat: add Pi package metadata to package.json"
```

---

### Task 8: Write setup.sh Manual Install Script

**Files:**
- Create: `setup.sh`
- Make executable

- [ ] **Step 1: Write the setup script**

Write `setup.sh` with this content:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_SKILLS="$HOME/.pi/agent/skills"
PI_EXTS="$HOME/.pi/agent/extensions"

echo "Installing Superpowers for Pi..."
echo ""

# Symlink skills
echo "Skills:"
mkdir -p "$PI_SKILLS"
for skill_dir in "$REPO_DIR/skills/"*; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$PI_SKILLS/$name"
  echo "  ✓ $name"
done

echo ""

# Symlink extension
echo "Extension:"
mkdir -p "$PI_EXTS"
ln -sfn "$REPO_DIR/.pi/extensions/superpowers-bootstrap.ts" \
  "$PI_EXTS/superpowers-bootstrap.ts"
echo "  ✓ superpowers-bootstrap"

echo ""
echo "Superpowers for Pi installed."
echo "Restart pi or run /reload to activate."
```

- [ ] **Step 2: Make executable**

```bash
chmod +x setup.sh
```

- [ ] **Step 3: Verify script is syntactically valid**

```bash
bash -n setup.sh
```

Expected: no output, exit code 0

- [ ] **Step 4: Commit**

```bash
git add setup.sh
git commit -m "feat: add Pi setup script for manual installation"
```

---

### Task 9: Write Test Helpers and Session Analyzer

**Files:**
- Create: `tests/pi/test-helpers.sh`
- Create: `tests/pi/analyze-session.py`

- [ ] **Step 1: Write test-helpers.sh**

Write `tests/pi/test-helpers.sh`:

```bash
#!/usr/bin/env bash
# Shared utilities for Pi Superpowers integration tests

set -euo pipefail

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}  [PASS]${NC} $1"
}

fail() {
    echo -e "${RED}  [FAIL]${NC} $1"
}

info() {
    echo -e "${YELLOW}  [INFO]${NC} $1"
}

# Create a temporary test project with a minimal Node.js setup
create_test_project() {
    local test_dir
    test_dir=$(mktemp -d /tmp/superpowers-pi-test.XXXXXX)
    cd "$test_dir"

    # Initialize git
    git init
    git config user.email "test@superpowers.test"
    git config user.name "Superpowers Test"

    # Create minimal package.json
    cat > package.json <<'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "test": "node --test"
  }
}
EOF

    # Initial commit
    git add package.json
    git commit -m "Initial commit"

    echo "$test_dir"
}

# Cleanup test project
cleanup_test_project() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

# Verify a Pi session transcript shows a specific tool was used
verify_tool_used() {
    local session_file="$1"
    local tool_name="$2"

    if [ ! -f "$session_file" ]; then
        fail "Session file not found: $session_file"
        return 1
    fi

    if grep -q "\"toolName\":\"$tool_name\"" "$session_file"; then
        pass "Tool '$tool_name' was invoked"
        return 0
    else
        fail "Tool '$tool_name' was NOT invoked"
        return 1
    fi
}

# Verify a file exists and contains expected content
verify_file_contains() {
    local file_path="$1"
    local expected="$2"

    if [ ! -f "$file_path" ]; then
        fail "File not found: $file_path"
        return 1
    fi

    if grep -q "$expected" "$file_path"; then
        pass "File $file_path contains '$expected'"
        return 0
    else
        fail "File $file_path does NOT contain '$expected'"
        return 1
    fi
}

# Find the most recent Pi session file
find_recent_pi_session() {
    local cwd="$1"
    local cwd_encoded
    cwd_encoded=$(echo "$cwd" | sed 's/\//-/g' | sed 's/^-//')
    # Pi stores sessions in project-memory dir
    local session_dir="$HOME/.pi/agent/projects-memory/$cwd_encoded"

    if [ ! -d "$session_dir" ]; then
        # Try alt location
        session_dir="$HOME/.pi/agent/sessions"
    fi

    find "$session_dir" -name "*.jsonl" -type f -mmin -60 2>/dev/null | sort -r | head -1
}
```

- [ ] **Step 2: Write analyze-session.py**

Write `tests/pi/analyze-session.py`:

```python
#!/usr/bin/env python3
"""
Analyze a Pi session transcript (JSONL) to show token usage,
cost, and subagent breakdown.

Usage:
    python3 tests/pi/analyze-session.py <session-file.jsonl>
"""

import json
import sys
from collections import defaultdict
from pathlib import Path


def analyze_session(session_file: str) -> None:
    if not Path(session_file).exists():
        print(f"Error: File not found: {session_file}")
        sys.exit(1)

    entries = []
    with open(session_file) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    entries.append(json.loads(line))
                except json.JSONDecodeError:
                    continue

    # Track usage
    total_input = 0
    total_output = 0
    total_cache_read = 0
    total_cache_write = 0
    message_count = 0
    tool_calls = defaultdict(int)
    subagent_usage: list[dict] = []

    for entry in entries:
        # Count messages
        if entry.get("role") in ("user", "assistant"):
            message_count += 1

        # Track tool calls
        tool_calls_data = entry.get("tool_calls") or []
        for tc in tool_calls_data:
            tool_name = tc.get("function", {}).get("name", "unknown")
            tool_calls[tool_name] += 1

        # Track usage from assistant messages
        usage = entry.get("usage")
        if usage:
            total_input += usage.get("input_tokens", 0)
            total_output += usage.get("output_tokens", 0)
            total_cache_read += usage.get("cache_read_input_tokens", 0)
            total_cache_write += usage.get("cache_creation_input_tokens", 0)

    # Print report
    print("=" * 60)
    print(" Pi Session Analysis")
    print("=" * 60)
    print(f"\n  Messages: {message_count}")
    print(f"  Tool calls: {sum(tool_calls.values())}")
    print()

    if tool_calls:
        print("  Tool Usage:")
        print("  " + "-" * 54)
        for name, count in sorted(tool_calls.items()):
            print(f"  {name:<30} {count:>4}")
        print()

    print("  Token Usage:")
    print("  " + "-" * 54)
    print(f"  {'Input tokens:':<30} {total_input:>10,}")
    print(f"  {'Output tokens:':<30} {total_output:>10,}")
    print(f"  {'Cache read tokens:':<30} {total_cache_read:>10,}")
    print(f"  {'Cache write tokens:':<30} {total_cache_write:>10,}")
    print(f"  {'Total tokens:':<30} {total_input + total_output:>10,}")

    # Cost estimate (Claude Sonnet pricing)
    cost_input = total_input * 3 / 1_000_000
    cost_output = total_output * 15 / 1_000_000
    cost_cache_read = total_cache_read * 0.30 / 1_000_000
    cost_cache_write = total_cache_write * 3.75 / 1_000_000
    total_cost = cost_input + cost_output + cost_cache_read + cost_cache_write

    print()
    print("  Cost Estimate (Claude Sonnet):")
    print("  " + "-" * 54)
    print(f"  {'Input:':<30} ${cost_input:>9.4f}")
    print(f"  {'Output:':<30} ${cost_output:>9.4f}")
    print(f"  {'Cache read:':<30} ${cost_cache_read:>9.4f}")
    print(f"  {'Cache write:':<30} ${cost_cache_write:>9.4f}")
    print(f"  {'Total:':<30} ${total_cost:>9.4f}")
    print()

    # Subagent breakdown
    if subagent_usage:
        print("  Subagent Breakdown:")
        print("  " + "-" * 54)
        for sa in subagent_usage:
            print(f"  {sa['agent_id']:<12} {sa['description'][:40]:<42}")
        print()

    print("=" * 60)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <session-file.jsonl>")
        sys.exit(1)
    analyze_session(sys.argv[1])
```

- [ ] **Step 3: Make scripts executable**

```bash
chmod +x tests/pi/test-helpers.sh
chmod +x tests/pi/analyze-session.py
```

- [ ] **Step 4: Commit**

```bash
git add tests/pi/test-helpers.sh tests/pi/analyze-session.py
git commit -m "test: add Pi test helpers and session analyzer"
```

---

### Task 10: Write Acceptance Test (Brainstorming Auto-Trigger)

**Files:**
- Create: `tests/pi/test-brainstorming.sh`

- [ ] **Step 1: Write the acceptance test**

Write `tests/pi/test-brainstorming.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=========================================="
echo " Acceptance Test: Brainstorming Auto-Trigger"
echo "=========================================="
echo ""

# Create test project
TEST_PROJECT=$(create_test_project)
trap "cleanup_test_project $TEST_PROJECT" EXIT
cd "$TEST_PROJECT"

echo "Test project: $TEST_PROJECT"
echo ""

# Run Pi with the acceptance prompt
echo "Running Pi with: 'Let'"'"'s make a react todo list'"'"'"
echo ""

pi --no-session \
  --print \
  --extension "$REPO_ROOT/.pi/extensions/superpowers-bootstrap.ts" \
  "Let's make a react todo list" \
  2>&1 | tee output.txt

echo ""
echo "=== Verification Tests ==="
echo ""

# Test 1: Brainstorming skill was invoked
if grep -qi "brainstorming" output.txt; then
    pass "Brainstorming skill was triggered"
else
    fail "Brainstorming skill was NOT triggered"
fi

# Test 2: No implementation code was written
if [ ! -f "src/App.jsx" ] && [ ! -f "src/App.tsx" ] && [ ! -f "index.html" ]; then
    pass "No premature implementation code written"
else
    fail "Premature implementation code found"
fi

# Test 3: The agent asked questions (brainstorming behavior)
if grep -qi "?" output.txt; then
    pass "Agent asked clarifying questions"
else
    fail "Agent did NOT ask clarifying questions"
fi

echo ""
echo "=== Test Summary ==="
echo ""
echo "See full output in: $TEST_PROJECT/output.txt"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x tests/pi/test-brainstorming.sh
```

- [ ] **Step 3: Commit**

```bash
git add tests/pi/test-brainstorming.sh
git commit -m "test: add Pi acceptance test for brainstorming auto-trigger"
```

---

### Task 11: Write Tool Registration Test

**Files:**
- Create: `tests/pi/test-tool-registration.sh`

- [ ] **Step 1: Write the tool registration test**

Write `tests/pi/test-tool-registration.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=========================================="
echo " Test: Tool Registration"
echo "=========================================="
echo ""

echo "Running Pi to list available tools..."
echo ""

pi --no-session \
  --print \
  --extension "$REPO_ROOT/.pi/extensions/superpowers-bootstrap.ts" \
  "List the names of all tools available to you" \
  2>&1 | tee output.txt

echo ""
echo "=== Verification Tests ==="
echo ""

# Test 1: superpowers_skill is available
if grep -qi "superpowers_skill" output.txt; then
    pass "superpowers_skill tool is available"
else
    fail "superpowers_skill tool is NOT available"
fi

# Test 2: todowrite is available
if grep -qi "todowrite" output.txt; then
    pass "todowrite tool is available"
else
    fail "todowrite tool is NOT available"
fi

# Test 3: Standard Pi tools still available
if grep -qi "read" output.txt && grep -qi "bash" output.txt; then
    pass "Standard Pi tools still available (read, bash)"
else
    fail "Standard Pi tools missing"
fi

echo ""
echo "=== Test Summary ==="
echo ""
```

- [ ] **Step 2: Make executable**

```bash
chmod +x tests/pi/test-tool-registration.sh
```

- [ ] **Step 3: Commit**

```bash
git add tests/pi/test-tool-registration.sh
git commit -m "test: add Pi tool registration test"
```

---

### Task 12: Write Subagent-Driven-Dev Integration Test

**Files:**
- Create: `tests/pi/test-subagent-driven-dev.sh`

- [ ] **Step 1: Write the integration test**

Write `tests/pi/test-subagent-driven-dev.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=========================================="
echo " Integration Test: Subagent-Driven Development"
echo "=========================================="
echo ""

# Create test project
TEST_PROJECT=$(create_test_project)
trap "cleanup_test_project $TEST_PROJECT" EXIT
cd "$TEST_PROJECT"

echo "Test project: $TEST_PROJECT"
echo ""

# Create a minimal implementation plan
mkdir -p docs/superpowers/plans
cat > docs/superpowers/plans/test-plan.md <<'PLANEOF'
# Test Math Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** Create a simple math library with add and multiply functions.

**Architecture:** Two pure functions in a single module with corresponding tests.

**Tech Stack:** Node.js with native test runner

---

### Task 1: Create Add Function

**Files:**
- Create: `src/math.js`
- Create: `test/math.test.js`

Implement an `add(a, b)` function that returns the sum of two numbers.

Write a test first, then implement. Commit when tests pass.

### Task 2: Create Multiply Function

**Files:**
- Modify: `src/math.js`
- Modify: `test/math.test.js`

Add a `multiply(a, b)` function that returns the product of two numbers.

Write a test first, then implement. Commit when tests pass.
PLANEOF

git add docs/
git commit -m "Add test implementation plan"

echo "Running Pi with implementation plan..."
echo ""

cd "$TEST_PROJECT"
pi --no-session \
  --print \
  --extension "$REPO_ROOT/.pi/extensions/superpowers-bootstrap.ts" \
  "Execute the implementation plan at docs/superpowers/plans/test-plan.md. Use subagent-driven-development." \
  2>&1 | tee output.txt

echo ""
echo "=== Verification Tests ==="
echo ""

# Test 1: superpowers_skill was invoked
if grep -qi "subagent-driven-development" output.txt; then
    pass "subagent-driven-development skill was invoked"
else
    fail "subagent-driven-development skill was NOT invoked"
fi

# Test 2: Implementation files created
verify_file_contains "src/math.js" "function add"
verify_file_contains "src/math.js" "function multiply"

# Test 3: Test file created
verify_file_contains "test/math.test.js" "add"
verify_file_contains "test/math.test.js" "multiply"

# Test 4: Tests pass
if node --test test/math.test.js 2>&1; then
    pass "Tests pass"
else
    fail "Tests do NOT pass"
fi

# Test 5: Git commits show proper workflow
COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
if [ "$COMMIT_COUNT" -ge 3 ]; then
    pass "Git history shows multiple commits (found $COMMIT_COUNT)"
else
    fail "Expected at least 3 commits, found $COMMIT_COUNT"
fi

echo ""
echo "=== Session Analysis ==="
echo ""

# Find and analyze the session
SESSION_FILE=$(find_recent_pi_session "$SCRIPT_DIR/../..")
if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
    python3 "$SCRIPT_DIR/analyze-session.py" "$SESSION_FILE"
else
    info "No session file found for analysis (--no-session was used)"
fi

echo ""
echo "=== Test Summary ==="
echo ""
```

- [ ] **Step 2: Make executable**

```bash
chmod +x tests/pi/test-subagent-driven-dev.sh
```

- [ ] **Step 3: Commit**

```bash
git add tests/pi/test-subagent-driven-dev.sh
git commit -m "test: add Pi subagent-driven-dev integration test"
```

---

## Task Execution Order

Tasks 1-3 are independent and can be done in any order. Tasks 4-8 depend on Task 1 (CLAUDE.md moved). Tasks 9-12 depend on Task 4 (extension exists).

```
Task 1 (move CLAUDE.md) ──┬── Task 2 (bootstrap CLAUDE.md)
                          ├── Task 3 (pi-tools.md)
                          ├── Task 4 (extension)
                          │     ├── Task 5 (using-superpowers update)
                          │     ├── Task 6 (README update)
                          │     ├── Task 7 (package.json)
                          │     ├── Task 8 (setup.sh)
                          │     └── Task 9 (test helpers)
                          │           ├── Task 10 (acceptance test)
                          │           ├── Task 11 (tool registration)
                          │           └── Task 12 (integration test)
```

Parallelizable groups:
- Group A: Tasks 2, 3 (after Task 1)
- Group B: Tasks 5, 6, 7, 8, 9 (after Task 4)
- Group C: Tasks 10, 11, 12 (after Task 9)
