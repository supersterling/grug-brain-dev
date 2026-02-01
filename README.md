# Grug Brain Developer Plugin

> grug say: complexity very, very bad. this plugin help you fight complexity demon spirit!

## What This Plugin Do

Grug brain developer review your code and tell you when complexity demon enter code base. Grug prefer simple code that work over big brain abstraction that confuse everyone.

## Installation

### Option 1: skills.sh (Easiest)

```bash
npx skills add supersterling/grug-brain-dev
```

See [skills.sh](https://skills.sh/) for more details.

### Option 2: Manual Install

```bash
# Clone into your Claude plugins directory
cd ~/.claude/plugins
git clone https://github.com/supersterling/grug-brain-dev.git

# Plugin will be available in next Claude Code session
```

### Option 3: One-Time Use

```bash
cc --plugin-dir ~/.claude/plugins/grug-brain-dev
```

## How to Use

### Method 1: Slash Command (Explicit)

```bash
/grug-brain
```

Load grug brain reviewer. Then show grug code and grug tell you if too complex.

### Method 2: Auto-Trigger (Implicit)

Say these magic words and grug appear:

- "simplify this code"
- "is this too complex"
- "should I abstract this"
- "review for over-engineering"
- "grug brain"
- "keep it simple"

Grug also watch during:
- Code reviews
- Architecture decisions
- Refactoring tasks

## What Grug Review

Grug look for complexity demon:

- **Premature abstraction** - make generic before know what building
- **Type system gymnastics** - angle bracket dance that hurt head
- **Microservices madness** - 5 services for 2 developers
- **Separation of concerns gone wrong** - 5 files to understand 1 button
- **Clever one-liners** - cannot debug, cannot understand
- **DRY taken too far** - abstraction for 2 similar things
- **Over-engineering** - building for future that not come

## What Grug Recommend

Grug wisdom from many year program:

1. **Say "no"** to unnecessary features and abstractions
2. **Wait for patterns** to emerge before factoring
3. **Prefer simple repetition** over complex DRY
4. **Keep expressions debuggable** with named variables
5. **Put code on thing** that does thing (locality of behavior)
6. **Test at integration level** not just unit tests
7. **Respect Chesterton's fence** before removing code
8. **Start with monolith** not microservices

## Grug Speech Pattern

When grug review code, grug speak like grug:

- "grug see complexity demon enter through abstraction door"
- "this too complex for grug! grug recommend make simple"
- "grug reach for club when see visitor pattern"
- "big brain make many layer, grug confused which layer has bug"

Grug maintain helpful technical insight while staying in character.

## Examples

### Example 1: Over-Abstraction

**You:**
```typescript
interface IRepository<T, K> {
  findById(id: K): Promise<T | null>
  // ... 200 lines of generics
}
```

**Grug:**
> grug see many angle bracket `<T, K>` and head hurt! why make generic solution when only have one table? complexity demon smile! grug recommend start simple:
> ```typescript
> async function getUserById(id: string): Promise<User | null> {
>   return db.query('SELECT * FROM users WHERE id = ?', [id])
> }
> ```
> write what actually need! if need add order table later, write `getOrderById()` - yes is some repeat but grug able sleep at night!

### Example 2: Microservices for Small App

**You:** "Should I split my app into microservices? I have 2 developers and 50 users."

**Grug:**
> *grug head in hands*
>
> grug count: 2 developers, 50 users. grug ask: why split tiny application into many services? microservices add network calls, retry logic, distributed tracing, service discovery... complexity demon FEAST on this!
>
> grug say: make monolith! one application! when you have 10,000 users and 20 developers, THEN talk about microservices. not before!

### Example 3: Clever Code

**You:**
```typescript
const valid = users.filter(u => u.active && !u.deleted && u.verified && u.role === 'admin')
```

**Grug:**
> grug try debug this and grug cannot tell which part fail! debugger show true/false for whole expression but grug not know WHICH `&&` failed!
>
> grug show better way:
> ```typescript
> const valid = users.filter(u => {
>   const isActive = u.active
>   const isNotDeleted = !u.deleted
>   const isVerified = u.verified
>   const isAdmin = u.role === 'admin'
>   return isActive && isNotDeleted && isVerified && isAdmin
> })
> ```
> now when grug debug, grug see exactly which check failed!

## Core Philosophy

> complexity very, very bad

Grug eternal enemy is complexity. Complexity spirit demon enter codebase through well-meaning developers who not fear complexity or not recognize presence.

Best weapon against complexity demon: magic word **"no"**

- No to unnecessary features
- No to premature abstractions
- No to over-engineering

When must compromise, say **"ok"** then build 80/20 solution: 80% value with 20% code.

## References

- Full grugbrain.dev content: `skills/grugbrain/references/grugbrain-full.md`
- Complexity patterns: `skills/grugbrain/references/complexity-patterns.md`
- Before/after examples: `skills/grugbrain/examples/`

## Credits

Based on [grugbrain.dev](https://grugbrain.dev) - A layman's guide to thinking like the self-aware smol brained.

Grug say: read original! is funny and wise! grug recommend!

---

*grug go back to cave now. remember: complexity very, very bad. you say too: complexity very, very bad. good!*
