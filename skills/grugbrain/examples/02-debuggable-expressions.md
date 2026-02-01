# Example: Debuggable Expressions

## Before: Clever One-Liner

```typescript
// Authentication middleware - all in one expression
app.use((req, res, next) => {
  if (req.headers.authorization &&
      req.headers.authorization.startsWith('Bearer ') &&
      jwt.verify(req.headers.authorization.slice(7), SECRET) &&
      (jwt.decode(req.headers.authorization.slice(7)) as any).role === 'admin') {
    next()
  } else {
    res.status(401).send('Unauthorized')
  }
})
```

**Problems:**
- Can't see which condition failed
- Debugging requires breaking apart the expression
- No clear variable names showing intent
- Multiple calls to same parsing logic (slice(7) repeated)
- Hard to add logging or metrics

## After: Debuggable Grug Version

```typescript
// Break into named steps - easy to debug
app.use((req, res, next) => {
  const authHeader = req.headers.authorization
  if (!authHeader) {
    return res.status(401).send('No auth header')
  }

  const hasBearer = authHeader.startsWith('Bearer ')
  if (!hasBearer) {
    return res.status(401).send('Invalid auth format')
  }

  const token = authHeader.slice(7)

  const isValidToken = jwt.verify(token, SECRET)
  if (!isValidToken) {
    return res.status(401).send('Invalid token')
  }

  const decoded = jwt.decode(token) as TokenPayload
  const isAdmin = decoded.role === 'admin'
  if (!isAdmin) {
    return res.status(401).send('Requires admin role')
  }

  next()
})
```

**Benefits:**
- Can set breakpoint and inspect each variable
- Clear error messages show which check failed
- Easy to add logging: `logger.debug({ authHeader, hasBearer, isAdmin })`
- Variable names document intent
- No repeated computation (token extracted once)

## Another Example: Complex Conditional

### Before

```typescript
function canEditPost(user: User, post: Post): boolean {
  return (user.id === post.authorId || user.role === 'admin') &&
         !post.isLocked &&
         (post.status === 'draft' || post.status === 'pending') &&
         (Date.now() - post.createdAt.getTime()) < 24 * 60 * 60 * 1000
}
```

### After

```typescript
function canEditPost(user: User, post: Post): boolean {
  const isAuthor = user.id === post.authorId
  const isAdmin = user.role === 'admin'
  const hasPermission = isAuthor || isAdmin

  const isNotLocked = !post.isLocked

  const isDraft = post.status === 'draft'
  const isPending = post.status === 'pending'
  const isEditable = isDraft || isPending

  const ageMs = Date.now() - post.createdAt.getTime()
  const oneDayMs = 24 * 60 * 60 * 1000
  const isRecent = ageMs < oneDayMs

  return hasPermission && isNotLocked && isEditable && isRecent
}
```

**In debugger:**
```
hasPermission: false  ← Ah! User isn't author or admin
isNotLocked: true
isEditable: true
isRecent: true

Result: false (because hasPermission is false)
```

## Real-World Bug Example

### The Bug (clever version)

```typescript
// Bug hidden in complex expression
const eligibleUsers = users.filter(u =>
  u.isActive &&
  !u.isDeleted &&
  u.emailVerified &&
  u.permissions.includes('billing') &&
  u.subscription?.status === 'active'
)
```

**Bug:** Should be `u.subscription?.status === 'active'` OR `u.subscription?.type === 'trial'`

But finding this by staring at one-liner is hard!

### The Fix (grug version)

```typescript
const eligibleUsers = users.filter(u => {
  const isActive = u.isActive
  const isNotDeleted = !u.isDeleted
  const hasVerifiedEmail = u.emailVerified
  const hasBillingPermission = u.permissions.includes('billing')

  const subscriptionStatus = u.subscription?.status
  const hasActiveSubscription = subscriptionStatus === 'active'
  const hasTrialSubscription = subscriptionStatus === 'trial'  // Missing!
  const hasValidSubscription = hasActiveSubscription || hasTrialSubscription

  return isActive &&
         isNotDeleted &&
         hasVerifiedEmail &&
         hasBillingPermission &&
         hasValidSubscription
})
```

**Now bug is obvious:** Oh! We need to check for trial subscriptions too!

## Pattern: Early Returns

### Before

```typescript
function processPayment(order: Order, card: Card): Result {
  if (order.total > 0) {
    if (card.isValid) {
      if (!card.isExpired) {
        if (order.items.length > 0) {
          // actual logic here
          return { success: true }
        } else {
          return { success: false, error: 'No items' }
        }
      } else {
        return { success: false, error: 'Card expired' }
      }
    } else {
      return { success: false, error: 'Invalid card' }
    }
  } else {
    return { success: false, error: 'Invalid total' }
  }
}
```

### After

```typescript
function processPayment(order: Order, card: Card): Result {
  const hasPositiveTotal = order.total > 0
  if (!hasPositiveTotal) {
    return { success: false, error: 'Invalid total' }
  }

  const cardIsValid = card.isValid
  if (!cardIsValid) {
    return { success: false, error: 'Invalid card' }
  }

  const cardIsExpired = card.isExpired
  if (cardIsExpired) {
    return { success: false, error: 'Card expired' }
  }

  const hasItems = order.items.length > 0
  if (!hasItems) {
    return { success: false, error: 'No items' }
  }

  // Happy path at bottom, all guards passed
  return { success: true }
}
```

## The Debugger Test

**Bad code:** Can't tell what's wrong without adding console.logs

**Good code:** Set one breakpoint, inspect variables, immediately see problem

## Grug Rules for Expressions

1. **One concept per variable:** `isActive`, `hasPermission`, `isExpired`
2. **Name shows intent:** Not `temp1`, `temp2`, but `userIsAdmin`, `postIsLocked`
3. **Early returns for guards:** Check and fail fast, don't nest
4. **Break complex conditionals:** If it has `&&` or `||`, probably break it up
5. **OK to have more lines:** 15 obvious lines beats 3 clever lines

When young grug complain about too many variables, old grug show them debugger and say: "which version easier to debug?"

Young grug always quiet after that.
