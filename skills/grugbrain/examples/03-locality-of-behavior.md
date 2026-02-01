# Example: Locality of Behavior (LoB)

## Before: Separation of Concerns (SoC) - Files Everywhere

```
src/
  components/
    TodoItem.tsx          # Just renders the markup
  styles/
    TodoItem.css          # Styles live here
  handlers/
    todoHandlers.ts       # Click handlers here
  state/
    todoState.ts          # State management here
  actions/
    todoActions.ts        # State updates here
  types/
    Todo.ts               # Type definitions here
```

### TodoItem.tsx
```typescript
import './styles/TodoItem.css'
import { handleTodoClick, handleDeleteClick } from '../handlers/todoHandlers'
import { useTodoState } from '../state/todoState'

export function TodoItem({ id }: Props) {
  const todo = useTodoState(id)

  return (
    <div className="todo-item">
      <span
        className="todo-text"
        onClick={() => handleTodoClick(id)}
      >
        {todo.text}
      </span>
      <button
        className="todo-delete"
        onClick={() => handleDeleteClick(id)}
      >
        Delete
      </button>
    </div>
  )
}
```

### styles/TodoItem.css
```css
.todo-item {
  display: flex;
  padding: 8px;
  border-bottom: 1px solid #ccc;
}

.todo-text {
  flex: 1;
  cursor: pointer;
}

.todo-delete {
  background: red;
  color: white;
}
```

### handlers/todoHandlers.ts
```typescript
import { toggleTodo, deleteTodo } from '../actions/todoActions'

export function handleTodoClick(id: string) {
  toggleTodo(id)
}

export function handleDeleteClick(id: string) {
  if (confirm('Delete todo?')) {
    deleteTodo(id)
  }
}
```

**Problem:** To understand what delete button does, grug must visit:
1. TodoItem.tsx (see button has onClick)
2. todoHandlers.ts (see it calls handleDeleteClick)
3. todoActions.ts (see it actually deletes)
4. TodoItem.css (see button styles)

**Four files to understand one button!** Complexity demon happy!

## After: Locality of Behavior - Everything in One Place

```
src/
  components/
    TodoItem.tsx          # Everything here!
```

### TodoItem.tsx (complete)
```typescript
import { useState } from 'react'

interface Todo {
  id: string
  text: string
  completed: boolean
}

export function TodoItem({ todo, onToggle, onDelete }: Props) {
  const [isDeleting, setIsDeleting] = useState(false)

  return (
    <div
      style={{
        display: 'flex',
        padding: '8px',
        borderBottom: '1px solid #ccc'
      }}
    >
      <span
        style={{
          flex: 1,
          cursor: 'pointer',
          textDecoration: todo.completed ? 'line-through' : 'none'
        }}
        onClick={() => onToggle(todo.id)}
      >
        {todo.text}
      </span>

      <button
        style={{
          background: isDeleting ? '#ff0000' : '#cc0000',
          color: 'white',
          border: 'none',
          padding: '4px 8px',
          cursor: 'pointer'
        }}
        onClick={() => {
          if (confirm('Delete this todo?')) {
            setIsDeleting(true)
            onDelete(todo.id)
          }
        }}
        onMouseEnter={() => setIsDeleting(true)}
        onMouseLeave={() => setIsDeleting(false)}
      >
        Delete
      </button>
    </div>
  )
}
```

**Benefits:**
- One file, one component, everything visible
- See what delete button does without leaving file
- Easy to copy/paste to other projects
- Inline styles show exactly what elements look like
- Logic and presentation together (as it should be!)

## Real-World Example: Modal Dialog

### Before: SoC (Separated)

```
src/
  components/Modal/
    Modal.tsx
    ModalHeader.tsx
    ModalBody.tsx
    ModalFooter.tsx
  styles/
    modal.css
  hooks/
    useModal.ts
  context/
    ModalContext.tsx
  utils/
    modalUtils.ts
```

