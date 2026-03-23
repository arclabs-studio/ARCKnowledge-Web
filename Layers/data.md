# Data Layer — ARC Labs Studio

The Data layer handles all external I/O: localStorage, API calls, cookies, IndexedDB, session storage.

---

## What Belongs Here

```
src/data/
└── repositories/
    ├── themeRepository.ts      # localStorage persistence
    ├── contactRepository.ts    # API client for contact form
    └── appsRepository.ts       # Static data / GitHub API
```

---

## Repository Pattern

Repositories abstract the storage mechanism. The Presentation layer (hooks) never knows whether data comes from localStorage, an API, memory, or a future database.

### Rules

1. **One repository per data source** — don't mix localStorage and API calls in the same file
2. **Return domain entities, not raw data** — repositories return `Theme`, not `string`
3. **Validate external data** — API responses are `unknown` until validated
4. **Handle errors locally** — return `Result<T>` for predictable failures, throw for unexpected
5. **Never import from Presentation** — data layer flows toward Domain only

---

## localStorage Repository

```ts
// data/repositories/themeRepository.ts
import { isTheme, type Theme } from '@domain/entities/Theme';

const STORAGE_KEY = 'arc-theme';

export const themeRepository = {
  get(): Theme {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return isTheme(raw) ? raw : 'brand';
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[themeRepository] failed to read:', error);
      }
      return 'brand';
    }
  },

  set(theme: Theme): void {
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[themeRepository] failed to write:', error);
      }
    }
  },

  clear(): void {
    localStorage.removeItem(STORAGE_KEY);
  },
} as const;
```

---

## API Repository with Result<T>

```ts
// data/repositories/contactRepository.ts
import { type ContactFormData } from '@domain/entities/ContactFormData';
import { type Result } from '@domain/entities/Result';

export const contactRepository = {
  async submit(data: ContactFormData): Promise<Result<void>> {
    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        const body = await response.json().catch(() => ({})) as Record<string, unknown>;
        const message = typeof body.message === 'string'
          ? body.message
          : `Server error: ${response.status}`;
        return { ok: false, error: message };
      }

      return { ok: true, data: undefined };
    } catch {
      return { ok: false, error: 'Network error. Please check your connection.' };
    }
  },
} as const;
```

---

## DTOs (Data Transfer Objects)

DTOs are the raw shapes returned by external APIs — before mapping to domain entities. Keep them close to the API they describe.

```ts
// data/repositories/appsRepository.ts
import { type App } from '@domain/entities/App';

// Raw GitHub API response shape
interface GitHubRepoDTO {
  id: number;
  name: string;
  description: string | null;
  html_url: string;
  stargazers_count: number;
  language: string | null;
}

// Maps DTO → Domain entity
function mapToApp(dto: GitHubRepoDTO): App {
  return {
    id: String(dto.id),
    name: dto.name,
    tagline: dto.description ?? 'No description',
    appStoreUrl: dto.html_url,
    // ... map remaining fields
  };
}

export const appsRepository = {
  async getAll(): Promise<App[]> {
    const response = await fetch('https://api.github.com/users/arclabs-studio/repos');
    if (!response.ok) throw new Error(`GitHub API error: ${response.status}`);
    const dtos = await response.json() as GitHubRepoDTO[];
    return dtos.map(mapToApp);
  },
} as const;
```

---

## Netlify Forms Integration

For Netlify form handling (no API server needed):

```ts
// data/repositories/contactRepository.ts (Netlify variant)
export const contactRepository = {
  async submit(data: ContactFormData): Promise<Result<void>> {
    try {
      const body = new URLSearchParams({
        'form-name': 'contact',
        ...Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
      });

      const response = await fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString(),
      });

      if (!response.ok) {
        return { ok: false, error: `Submission failed: ${response.status}` };
      }

      return { ok: true, data: undefined };
    } catch {
      return { ok: false, error: 'Network error. Please try again.' };
    }
  },
} as const;
```

---

## Static Data Repositories

For data that is embedded in the app (not fetched from an API):

```ts
// data/repositories/appsRepository.ts (static variant)
import { type App } from '@domain/entities/App';

const APPS_DATA: readonly App[] = [
  {
    id: 'app-1',
    name: 'MyApp',
    tagline: 'A delightful iOS app',
    // ...
  },
] as const;

export const appsRepository = {
  getAll(): readonly App[] {
    return APPS_DATA;
  },

  getById(id: string): App | undefined {
    return APPS_DATA.find(app => app.id === id);
  },
} as const;
```

---

## Common Anti-Patterns

```ts
// BAD — component directly calls fetch
function ContactSection(): React.JSX.Element {
  const handleSubmit = async () => {
    await fetch('/api/contact', { ... }); // ← direct API call in component
  };
}

// BAD — repository returns raw fetch response
async function submit(): Promise<Response> {
  return fetch('/api/contact', { ... }); // ← caller has to know HTTP details
}

// BAD — no validation of external data
const dto = await response.json() as MyType; // ← trusting external data shape
```
