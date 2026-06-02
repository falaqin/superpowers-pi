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
ln -sfn "$REPO_DIR/extensions/superpowers-bootstrap.ts" \
	"$PI_EXTS/superpowers-bootstrap.ts"
echo "  ✓ superpowers-bootstrap"

echo ""
echo "Superpowers for Pi installed."
echo "Restart pi or run /reload to activate."
