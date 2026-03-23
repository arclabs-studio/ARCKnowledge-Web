---
name: arc-react-performance
description: |
  React performance optimization patterns for ARC Labs Studio: preventing
  unnecessary re-renders, bundle splitting, memoization, waterfall elimination,
  image optimization, Core Web Vitals. Use when "performance", "slow renders",
  "re-renders", "bundle size", "lazy loading", "Lighthouse score", "LCP", "CLS",
  "code splitting", or "React.memo".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - React Performance

## Instructions

### Core Web Vitals Targets

| Metric | Target | Measured by |
|--------|--------|-------------|
| LCP (Largest Contentful Paint) | < 2.5s | Time to render main content |
| CLS (Cumulative Layout Shift) | < 0.1 | Layout stability |
| INP (Interaction to Next Paint) | < 200ms | Response to user input |
| FID (First Input Delay) | < 100ms | Interactivity |

Run `make lighthouse` before each release to validate.

### Prevent Unnecessary Re-Renders

Components re-render when props or state change. Avoid creating new object/array references in render:

```tsx
// BAD — new object created every render, causes re-render
function Parent(): React.JSX.Element {
  return <Child config={{ size: 'large' }} />; // new object every render
}

// GOOD — stable reference
const CHILD_CONFIG = { size: 'large' } as const;

function Parent(): React.JSX.Element {
  return <Child config={CHILD_CONFIG} />;
}
```

### `React.memo` — When to Use

Only memoize when you can measure a performance problem. Not by default.

```tsx
// Use React.memo when:
// 1. Component renders often (in a list)
// 2. Re-render is expensive
// 3. Props change infrequently

const AppCard = React.memo(function AppCard({ name, tagline, iconUrl }: AppCardProps) {
  return (
    <div className={styles.card}>
      <img src={iconUrl} alt={`${name} app icon`} width={64} height={64} />
      <h3>{name}</h3>
      <p>{tagline}</p>
    </div>
  );
});
```

### `useMemo` / `useCallback` Rules

Only for referential stability — not as a default optimization.

```tsx
// GOOD — sorting is expensive, items changes infrequently
const sortedApps = useMemo(
  () => [...apps].sort((a, b) => a.name.localeCompare(b.name)),
  [apps],
);

// GOOD — passed to React.memo child
const handleSelect = useCallback((id: string): void => {
  setSelectedId(id);
}, []);

// BAD — pointless, handler doesn't cross memo boundary
const handleClick = useCallback((): void => {
  setCount(c => c + 1);
}, []); // no memo benefit
```

### Code Splitting — Route Level

Split large routes into separate chunks. For marketing sites with few routes, this rarely matters. For full apps:

```tsx
import { lazy, Suspense } from 'react';

// Each route loaded on demand
const DashboardPage = lazy(() => import('./features/dashboard/DashboardPage'));
const SettingsPage = lazy(() => import('./features/settings/SettingsPage'));

// Suspense at route level
<Route
  path="/dashboard"
  element={
    <Suspense fallback={<PageSkeleton />}>
      <DashboardPage />
    </Suspense>
  }
/>
```

### Code Splitting — Component Level

For large components not needed on initial load (modals, heavy visualisations):

```tsx
// Load only when user opens the modal
const DataVisualization = lazy(() => import('./DataVisualization'));

function Dashboard(): React.JSX.Element {
  const [showViz, setShowViz] = useState(false);
  return (
    <>
      <button onClick={() => setShowViz(true)}>Show chart</button>
      {showViz && (
        <Suspense fallback={<ChartSkeleton />}>
          <DataVisualization />
        </Suspense>
      )}
    </>
  );
}
```

### Eliminate Request Waterfalls

Waterfall: Component renders → fetches data → renders child → child fetches data.

```tsx
// BAD — sequential fetches (waterfall)
function Dashboard(): React.JSX.Element {
  const { user } = useUser();               // fetch 1
  return user ? <Stats userId={user.id} /> : null;
}

function Stats({ userId }: { userId: string }): React.JSX.Element {
  const { stats } = useStats(userId);       // fetch 2 — waits for fetch 1
  return ...;
}

// GOOD — parallel fetches
function Dashboard(): React.JSX.Element {
  const { user } = useUser();               // fetch 1 in parallel
  const { stats } = useStats();             // fetch 2 in parallel
  ...
}

// GOOD — TanStack Query parallel queries
function useDashboardData() {
  const userQuery = useQuery({ queryKey: ['user'], queryFn: fetchUser });
  const statsQuery = useQuery({ queryKey: ['stats'], queryFn: fetchStats });
  return { user: userQuery.data, stats: statsQuery.data };
}
```

### Image Optimization

Always specify dimensions to prevent layout shift (CLS):

```tsx
{/* GOOD — width + height prevent CLS */}
<img
  src="/images/hero.jpg"
  srcSet="/images/hero@2x.jpg 2x"
  alt="ARC Labs Studio hero"
  width={1200}
  height={600}
  loading="lazy"           // below fold images
/>

{/* Hero image — eager load (above fold) */}
<img src="/images/hero.jpg" alt="..." width={1200} height={600} loading="eager" />
```

### Bundle Size

```bash
# Analyse bundle
npx vite-bundle-visualizer

# Check a package before adding
# Visit https://bundlephobia.com
```

Common size traps:
- `moment.js` (300kB) → use `date-fns` (tree-shakeable) or `Intl`
- `lodash` (70kB) → use native array methods or specific imports
- Icon libraries (full import) → import icons individually

```ts
// BAD — imports entire icon library
import * as Icons from 'react-icons/fa';

// GOOD — tree-shakeable, only imports what's used
import { FaGithub, FaApple } from 'react-icons/fa';
```

### List Rendering Keys

Keys must be stable, unique identifiers — not array indexes:

```tsx
// BAD — index as key causes re-render issues on list changes
{apps.map((app, index) => <AppCard key={index} {...app} />)}

// GOOD — stable unique ID
{apps.map(app => <AppCard key={app.id} {...app} />)}
```

### State Structure

Avoid state updates that trigger cascading re-renders:

```tsx
// BAD — updating object state causes full re-render of anything using it
const [formData, setFormData] = useState({ name: '', email: '' });
setFormData(prev => ({ ...prev, name: 'John' })); // fine but spreads

// BETTER — separate state for independent values
const [name, setName] = useState('');
const [email, setEmail] = useState('');

// BEST for forms — use react-hook-form (uncontrolled, minimal re-renders)
```

### React Compiler (Vite 7 + React 19)

The React Compiler automatically memoizes components and hooks. When enabled via `babel-plugin-react-compiler`, you can remove manual `useMemo`/`useCallback` in many cases. Let the compiler handle it:

```ts
// vite.config.ts
react({
  babel: {
    plugins: [['babel-plugin-react-compiler']],
  },
})
```

Don't add `useMemo`/`useCallback` speculatively if React Compiler is enabled — verify it's needed first.

## Further Reading

- `Tools/vite.md` — code splitting, bundle analysis, lazy loading
- `Quality/code-review.md` — Performance domain (H) in the review checklist
