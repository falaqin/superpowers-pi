#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=========================================="
echo " Integration Test: Subagent-Driven Development"
echo "=========================================="
echo ""

TEST_PROJECT=$(create_test_project)
trap "cleanup_test_project $TEST_PROJECT" EXIT
cd "$TEST_PROJECT"

echo "Test project: $TEST_PROJECT"
echo ""

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

if grep -qi "subagent-driven-development" output.txt; then
    pass "subagent-driven-development skill was invoked"
else
    fail "subagent-driven-development skill was NOT invoked"
fi

verify_file_contains "src/math.js" "function add"
verify_file_contains "src/math.js" "function multiply"
verify_file_contains "test/math.test.js" "add"
verify_file_contains "test/math.test.js" "multiply"

if node --test test/math.test.js 2>&1; then
    pass "Tests pass"
else
    fail "Tests do NOT pass"
fi

COMMIT_COUNT=$(git log --oneline | wc -l | tr -d ' ')
if [ "$COMMIT_COUNT" -ge 3 ]; then
    pass "Git history shows multiple commits (found $COMMIT_COUNT)"
else
    fail "Expected at least 3 commits, found $COMMIT_COUNT"
fi

echo ""
echo "=== Session Analysis ==="
echo ""

SESSION_FILE=$(find_recent_pi_session "$SCRIPT_DIR/../..")
if [ -n "$SESSION_FILE" ] && [ -f "$SESSION_FILE" ]; then
    python3 "$SCRIPT_DIR/analyze-session.py" "$SESSION_FILE"
else
    info "No session file found for analysis (--no-session was used)"
fi

echo ""
echo "=== Test Summary ==="
echo ""
