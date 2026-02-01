#!/bin/bash
# Quick validation script for Agent Skills spec compliance

echo "🔍 Validating Agent Skills format..."
echo

# Check directory structure
if [ ! -d "skills/grug-brain-development" ]; then
  echo "❌ Directory 'skills/grug-brain-development' not found"
  exit 1
fi
echo "✅ Skill directory exists: skills/grug-brain-development/"

# Check SKILL.md exists
if [ ! -f "skills/grug-brain-development/SKILL.md" ]; then
  echo "❌ SKILL.md not found"
  exit 1
fi
echo "✅ SKILL.md exists"

# Extract frontmatter name
SKILL_NAME=$(awk '/^name:/{print $2; exit}' skills/grug-brain-development/SKILL.md)
if [ "$SKILL_NAME" != "grug-brain-development" ]; then
  echo "❌ Name field '$SKILL_NAME' doesn't match directory name"
  exit 1
fi
echo "✅ Name field matches directory: $SKILL_NAME"

# Check name format (lowercase, hyphens only)
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "❌ Name contains invalid characters (only lowercase a-z, 0-9, - allowed)"
  exit 1
fi
echo "✅ Name format is valid (lowercase, hyphens only)"

# Check description exists
if ! grep -q "^description:" skills/grug-brain-development/SKILL.md; then
  echo "❌ Description field missing"
  exit 1
fi
echo "✅ Description field present"

# Check for old plugin.json
if [ -f ".claude-plugin/plugin.json" ]; then
  echo "⚠️  Warning: .claude-plugin/plugin.json still exists (Claude Code specific)"
fi

echo
echo "✅ All checks passed! Skill follows Agent Skills specification."
echo
echo "Install with: npx skills add supersterling/grug-brain-dev"
