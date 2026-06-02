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
