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
