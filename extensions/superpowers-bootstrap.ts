import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";

// ── Skill path resolution ──────────────────────────────────────────────

function findPluginRoot(extensionDir: string): string {
  const candidate = path.resolve(extensionDir, "..", "..");
  const skillsDir = path.join(candidate, "skills");
  if (fs.existsSync(skillsDir) && fs.statSync(skillsDir).isDirectory()) {
    return candidate;
  }
  throw new Error(
    "Could not find Superpowers skills directory. " +
    "Ensure the superpowers-pi package is installed correctly."
  );
}

function resolveSkillPath(skillName: string): string | null {
  const searchDirs: string[] = [];
  searchDirs.push(path.join(os.homedir(), ".pi", "agent", "skills"));
  searchDirs.push(path.join(os.homedir(), ".agents", "skills"));
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
    const directPath = path.join(skillsDir, skillName, "SKILL.md");
    if (fs.existsSync(directPath)) return directPath;
    try {
      const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
      for (const entry of entries) {
        if (!entry.isDirectory()) continue;
        const nestedPath = path.join(skillsDir, entry.name, skillName, "SKILL.md");
        if (fs.existsSync(nestedPath)) return nestedPath;
      }
    } catch {
    }
  }
  return null;
}

function buildSkillList(skillsDir: string): string {
  if (!fs.existsSync(skillsDir)) return "";
  const lines: string[] = [];
  try {
    const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;
      const skillMd = path.join(skillsDir, entry.name, "SKILL.md");
      if (!fs.existsSync(skillMd)) continue;
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
  }
  return lines.join("\n");
}

// ── Extension ───────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
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
      if (!fs.existsSync(todosDir)) {
        fs.mkdirSync(todosDir, { recursive: true });
      }
      let existing: Record<string, unknown> = {};
      if (fs.existsSync(todosPath)) {
        try {
          existing = JSON.parse(fs.readFileSync(todosPath, "utf-8"));
        } catch {
        }
      }
      const todosData = {
        updated: new Date().toISOString(),
        todos: params.todos,
      };
      fs.writeFileSync(todosPath, JSON.stringify(todosData, null, 2), "utf-8");
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
      message: {
        customType: "superpowers-bootstrap",
        content: bootstrapMessage,
        display: true,
      },
    };
  });
}
