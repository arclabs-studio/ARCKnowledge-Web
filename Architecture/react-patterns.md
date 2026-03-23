# React Patterns — ARC Labs Studio

Day-to-day React design decisions. These patterns guide every component and hook.

---

## Custom Hooks Are the Unit of Reuse

Extract logic to hooks, not components. A hook can be reused and tested in isolation; a component that bundles logic with JSX cannot.

```tsx
// BAD — logic buried in component, impossible to test or reuse
function ContactSection(): React.JSX.Element {
  const [status, setStatus] = useState<'idle' | 'submitting' | 'done'>('idle');
  const onSubmit = async (data: ContactFormData): Promise<void> => { ... };
  return <form onSubmit={...}>...</form>;
}

// GOOD — hook owns logic, component owns JSX
function ContactSection(): React.JSX.Element {
  const { status, onSubmit } = useContactForm();
  return <form onSubmit={onSubmit}>...</form>;
}
```

The hook `useContactForm` can be tested with `renderHook` independently. The component test only verifies that the JSX renders the correct elements given hook outputs.

---

## Composition Over Configuration

Use `children` and wrapper components instead of proliferating `variant` props.

```tsx
// BAD — component grows unboundedly with every new use case
<Card variant="featured" withBorder withShadow headerSlot={<Title />} />

// GOOD — compose at the call site
<Card>
  <CardHeader><Title /></CardHeader>
  <CardBody>...</CardBody>
</Card>
```

When a component needs a new variation, create a specialized wrapper — do not add a `variant` prop to the base component.

---

## State Colocation

**Keep state as close to where it is used as possible. Lift only when siblings must share it.**

```tsx
// BAD — modal open state lifted to parent when only one child uses it
function Parent(): React.JSX.Element {
  const [isOpen, setIsOpen] = useState(false);
  return <Child isOpen={isOpen} onOpen={() => setIsOpen(true)} />;
}

// GOOD — state lives where it is consumed
function Child(): React.JSX.Element {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <>
      {isOpen && <Modal />}
      <button onClick={() => setIsOpen(true)}>Open</button>
    </>
  );
}
```

Before lifting state, ask: "Do any siblings need this?" If no, keep it local.

---

## Context Rules

**Context is for truly global concerns: theme, auth, locale. It is not a prop-drilling shortcut.**

Use Context for:
- Theme (`useTheme`)
- Authenticated user identity
- Locale / i18n

Do NOT use Context for:
- Form state
- List filters or sort order
- Modal visibility
- Component-local async state

Prefer composition (children, render props) over Context for moderate sharing needs.

```tsx
// BAD — creating Context to avoid drilling one level
const FilterContext = createContext<string>('');

// GOOD — just pass the prop
<ProductList filter={filter} />
```

---

## Container/Presenter Split

**Logic in hook. JSX in component.** Maintain this separation rigorously.

```
useContactForm.ts   ← all state, validation, submit logic
ContactSection.tsx  ← JSX only, calls useContactForm()
```

A component that follows this pattern has:
- No `useState` (except for purely local UI state like hover/focus)
- No `useEffect`
- No `async` functions
- No direct repository or API calls

---

## useMemo / useCallback Rules

**Only use when referential stability is actually required.** Not as "optimisation by default."

Use `useCallback` when:
- The function is a dependency in another hook's dep array
- The function is passed as a prop to a `React.memo` component

Use `useMemo` when:
- The result is a dependency in another hook's dep array
- The computation is genuinely expensive (benchmark first — most are not)

```tsx
// BAD — wrapping everything in useCallback "just in case"
const handleClick = useCallback(() => setCount(c => c + 1), []); // pointless

// GOOD — only when it crosses a memo boundary
const sortedItems = useMemo(() => [...items].sort(compareFn), [items, compareFn]);
```

Do not wrap a function in `useCallback` just because it is "passed to a child." Wrap it only when the child is `React.memo` and the reference change would trigger a re-render.

---

## Avoid Derived State

**Never `useState` from props. Compute inline or use `useMemo`.**

```tsx
// BAD — derived state goes stale when props change
function Tag({ label }: { label: string }): React.JSX.Element {
  const [upper, setUpper] = useState(label.toUpperCase()); // stale after prop change
  ...
}

// GOOD — compute directly, always fresh
function Tag({ label }: { label: string }): React.JSX.Element {
  const upper = label.toUpperCase();
  ...
}
```

---

## Prop Drilling Limit

**Do not drill props more than 2 levels.** Reach for composition first, Context second.

```
Level 1: Parent → Child                     ✓ fine
Level 2: Parent → Child → GrandChild        ✓ acceptable
Level 3+: restructure composition or use Context
```

Composition fix: pass the rendered subtree as `children` rather than drilling data down and callbacks up.

---

## Key Rules

```
function onClick():  → name event handlers with "handle" prefix: handleClick, handleSubmit
useXxx():           → hooks always start with "use"
XxxComponent:       → PascalCase for all component names
xxx.module.css:     → CSS Module file named after the component
```

---

## Keys in Lists

Keys must be **stable, unique, and not index-based** when items can reorder or be removed.

```tsx
// BAD — index as key breaks animations and reconciliation
{items.map((item, index) => <Item key={index} {...item} />)}

// GOOD — stable ID from the data
{items.map(item => <Item key={item.id} {...item} />)}
```

---

## Avoid useEffect for Data Fetching

In React 19, `use()` and Suspense are the idiomatic patterns. `useEffect` data fetching creates waterfalls and races.

```tsx
// BAD — useEffect data fetching
function UserProfile({ id }: { id: string }): React.JSX.Element {
  const [user, setUser] = useState<User | null>(null);
  useEffect(() => {
    fetchUser(id).then(setUser);
  }, [id]);
  if (!user) return <Skeleton />;
  return <div>{user.name}</div>;
}

// GOOD — use() with Suspense (React 19)
function UserProfile({ id }: { id: string }): React.JSX.Element {
  const user = use(fetchUser(id));
  return <div>{user.name}</div>;
}
```

For synchronizing with external systems (DOM, WebSockets, subscriptions), `useEffect` is still appropriate.