**To understand modal close button:**
- Check Modal.tsx for structure
- Check ModalHeader.tsx for close button
- Check modal.css for styles
- Check useModal.ts for close logic
- Check ModalContext.tsx for state
- Check modalUtils.ts for helpers

**Six files!** Complexity demon feast!

### After: LoB (Together)

```typescript
// Modal.tsx - complete modal in one file
import { useState, ReactNode } from 'react'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title: string
  children: ReactNode
}

export function Modal({ isOpen, onClose, title, children }: ModalProps) {
  if (!isOpen) return null

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}
      onClick={onClose}
    >
      <div
        style={{
          background: 'white',
          borderRadius: '8px',
          padding: '24px',
          maxWidth: '500px',
          width: '100%'
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div style={{ display: 'flex', marginBottom: '16px' }}>
          <h2 style={{ flex: 1, margin: 0 }}>{title}</h2>
          <button
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              fontSize: '24px',
              cursor: 'pointer'
            }}
          >
            ×
          </button>
        </div>

        {/* Body */}
        <div style={{ marginBottom: '16px' }}>
          {children}
        </div>

        {/* Footer */}
        <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
          <button
            onClick={onClose}
            style={{
              padding: '8px 16px',
              cursor: 'pointer'
            }}
          >
            Close
          </button>
        </div>
      </div>
    </div>
  )
}

// Usage
function App() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <>
      <button onClick={() => setIsOpen(true)}>Open Modal</button>

      <Modal
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        title="My Modal"
      >
        <p>Modal content here</p>
      </Modal>
    </>
  )
}
```

**Everything visible in one file:**
- What modal looks like (inline styles)
- How it behaves (onClick handlers)
- What state it manages (isOpen)
- How to use it (example at bottom)

## When SoC Makes Sense

Grug not say SoC always bad. Sometimes good:

### Good separation: Different responsibilities
```
src/
  database/
    connection.ts        # Database connection
  api/
    routes.ts            # HTTP routes
  email/
    sender.ts            # Email sending
```

These are genuinely different systems. Separation makes sense.

### Bad separation: Same feature scattered
```
src/
  components/UserButton.tsx     # UI
  styles/UserButton.css         # Styles
  handlers/userHandlers.ts      # Logic
  state/userState.ts            # State
```

Same feature (user button) scattered. LoB better here.

## The Locality Test

**Question:** To understand this button, how many files must I read?

**SoC answer:** 4-6 files (component, style, handler, state, action, type)

**LoB answer:** 1 file (everything here)

**Grug prefers:** 1 file

## Tailwind CSS: Grug Approved

```typescript
// Tailwind: styles on the element
function Button({ onClick, children }) {
  return (
    <button
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
      onClick={onClick}
    >
      {children}
    </button>
  )
}
```

**Why grug like:**
- See styles on element
- No separate CSS file to check
- Change padding? Edit it right here
- Copy component, styles come with it

## The Scattering Problem

### Traditional approach
```
User clicks button
  → Go to component file (what's the handler?)
  → Go to handler file (what does it call?)
  → Go to action file (what does it do?)
  → Go to style file (what does it look like?)
```

### LoB approach
```
User clicks button
  → Look at button element
  → Everything right here
```

## Grug Rules for LoB

1. **Put code on the thing:** Button logic on button, not elsewhere
2. **Inline when possible:** Styles, handlers, small state
3. **One file per feature:** Not one file per "type" (handlers/styles/etc)
4. **Copy-paste friendly:** Should be able to copy component and use elsewhere
5. **Minimize jumping:** Reading code shouldn't require file navigation

## Balance

**Too much LoB:** 1000-line component file (bad)

**Too much SoC:** 10 files for simple button (bad)

**Grug balance:** One component, ~100-200 lines, everything visible

If component gets too big, split by feature (not by "type"):
- `UserProfile.tsx` (user profile feature, complete)
- `UserSettings.tsx` (user settings feature, complete)

Not:
- `UserStyles.css` (all user styles)
- `UserHandlers.ts` (all user handlers)

Feature separation good. Type separation often bad.

Grug say: code that changes together should live together.
