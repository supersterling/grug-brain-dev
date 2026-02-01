# Complexity Anti-Patterns and Solutions

Specific patterns that invite the complexity demon and their grug-brained alternatives.

## Anti-Pattern: Premature Abstraction

### Symptoms
- Abstractions created before understanding domain
- Generic solutions to problems not yet encountered
- "Future-proof" code that handles hypothetical cases
- Layers of indirection with no current users

### Example: Bad

```typescript
// Created on day 1 of project
interface DataStore<T, K> {
  get(key: K): Promise<T | null>
  set(key: K, value: T): Promise<void>
  delete(key: K): Promise<boolean>
  query(predicate: (item: T) => boolean): Promise<T[]>
}

class CachedDataStore<T, K> implements DataStore<T, K> {
  constructor(
    private inner: DataStore<T, K>,
    private cache: Cache<K, T>,
    private strategy: CacheStrategy
  ) {}
  // ... complex caching logic
}

class DatabaseDataStore implements DataStore<User, string> {
  // ... only implementation, but hidden behind abstraction
}
```

### Example: Good

```typescript
// Start simple, let pattern emerge
async function getUser(id: string): Promise<User | null> {
  return db.query('SELECT * FROM users WHERE id = ?', [id])
}

async function saveUser(user: User): Promise<void> {
  await db.query('INSERT INTO users ...', user)
}

// Later, if caching actually needed:
const userCache = new Map<string, User>()

async function getUser(id: string): Promise<User | null> {
  if (userCache.has(id)) return userCache.get(id)!
  const user = await db.query('SELECT * FROM users WHERE id = ?', [id])
  if (user) userCache.set(id, user)
  return user
}
```

### Grug Rule
Wait for three concrete use cases before abstracting. Two instances is coincidence, three is pattern.

## Anti-Pattern: Abstraction Astronauts

### Symptoms
- Type system gymnastics that obscure business logic
- Monads, functors, and category theory in CRUD app
- Code that reads like academic paper
- "Elegant" solutions nobody can debug

### Example: Bad

```typescript
type Functor<F> = <A, B>(fa: F<A>, f: (a: A) => B) => F<B>
type Monad<M> = Functor<M> & {
  of: <A>(a: A) => M<A>
  chain: <A, B>(ma: M<A>, f: (a: A) => M<B>) => M<B>
}

const Result: Monad<Result> = {
  // ... academic implementation
}

// Using it for simple validation:
const validateUser = (input: unknown): Result<User> =>
  Result.of(input)
    .chain(validateNotNull)
    .chain(validateShape)
    .chain(validateEmail)
    .chain(validateAge)
```

### Example: Good

```typescript
function validateUser(input: unknown): User | Error {
  if (input == null) {
    return new Error('User cannot be null')
  }

  if (typeof input !== 'object') {
    return new Error('User must be object')
  }

  const email = input.email
  if (!isValidEmail(email)) {
    return new Error('Invalid email')
  }

  // ... more validations

  return input as User
}
```

### Grug Rule
If you need PhD to understand code that validates email, complexity demon has won.

## Anti-Pattern: Microservices Too Early

### Symptoms
- Three developers, five microservices
- Network calls for operations that were function calls
- Distributed transaction complexity
- "We might need to scale" for app with 10 users

### Example: Bad

```
UserService (port 3001)
  ↓ HTTP
AuthService (port 3002)
  ↓ HTTP
EmailService (port 3003)
  ↓ HTTP
NotificationService (port 3004)

// To send password reset email:
// 1. UserService finds user
// 2. Calls AuthService to generate token
// 3. Calls EmailService to format email
// 4. Calls NotificationService to send
// Network: 4 round trips, 3 potential failure points
```

### Example: Good

```typescript
// Monolith modules
async function sendPasswordReset(email: string) {
  const user = await users.findByEmail(email)
  if (!user) return

  const token = auth.generateResetToken(user.id)
  const emailHtml = templates.passwordReset(user.name, token)
  await notifications.sendEmail(user.email, emailHtml)
}

// In-process: 0 network calls, 0 distributed failures
```

### Grug Rule
Start with monolith. Split when team size or deployment requirements force it, not before.

## Anti-Pattern: Separation of Concerns Taken Too Far

### Symptoms
- Five files to understand one button click
- CSS in one file, HTML in another, JS in third
- Changing button color requires editing multiple locations
- "Clean architecture" with 7 layers for CRUD

### Example: Bad

```
components/
  Button.tsx           (renders button)
styles/
  button.css          (button styles)
handlers/
  buttonHandlers.ts   (click logic)
state/
  buttonState.ts      (button state)
actions/
  buttonActions.ts    (state updates)
```

### Example: Good

```typescript
// Button.tsx - everything in one place
function Button({ label, onClick }: Props) {
  const [clicked, setClicked] = useState(false)

  return (
    <button
      className="px-4 py-2 bg-blue-500 text-white rounded"
      onClick={() => {
        setClicked(true)
        onClick()
      }}
    >
      {clicked ? '✓ ' : ''}{label}
    </button>
  )
}
```

