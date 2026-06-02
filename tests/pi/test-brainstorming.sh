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
echo "Running Pi with: 'Let's make a react todo list'"
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
