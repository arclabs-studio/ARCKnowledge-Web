# SOLID Principles — ARC Labs Studio

SOLID adapted for React + TypeScript functional paradigm. Not classical OOP.

---

## S — Single Responsibility

**One component renders one thing. One hook manages one concern.**

Red flag: "And" in a name (`HeaderAndNav`, `fetchAndTransform`, `useDataAndSubmit`).

```tsx
// BAD — fetches data AND renders a list AND handles empty state
function UserList(): React.JSX.Element {
  const [users, setUsers] = useState([]);
  useEffect(() => { fetch('/users').then(...) }, []);
  if (!users.length) return <Empty />;
  return <ul>{users.map(u => <li>{u.name}</li>)}</ul>;
}

// GOOD — hook owns data, component owns render
function UserList(): React.JSX.Element {
  const { users, isEmpty } = useUsers();
  if (isEmpty) return <Empty />;
  return <ul>{users.map(u => <UserItem key={u.id} user={u} />)}</ul>;
}
```

**Test for SRP**: Can you describe what this function/component does in a single sentence without using "and"?

---

## O — Open/Closed

**Extend via props, composition, or children. Never branch into existing components.**

Adding `if (variant === 'new')` to an existing component is an open/closed violation.

```tsx
// BAD — modifying existing component to add a new case
function Card({ variant }: { variant: 'default' | 'featured' | 'compact' }): React.JSX.Element {
  if (variant === 'compact') return <div className={styles.compact}>...</div>;
  if (variant === 'featured') return <div className={styles.featured}>...</div>;
  return <div className={styles.card}>...</div>;
}

// GOOD — compose from a base
function Card({ children, className }: CardProps): React.JSX.Element {
  return <div className={clsx(styles.card, className)}>{children}</div>;
}

function FeaturedCard({ children }: { children: React.ReactNode }): React.JSX.Element {
  return <Card className={styles.featured}>{children}</Card>;
}
```

**How to add new behavior**: Create a new component that wraps the existing one, rather than adding conditional branches to the existing one.

---

## L — Liskov Substitution

**Components sharing a props interface must be interchangeable. Never narrow a contract in a specialisation.**

```tsx
// BAD — CompactButton removes an onClick that Button accepts
interface ButtonProps { label: string; onClick: () => void; }
interface CompactButtonProps { label: string; } // onClick removed — violates LSP

// GOOD — specialisation only adds, never removes
interface ButtonProps { label: string; onClick: () => void; }
interface IconButtonProps extends ButtonProps { icon: React.ReactNode; }
```

**In practice**: If you have `Button`, `PrimaryButton`, and `DestructiveButton`, they must all accept the same base props. A `PrimaryButton` that disables `onClick` is a Liskov violation.

---

## I — Interface Segregation

**Split large prop interfaces. Pass only what the component needs. No god props.**

```tsx
// BAD — component receives an entire entity when it only needs two fields
function AppCard({ app }: { app: App }): React.JSX.Element {
  return <div>{app.name} — {app.tagline}</div>; // uses 2 of 10 fields
}

// GOOD — extract the slice the component actually uses
interface AppCardProps {
  name: string;
  tagline: string;
}

function AppCard({ name, tagline }: AppCardProps): React.JSX.Element {
  return <div>{name} — {tagline}</div>;
}
```

Use `Pick<Entity, 'field1' | 'field2'>` when the component is a direct view of a domain entity:

```ts
type AppCardProps = Pick<App, 'name' | 'tagline' | 'iconUrl'>;
```

**Large prop interfaces** (more than 5-6 props) are usually a sign that the component has too many responsibilities. Split the component first, then the interface naturally becomes smaller.

---

## D — Dependency Inversion

**Components depend on abstractions (props/hook interfaces), not concretions. Never import repositories directly in components.**

```tsx
// BAD — component is coupled to a concrete data source
import { themeRepository } from '@data/repositories/themeRepository';

function ThemeToggle(): React.JSX.Element {
  const theme = themeRepository.get(); // tightly coupled to localStorage
  ...
}

// GOOD — depend on the hook abstraction
import { useTheme } from '@presentation/hooks/useTheme';

function ThemeToggle(): React.JSX.Element {
  const { theme, setTheme } = useTheme(); // implementation hidden behind hook
  ...
}
```

**The hook is the abstraction layer.** Components never know whether data comes from localStorage, an API, a context, or in-memory state. That decision lives in the hook (and ultimately the Data layer).

**For testing**: Dependency inversion via hooks means test can use `vi.mock` at the hook level, not at the repository level. You mock the interface, not the implementation.

```tsx
// Test mocks the hook interface, not the storage layer
vi.mock('@presentation/hooks/useTheme', () => ({
  useTheme: () => ({ theme: 'dark', setTheme: vi.fn() }),
}));
```

---

## SOLID Quick Reference

| Principle | Web Translation | Red Flag |
|-----------|----------------|----------|
| **S** — Single Responsibility | One component renders one thing; one hook manages one concern | "And" in the name |
| **O** — Open/Closed | Extend via composition; never add `variant` branches to existing components | `if (variant === 'x')` in an existing component |
| **L** — Liskov Substitution | Specialized components must accept all base props | A sub-component that removes a prop from its parent interface |
| **I** — Interface Segregation | Pass only what the component needs; no god props | A component receiving a full entity when it uses 2 fields |
| **D** — Dependency Inversion | Components depend on hooks, not repositories or API clients | Direct repository import in a `.tsx` file |
