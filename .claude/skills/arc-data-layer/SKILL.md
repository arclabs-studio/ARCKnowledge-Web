---
name: arc-data-layer
description: |
  Data layer patterns for ARC Labs Studio: repository pattern, localStorage
  abstraction, API clients, DTOs with mapping functions, Result type, Netlify
  Forms integration. Use when "creating a repository", "accessing localStorage",
  "making an API call", "handling a form submission", "adding a data source",
  or any question about the Data layer.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Data Layer

## Instructions

### Repository Rules

1. **Repositories live in** `src/data/repositories/`
2. **Repositories are NEVER imported directly in `.tsx` files** — always through a hook
3. **Repositories abstract the storage mechanism** — callers don't know if data is in localStorage, an API, or a static file
4. **All operations that can fail return `Result<T>`**
5. **No console.log/error in production paths** — use `import.meta.env.DEV` guard

### localStorage Repository Pattern

```ts
// src/data/repositories/themeRepository.ts
import type { Theme } from '@domain/entities/Theme';
import { isTheme } from '@domain/entities/Theme';

const STORAGE_KEY = 'arc-theme';

const themeRepository = {
  get(): Theme {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      return isTheme(raw) ? raw : 'brand';
    } catch {
      return 'brand'; // SSR / private browsing fallback
    }
  },

  set(theme: Theme): void {
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[themeRepository] failed to persist theme:', error);
      }
    }
  },
};

export { themeRepository };
```

### API Repository Pattern (with Result<T>)

```ts
// src/data/repositories/userRepository.ts
import type { User } from '@domain/entities/User';
import type { Result } from '@domain/entities/Result';
import { userFromDTO, type UserDTO } from './dtos/UserDTO';

const BASE_URL = import.meta.env.VITE_API_URL;

const userRepository = {
  async getById(id: string): Promise<Result<User>> {
    try {
      const response = await fetch(`${BASE_URL}/users/${id}`, {
        headers: { 'Content-Type': 'application/json' },
      });

      if (!response.ok) {
        return { ok: false, error: `Failed to fetch user: ${response.status}` };
      }

      const dto = (await response.json()) as UserDTO;
      return { ok: true, data: userFromDTO(dto) };
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[userRepository] getById failed:', error);
      }
      return { ok: false, error: 'Network error. Please check your connection.' };
    }
  },
};

export { userRepository };
```

### DTO + Mapping Function Pattern

DTOs are the raw API response shape. Domain entities are the clean internal shape.
Never use DTOs in the Presentation or Domain layers — map at the repository boundary.

```ts
// src/data/repositories/dtos/UserDTO.ts
import type { User } from '@domain/entities/User';

// Raw API response shape — may differ from domain entity
export interface UserDTO {
  user_id: string;           // snake_case from API
  display_name: string;
  email_address: string;
  created_at: string;        // ISO string, not Date
}

// Mapping function: DTO → Domain entity
export function userFromDTO(dto: UserDTO): User {
  return {
    id: dto.user_id,
    name: dto.display_name,
    email: dto.email_address,
    createdAt: new Date(dto.created_at),
  };
}
```

### Netlify Forms Repository

```ts
// src/data/repositories/contactRepository.ts
//
// Netlify Forms integration — form submissions are handled by Netlify's
// built-in form processing when deployed. For local development, POST
// requests return 404 (expected). The HTML form in index.html must
// include data-netlify="true" and a hidden input with the form name.

import type { ContactFormData } from '@domain/entities/ContactFormData';
import type { Result } from '@domain/entities/Result';

const contactRepository = {
  async submit(data: ContactFormData): Promise<Result<void>> {
    try {
      const body = new URLSearchParams({
        'form-name': 'contact',
        name: data.name,
        email: data.email,
        message: data.message,
      });

      const response = await fetch('/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: body.toString(),
      });

      if (!response.ok && response.status !== 404) {
        return { ok: false, error: 'Failed to send message. Please try again.' };
      }

      return { ok: true, data: undefined };
    } catch (error) {
      if (import.meta.env.DEV) {
        console.error('[contactRepository] submit failed:', error);
      }
      return { ok: false, error: 'Network error. Please try again.' };
    }
  },
};

export { contactRepository };
```

### Static Data Repository

For static content (app descriptions, team members, services):

```ts
// src/data/repositories/appsRepository.ts
import type { AppEntity } from '@domain/entities/App';
import { APPS } from '@domain/entities/App';

// Static data repository — no async needed, wraps domain constants
const appsRepository = {
  getAll(): readonly AppEntity[] {
    return APPS;
  },

  getById(id: string): AppEntity | undefined {
    return APPS.find(app => app.id === id);
  },
};

export { appsRepository };
```

### Result Type (Domain Entity)

```ts
// src/domain/entities/Result.ts
export type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };
```

### Common Anti-Patterns

```ts
// BAD — importing repository directly in a component
// ContactSection.tsx
import { contactRepository } from '@data/repositories/contactRepository'; // ✗

// GOOD — repository through hook
// useContactForm.ts
import { contactRepository } from '@data/repositories/contactRepository'; // ✓

// BAD — unhandled async
const handleSubmit = async () => {
  await contactRepository.submit(data); // throws on failure, nothing catches
};

// GOOD — Result<T> forces handling both paths
const result = await contactRepository.submit(data);
if (!result.ok) {
  setError(result.error);
  return;
}
setStatus('success');

// BAD — console.log in production path
console.log('Submitted:', data);

// GOOD — dev-only logging
if (import.meta.env.DEV) {
  console.log('[contactRepository] submitted:', data);
}
```

## Further Reading

- `Layers/data.md` — full data layer documentation with all repository patterns
- `Architecture/error-handling.md` — Result type, async error handling
- `Architecture/typescript-patterns.md` — type guards at system boundaries
