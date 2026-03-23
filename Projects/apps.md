# Full Web Applications — ARC Labs Studio

Architecture decisions, structure, and constraints for full web apps (SaaS, dashboards, tools).

---

## What Is a Full Web App

A **full web app** is a React SPA where:
- Users authenticate and have persistent accounts
- Data is fetched from and written to a real API
- Multiple routes/pages exist (dashboard, settings, detail views)
- State is more complex than a landing page

Examples: SaaS dashboard, analytics tool, admin panel, productivity app.

---

## When to Use This Pattern

Switch from `Projects/sites.md` to `Projects/apps.md` when:
- The project needs client-side routing
- The project has user authentication
- Sections have grown beyond 3 components each
- Multiple sections share logic or data

---

## Project Structure (Feature-Based)

```
src/
├── presentation/
│   ├── features/                    # Feature-scoped components + hooks
│   │   ├── auth/
│   │   │   ├── LoginPage.tsx
│   │   │   ├── LoginPage.module.css
│   │   │   ├── LoginPage.test.tsx
│   │   │   ├── LoginForm.tsx
│   │   │   ├── LoginForm.module.css
│   │   │   ├── LoginForm.test.tsx
│   │   │   ├── useLogin.ts
│   │   │   └── index.ts
│   │   ├── dashboard/
│   │   │   ├── DashboardPage.tsx
│   │   │   ├── DashboardPage.module.css
│   │   │   ├── DashboardPage.test.tsx
│   │   │   ├── MetricsCard.tsx
│   │   │   ├── MetricsCard.module.css
│   │   │   ├── MetricsCard.test.tsx
│   │   │   ├── useMetrics.ts
│   │   │   └── index.ts
│   │   └── settings/
│   │       └── ...
│   ├── shared/
│   │   ├── components/              # Truly shared UI primitives
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   ├── Modal/
│   │   │   └── LoadingSpinner/
│   │   └── hooks/
│   │       ├── useTheme.ts          # Global concern
│   │       ├── useAuth.ts           # Global concern
│   │       └── useScrollReveal.ts
│   ├── layouts/
│   │   ├── AppLayout/               # Authenticated app shell
│   │   └── AuthLayout/              # Login/signup pages
│   └── styles/
│       ├── tokens.css
│       ├── reset.css
│       └── typography.css
├── domain/
│   └── entities/
│       ├── User.ts
│       ├── AuthSession.ts
│       └── Metrics.ts
├── data/
│   └── repositories/
│       ├── authRepository.ts
│       ├── metricsRepository.ts
│       └── userRepository.ts
├── assets/
└── main.tsx
```

---

## Routing

Use React Router v7 for client-side routing:

```tsx
// src/main.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthLayout } from '@presentation/layouts/AuthLayout';
import { AppLayout } from '@presentation/layouts/AppLayout';

function App(): React.JSX.Element {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AuthLayout />}>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/signup" element={<SignupPage />} />
        </Route>
        <Route element={<AppLayout />}>
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/settings" element={<SettingsPage />} />
        </Route>
        <Route path="/" element={<Navigate to="/dashboard" />} />
      </Routes>
    </BrowserRouter>
  );
}
```

---

## Authentication Pattern

Auth state lives in a Context + hook pair (global concern):

```ts
// src/domain/entities/AuthSession.ts
export interface AuthSession {
  readonly userId: string;
  readonly email: string;
  readonly accessToken: string;
  readonly expiresAt: Date;
}

export type AuthState =
  | { status: 'loading' }
  | { status: 'authenticated'; session: AuthSession }
  | { status: 'unauthenticated' };
```

```ts
// src/presentation/shared/hooks/useAuth.ts
import { use } from 'react';
import { AuthContext } from '../contexts/AuthContext';

function useAuth(): AuthState {
  const context = use(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

export { useAuth };
```

**Rules**:
- Auth Context is a global concern — lives in `shared/`, not in a feature
- Never store tokens in `localStorage` — use `httpOnly` cookies or secure session storage
- Redirect to `/login` in the `AppLayout` if `status === 'unauthenticated'`

---

## Data Fetching

For full apps, use [TanStack Query](https://tanstack.com/query) for server state:

```ts
// src/presentation/features/dashboard/useMetrics.ts
import { useQuery } from '@tanstack/react-query';
import { metricsRepository } from '@data/repositories/metricsRepository';
import type { MetricsData } from '@domain/entities/Metrics';

interface UseMetricsResult {
  metrics: MetricsData | undefined;
  isLoading: boolean;
  error: string | null;
}

function useMetrics(): UseMetricsResult {
  const { data, isLoading, error } = useQuery({
    queryKey: ['metrics'],
    queryFn: () => metricsRepository.getAll(),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  return {
    metrics: data,
    isLoading,
    error: error ? 'Failed to load metrics' : null,
  };
}

export { useMetrics };
```

**Rules**:
- TanStack Query manages server state (cache, refetch, loading, error)
- React state manages UI state (modal open, selected tab)
- Don't duplicate server state in `useState` — it goes stale

---

## Forms

Use `react-hook-form` + `zod` for all forms:

```ts
// src/domain/entities/User.ts
import { z } from 'zod';

export const updateProfileSchema = z.object({
  displayName: z.string().min(1, 'Display name is required').max(50),
  email: z.string().email('Invalid email address'),
});

export type UpdateProfileData = z.infer<typeof updateProfileSchema>;
```

```ts
// src/presentation/features/settings/useUpdateProfile.ts
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { updateProfileSchema, type UpdateProfileData } from '@domain/entities/User';

function useUpdateProfile() {
  return useForm<UpdateProfileData>({
    resolver: zodResolver(updateProfileSchema),
    defaultValues: { displayName: '', email: '' },
  });
}

export { useUpdateProfile };
```

---

## Global State

Avoid global state libraries until genuinely needed. Order of preference:

1. **Local state** — `useState` in component or hook (most cases)
2. **Context** — for truly global concerns (theme, auth, locale)
3. **TanStack Query** — for server state (already included)
4. **Zustand** — for complex client-side state only if Context is insufficient

Never use Redux in a new project. If maintaining a Redux codebase, migrate incrementally.

---

## Performance Considerations

For full apps (unlike marketing sites), code splitting is essential:

```tsx
import { lazy, Suspense } from 'react';

// Each route is a separate chunk
const DashboardPage = lazy(() => import('./features/dashboard/DashboardPage'));
const SettingsPage = lazy(() => import('./features/settings/SettingsPage'));

// Route-level suspense boundary
<Route
  path="/dashboard"
  element={
    <Suspense fallback={<PageSkeleton />}>
      <DashboardPage />
    </Suspense>
  }
/>
```

---

## When Marketing Site Patterns Still Apply

Even in a full app, these marketing site rules remain:
- CSS Modules only — no Tailwind, no inline styles
- Design tokens — no hardcoded values
- Mobile-first responsive
- WCAG 2.2 AA accessibility
- Conventional Commits + branch naming
- Clean Architecture layers (Presentation → Domain ← Data)

The difference is structural scope, not code quality standards.