### Grug Rule
Prefer locality of behavior (LoB). Put code on the thing that does the thing.

## Anti-Pattern: DRY Taken Too Far

### Symptoms
- Abstraction created for two similar-but-different cases
- Callback hell to handle variations
- Boolean flags controlling behavior
- "Reusable" code nobody can reuse

### Example: Bad

```typescript
function processData(
  data: unknown,
  transformType: 'user' | 'order' | 'product',
  includeMetadata: boolean,
  useCache: boolean,
  validationLevel: 'strict' | 'permissive',
  errorHandling: 'throw' | 'return' | 'log'
) {
  // 200 lines of branching logic
  if (transformType === 'user') {
    if (includeMetadata) {
      if (useCache) {
        // ...
      }
    }
  }
  // ... complexity demon feasts
}
```

### Example: Good

```typescript
// Separate simple functions
function processUser(user: unknown): User {
  // 20 lines, easy to understand
}

function processOrder(order: unknown): Order {
  // 25 lines, slightly different logic
}

function processProduct(product: unknown): Product {
  // 18 lines, even more different
}

// Some repetition, but clear and debuggable
```

### Grug Rule
Prefer obvious repeated code over clever abstraction. Copy-paste three times before abstracting.

## Anti-Pattern: Generic Mania

### Symptoms
- Generics nested three levels deep
- Type parameters with constraints on constraints
- Code that works for "any T, where T extends U & V"
- Nobody understands what the code actually does

### Example: Bad

```typescript
type Mapper<T, U, V extends keyof T> = {
  [K in V]: (value: T[K]) => U
}

function transform<
  T extends Record<string, unknown>,
  U,
  V extends keyof T,
  W extends Mapper<T, U, V>
>(
  input: T,
  mappers: W,
  keys: V[]
): Record<V, U> {
  // ... type tetris
}
```

### Example: Good

```typescript
// Specific, understandable code
function transformUser(user: User): UserDTO {
  return {
    id: user.id,
    name: user.name,
    email: user.email
  }
}

function transformOrder(order: Order): OrderDTO {
  return {
    id: order.id,
    total: order.total,
    items: order.items.length
  }
}
```

### Grug Rule
Limit generics to containers (Array<T>, Map<K,V>). Business logic should be concrete.

## Anti-Pattern: Visitor Pattern

### Symptoms
- Double dispatch complexity
- Adding operation requires changing many classes
- "Extensible" design nobody can extend
- Gang of Four pattern applied without understanding

### Example: Bad

```typescript
interface Visitor {
  visitUser(user: User): void
  visitOrder(order: Order): void
  visitProduct(product: Product): void
}

class User {
  accept(visitor: Visitor) {
    visitor.visitUser(this)
  }
}

// To add validation, create visitor:
class ValidationVisitor implements Visitor {
  visitUser(user: User) { /* validate */ }
  visitOrder(order: Order) { /* validate */ }
  visitProduct(product: Product) { /* validate */ }
}

// To add serialization, create another visitor:
class SerializationVisitor implements Visitor {
  // ... and so on
}
```

### Example: Good

```typescript
function validateUser(user: User): boolean {
  return user.email.includes('@')
}

function validateOrder(order: Order): boolean {
  return order.total > 0
}

function serializeUser(user: User): string {
  return JSON.stringify(user)
}

// Simple, understandable, no pattern needed
```

### Grug Rule
Visitor pattern bad. Use functions.

## Anti-Pattern: Callback Hell

### Symptoms
- Closures nested five levels deep
- Lost in sea of anonymous functions
- Debugging impossible (which callback failed?)
- "Functional programming" turned into nightmare

### Example: Bad

```typescript
getData(userId, (user) => {
  getOrders(user.id, (orders) => {
    getProducts(orders[0].id, (products) => {
      getInventory(products[0].id, (inventory) => {
        updateStock(inventory.id, (result) => {
          // finally!
        }, (error) => {
          // which call failed??
        })
      })
    })
  })
})
```

### Example: Good

```typescript
async function updateUserStock(userId: string) {
  const user = await getData(userId)
  const orders = await getOrders(user.id)
  const products = await getProducts(orders[0].id)
  const inventory = await getInventory(products[0].id)
  const result = await updateStock(inventory.id)
  return result
}

// Linear, debuggable, obvious
```

### Grug Rule
Closures like salt: small amount good, too much kill. Use async/await for sequential operations.

## Anti-Pattern: Framework Overkill

### Symptoms
- React app for static content
- GraphQL API for CRUD
- Message queue for request/response
- Kubernetes for single server

### Example: Bad

