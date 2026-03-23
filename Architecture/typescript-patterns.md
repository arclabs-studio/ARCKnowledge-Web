# TypeScript Patterns — ARC Labs Studio

Patterns that prevent bugs and improve code generation quality.

---

## Discriminated Unions Over Boolean Flags

Model mutually exclusive states with a discriminated union, not boolean combinations.

```ts
// BAD — 4 booleans = 16 possible states, most invalid
interface FetchState {
  isLoading: boolean;
  isError: boolean;
  isSuccess: boolean;
  data?: ContactFormData;
}

// GOOD — exactly 4 valid states
type FetchState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'error'; message: string }
  | { status: 'success'; data: ContactFormData };
```

Discriminated unions make invalid states unrepresentable. The type system prevents bugs like "loading AND error at the same time."

---

## Exhaustive Checks with `never`

Use `never` as a compiler-enforced exhaustiveness guard in switch/if-else chains.

```ts
function getLabel(status: FetchState['status']): string {
  switch (status) {
    case 'idle': return 'Ready';
    case 'loading': return 'Sending…';
    case 'error': return 'Failed';
    case 'success': return 'Sent!';
    default: {
      const _exhaustive: never = status; // compile error if a new case is added but not handled
      return _exhaustive;
    }
  }
}
```

When a new status is added to the union, this function will fail to compile until the new case is handled.

---

## `type` vs `interface`

- **`interface`** — object shapes that components or hooks expose as their public contract
- **`type`** — unions, intersections, mapped types, conditional types, `as const` derivations

```ts
// interface for component props and hook return shapes
interface ThemeToggleProps {
  theme: Theme;
  onThemeChange: (theme: Theme) => void;
}

interface UseThemeResult {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

// type for unions and computed types
type Theme = 'brand' | 'dark' | 'light';
type PartialThemeToggleProps = Partial<ThemeToggleProps>;
type ThemeKeys = keyof typeof THEMES_MAP;
```

---

## Avoid `as` Assertions

`as` silences the compiler without fixing the type gap. Treat every `as` as a design smell that must be justified.

```ts
// BAD — hides a real type problem
const theme = localStorage.getItem('theme') as Theme;

// GOOD — validate at the boundary with a type guard
function isTheme(value: unknown): value is Theme {
  return value === 'brand' || value === 'dark' || value === 'light';
}
const raw = localStorage.getItem('theme');
const theme: Theme = isTheme(raw) ? raw : 'brand';
```

The only acceptable `as` uses:
- `as const` (this is not an assertion, it narrows literal types)
- `as unknown as T` in test double factories where the shape is intentionally partial

---

## No `enum` — Use `as const`

`enum` compiles to runtime objects with surprising behavior (numeric bidirectional lookup, tree-shaking issues). Use `as const` + `typeof` instead.

```ts
// BAD — enum has runtime overhead and surprising behavior
enum SectionId {
  Hero = 'hero',
  About = 'about',
}

// GOOD — as const is tree-shakeable and produces exact literal types
const SECTION_IDS = {
  Hero: 'hero',
  About: 'about',
} as const;

type SectionId = typeof SECTION_IDS[keyof typeof SECTION_IDS]; // 'hero' | 'about'
```

For a list of string values:
```ts
const THEMES = ['brand', 'dark', 'light'] as const;
type Theme = typeof THEMES[number]; // 'brand' | 'dark' | 'light'
```

---

## Utility Types

Derive prop types from domain entities rather than duplicating shapes.

```ts
// Domain entity
interface App {
  id: string;
  name: string;
  tagline: string;
  iconUrl: string;
  appStoreUrl: string;
  description: string;
}

// Component only needs a subset — derive it, don't duplicate
type AppCardProps = Pick<App, 'name' | 'tagline' | 'iconUrl'>;

// Use Partial only at call sites (update payloads), never in type definitions
function updateApp(id: string, patch: Partial<App>): void { ... }
```

Common utility types:
- `Pick<T, K>` — extract specific keys
- `Omit<T, K>` — exclude specific keys
- `Partial<T>` — all keys optional (use at call sites only)
- `Required<T>` — all keys required
- `Readonly<T>` — all keys readonly (good for domain entities)
- `Record<K, V>` — typed object with known key shape
- `ReturnType<typeof fn>` — derive type from a function's return value

---

## Constrain Generics

Always constrain generics. Unconstrained `T` is rarely correct and produces poor error messages.

```ts
// BAD — T could be anything; compiler can't help
function getFirst<T>(items: T[]): T | undefined {
  return items[0];
}

// GOOD — constrained to objects with an id
function findById<T extends { id: string }>(items: T[], id: string): T | undefined {
  return items.find(item => item.id === id);
}
```

---

## Explicit Return Types

Required on all functions (ESLint enforces `@typescript-eslint/explicit-function-return-type`). Return types document intent and catch accidental `undefined` returns.

```ts
// BAD — implicit return type
const getTheme = () => localStorage.getItem('theme') ?? 'brand';

// GOOD — explicit return type
const getTheme = (): Theme => {
  const raw = localStorage.getItem('theme');
  return isTheme(raw) ? raw : 'brand';
};
```

React components always return `React.JSX.Element` or `React.JSX.Element | null`:

```tsx
// GOOD
function Button({ label }: ButtonProps): React.JSX.Element {
  return <button className={styles.button}>{label}</button>;
}

// GOOD — explicit null return
function ConditionalBanner({ show }: { show: boolean }): React.JSX.Element | null {
  if (!show) return null;
  return <div className={styles.banner}>...</div>;
}
```

---

## Type Guards at System Boundaries

Validate external data at every boundary: localStorage, API responses, URL params, user input.

```ts
// When receiving data from an API
interface ApiResponse {
  user: unknown; // unknown, not any
}

function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value &&
    typeof (value as Record<string, unknown>).id === 'string'
  );
}

const { user } = await fetchUser(id);
if (!isUser(user)) {
  throw new Error('[fetchUser] unexpected response shape');
}
// user is now User
```

For complex shapes, prefer Zod schemas which generate both types and validators:

```ts
import { z } from 'zod';

const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
});

type User = z.infer<typeof userSchema>;

// At the boundary:
const result = userSchema.safeParse(rawData);
if (!result.success) {
  throw new Error(`[fetchUser] invalid shape: ${result.error.message}`);
}
const user = result.data; // User
```

---

## Quick Reference

| Pattern | Rule |
|---------|------|
| States | Discriminated union, not boolean flags |
| Exhaustive switch | Add `never` default case |
| Objects/contracts | `interface` |
| Unions/computed | `type` |
| Casting | Never `as` — write a type guard instead |
| Enums | Never — use `as const` |
| Prop types | `Pick<Entity, ...>` — don't duplicate |
| Return types | Always explicit |
| External data | Validate with Zod or type guard |
