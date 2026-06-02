# Superpowers for Pi

Superpowers is a complete software development methodology for the [Pi coding agent](https://pi.dev), built on top of a set of composable skills that auto-trigger at the right moments.

**This is a Pi-specific fork** of the original [obra/superpowers](https://github.com/obra/superpowers) by Jesse Vincent. All credit for the original skills system goes to him and [Prime Radiant](https://primeradiant.com).

## Quickstart

```bash
pi install npm:@falaqin/superpowers-pi
```

That's it. Restart Pi and you have Superpowers.

## How it works

It starts from the moment you fire up Pi. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do.

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest.

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY.

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.

## Installation

Install from npm (lightweight, no git history):

```bash
pi install npm:@falaqin/superpowers-pi
```

This downloads the skills and the `superpowers-bootstrap` extension that registers `superpowers_skill` and `todowrite` tools and loads the Superpowers workflow at session start.

**Alternative — install from GitHub:**

```bash
pi install git:github.com/falaqin/superpowers-pi
```

**Manual setup:**

```bash
git clone https://github.com/falaqin/superpowers-pi
cd superpowers-pi
./setup.sh
```

After any install method, restart Pi or run `/reload` to activate.

## The Basic Workflow

1. **brainstorming** - Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.
2. **using-git-worktrees** - Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.
3. **writing-plans** - Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.
4. **subagent-driven-development** or **executing-plans** - Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with checkpoints.
5. **test-driven-development** - Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.
6. **requesting-code-review** - Reviews against plan, reports issues by severity. Critical issues block progress.
7. **finishing-a-development-branch** - Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration**
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/).

## License

MIT License - see LICENSE file for details

Based on the original [obra/superpowers](https://github.com/obra/superpowers) by [Jesse Vincent](https://blog.fsck.com) and [Prime Radiant](https://primeradiant.com), used under the MIT license.
