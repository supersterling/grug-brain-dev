# Testing Grug Brain Plugin

## Quick Test

1. **Load plugin:**
   ```bash
   cc --plugin-dir ~/.claude/plugins/grug-brain-dev
   ```

2. **Test slash command:**
   ```
   /grug
   ```
   
   Expected: Grug loads and speaks in grug-speak

3. **Test auto-trigger:**
   Say: "Is this code too complex?"
   
   Expected: Grug skill auto-loads

## Test Cases

### Test 1: Over-Abstraction

```
/grug

Review this code:

interface IRepository<T, K> {
  findById(id: K): Promise<T | null>
  findAll(): Promise<T[]>
}

class UserRepository implements IRepository<User, string> {
  // only implementation
}
```

**Expected:** Grug complains about premature abstraction, recommends simple functions

### Test 2: Complex Expression

```
/grug

Is this too complex?

const eligible = users.filter(u => u.active && !u.deleted && u.verified && u.permissions.includes('admin'))
```

**Expected:** Grug says hard to debug, recommends breaking into named variables

### Test 3: Microservices

```
/grug

Should I split my 100-user app into 5 microservices?
```

**Expected:** Grug reaches for club, recommends monolith

### Test 4: Auto-Trigger

```
Simplify this code:

function process(data, type, includeMetadata, useCache, validationLevel) {
  if (type === 'user') {
    if (includeMetadata) {
      if (useCache) {
        // ...
      }
    }
  }
}
```

**Expected:** Grug auto-loads (no /grug needed), reviews the code

## Success Criteria

- ✅ `/grug` command works
- ✅ Auto-triggers on key phrases
- ✅ Responds in grug-speak (broken English, "grug say", "complexity demon")
- ✅ Provides helpful technical advice
- ✅ Shows before/after code examples
- ✅ Maintains grug character throughout

## Troubleshooting

**Plugin not found:**
```bash
ls -la ~/.claude/plugins/grug-brain-dev/.claude-plugin/
cat ~/.claude/plugins/grug-brain-dev/.claude-plugin/plugin.json
```

**Skill not loading:**
```bash
ls -la ~/.claude/plugins/grug-brain-dev/skills/grugbrain/SKILL.md
```

**Wrong voice (not grug-speak):**
Check SKILL.md has CRITICAL section about grug-speak enforcement