```typescript
// Static about page using React, Redux, GraphQL, Webpack
const AboutPage = () => {
  const dispatch = useDispatch()
  const { data } = useQuery(ABOUT_CONTENT_QUERY)

  useEffect(() => {
    dispatch(loadAboutContent())
  }, [])

  return <div>{data?.about?.content}</div>
}
```

### Example: Good

```html
<!-- about.html -->
<html>
  <body>
    <h1>About Us</h1>
    <p>We make software.</p>
  </body>
</html>
```

### Grug Rule
Use simplest tool that works. Static content should be static. Don't SPA everything.

## Anti-Pattern: Test Everything Always

### Symptoms
- 100% unit test coverage requirement
- Tests more complex than code
- Mocking mocks that mock mocks
- Tests break on every refactor

### Example: Bad

```typescript
describe('UserService', () => {
  let mockDb: jest.Mocked<Database>
  let mockCache: jest.Mocked<Cache>
  let mockLogger: jest.Mocked<Logger>
  let mockValidator: jest.Mocked<Validator>

  beforeEach(() => {
    mockDb = createMockDatabase()
    mockCache = createMockCache()
    mockLogger = createMockLogger()
    mockValidator = createMockValidator()
    // ... 50 lines of mock setup
  })

  it('should get user when user exists', async () => {
    mockDb.query.mockResolvedValue({ id: '1', name: 'test' })
    mockCache.get.mockResolvedValue(null)
    // ... testing mocks, not reality
  })
})
```

### Example: Good

```typescript
// Integration test with real database
describe('User operations', () => {
  it('should create and retrieve user', async () => {
    const userId = await createUser({ name: 'test', email: 'test@example.com' })
    const user = await getUser(userId)

    expect(user.name).toBe('test')
    expect(user.email).toBe('test@example.com')
  })
})

// Tests actual behavior, easy to debug
```

### Grug Rule
Focus on integration tests at cut points. Limit unit tests. Avoid mocking. Real bugs live at boundaries.

## Anti-Pattern: Configuration Overdose

### Symptoms
- Every value configurable
- YAML/JSON configuration 500+ lines
- Runtime behavior changes via config
- "Flexible" system nobody can configure

### Example: Bad

```yaml
# config.yaml (500 lines)
app:
  server:
    port: ${PORT:-3000}
    host: ${HOST:-localhost}
    timeout:
      read: ${READ_TIMEOUT:-30s}
      write: ${WRITE_TIMEOUT:-30s}
  database:
    primary:
      host: ${DB_HOST}
      port: ${DB_PORT}
      pool:
        min: ${DB_POOL_MIN:-5}
        max: ${DB_POOL_MAX:-20}
        acquireTimeout: ${DB_ACQUIRE_TIMEOUT:-30s}
# ... 450 more lines
```

### Example: Good

```typescript
// Simple, sensible defaults
const config = {
  port: process.env.PORT || 3000,
  dbUrl: process.env.DATABASE_URL,
  // Only configure what actually varies
}
```

### Grug Rule
Configure only what actually changes between environments. Prefer code over config.

## Summary: Spotting Complexity Demon

### Red Flags
1. **Abstraction without usage**: Creating interfaces/generics before second user
2. **Indirection layers**: More than 2-3 layers between request and action
3. **Configuration explosion**: More config than code
4. **Framework maximalism**: Using newest/heaviest tool for simple task
5. **Pattern worship**: Applying Gang of Four patterns because "proper"
6. **Type tetris**: Spending more time satisfying compiler than solving problem
7. **Test mocking hell**: More mock setup than actual code
8. **Microservice madness**: Network calls for function calls
9. **DRY absolutism**: Abstraction for two similar things
10. **SoC extremism**: Five files to understand one feature

### Ask Yourself
- Can junior developer understand this in 6 months?
- Does this make the simple case simpler or harder?
- Am I solving a problem I have or one I imagine?
- Would deleting this abstraction make code clearer?
- Is this code or is this résumé-driven development?

### The Grug Test

**Before adding complexity, ask:**

1. Do I have three concrete use cases? (Not "might need")
2. Is the simpler solution actually insufficient? (Not "less elegant")
3. Can I explain this to rubber duck without saying "well, in the future..."?
4. Will debugging this be easier or harder?
5. Am I making the common case faster or adding ceremony?

**If any answer is no, complexity demon approaches. Say no.**

## Escape Routes

### If Already Complex

1. **Don't make worse**: Stop adding abstractions
2. **Wait for clarity**: Live with current complexity until cut points emerge
3. **Small refactors**: Improve one piece at a time
4. **Test boundaries**: Lock down behavior before changing
5. **Respect Chesterton's fence**: Understand before removing

### If Starting Fresh

1. **Prototype first**: Build working version, ugly okay
2. **Resist big brain**: Defer "proper" architecture
3. **Wait for three**: Need three use cases before abstracting
4. **Cut points emerge**: Watch for natural boundaries
5. **Stay close to shore**: Small steps, always working

Complexity very, very bad. Simple very, very good. Grug say often: when doubt, choose boring.
