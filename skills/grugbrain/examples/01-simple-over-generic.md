# Example: Simple Over Generic

## Before: Over-Engineered Generic Solution

```typescript
// Premature abstraction - day 1 of project
interface Repository<T, ID> {
  findById(id: ID): Promise<T | null>
  findAll(options?: QueryOptions<T>): Promise<T[]>
  save(entity: T): Promise<T>
  delete(id: ID): Promise<boolean>
  update(id: ID, updates: Partial<T>): Promise<T>
}

interface QueryOptions<T> {
  where?: Partial<T>
  orderBy?: keyof T
  limit?: number
  offset?: number
}

class BaseRepository<T extends { id: ID }, ID> implements Repository<T, ID> {
  constructor(private tableName: string) {}

  async findById(id: ID): Promise<T | null> {
    const query = `SELECT * FROM ${this.tableName} WHERE id = ?`
    return this.db.query(query, [id])
  }

  async findAll(options?: QueryOptions<T>): Promise<T[]> {
    let query = `SELECT * FROM ${this.tableName}`
    const params: unknown[] = []

    if (options?.where) {
      const conditions = Object.entries(options.where)
        .map(([key, _]) => `${key} = ?`)
        .join(' AND ')
      query += ` WHERE ${conditions}`
      params.push(...Object.values(options.where))
    }

    if (options?.orderBy) {
      query += ` ORDER BY ${String(options.orderBy)}`
    }

    if (options?.limit) {
      query += ` LIMIT ?`
      params.push(options.limit)
    }

    if (options?.offset) {
      query += ` OFFSET ?`
      params.push(options.offset)
    }

    return this.db.query(query, params)
  }

  // ... more generic methods
}

// Usage (for single user table!)
class UserRepository extends BaseRepository<User, string> {
  constructor() {
    super('users')
  }
}

const userRepo = new UserRepository()
const user = await userRepo.findById('123')
```

**Problems:**
- Generic abstraction created before second use case exists
- Complex query builder for simple needs
- Type gymnastics (T extends { id: ID })
- Debugging harder (which layer has bug?)
- More code to understand than simple solution

## After: Simple Grug Solution

```typescript
// Start simple - build what you actually need
async function getUserById(id: string): Promise<User | null> {
  return db.query('SELECT * FROM users WHERE id = ?', [id])
}

async function getAllUsers(): Promise<User[]> {
  return db.query('SELECT * FROM users ORDER BY created_at DESC')
}

async function createUser(user: User): Promise<User> {
  const result = await db.query(
    'INSERT INTO users (id, name, email) VALUES (?, ?, ?)',
    [user.id, user.name, user.email]
  )
  return user
}

async function deleteUser(id: string): Promise<boolean> {
  const result = await db.query('DELETE FROM users WHERE id = ?', [id])
  return result.affectedRows > 0
}

// Usage
const user = await getUserById('123')
```

**Benefits:**
- Obvious what each function does
- Easy to debug (set breakpoint, see SQL)
- No unnecessary abstraction
- Fast to read and understand
- Easy to customize for special cases

## Evolution Path

**Later, when second table appears:**

```typescript
// Still concrete, but now two sets of functions
async function getUserById(id: string): Promise<User | null> {
  return db.query('SELECT * FROM users WHERE id = ?', [id])
}

async function getOrderById(id: string): Promise<Order | null> {
  return db.query('SELECT * FROM orders WHERE id = ?', [id])
}

// Some duplication, but clear and debuggable
```

**If third table appears and pattern is obvious:**

```typescript
// NOW abstract (after 3 concrete examples)
function createFindById<T>(tableName: string) {
  return async (id: string): Promise<T | null> => {
    return db.query(`SELECT * FROM ${tableName} WHERE id = ?`, [id])
  }
}

const getUserById = createFindById<User>('users')
const getOrderById = createFindById<Order>('orders')
const getProductById = createFindById<Product>('products')

// Simple abstraction that emerged from real use
// Still easy to debug
// Can easily make custom version if needed
```

## Grug Wisdom

**Day 1:** Write concrete code for concrete problem

**Day 30:** Notice repetition, but resist urge to abstract

**Day 90:** Three concrete examples exist, pattern clear, NOW abstract

**Result:** Abstraction that actually helps instead of hurts
