# Domain Layer — ARC Labs Studio

The Domain layer is the heart of the application. It contains pure TypeScript — no React, no browser APIs, no external framework dependencies.

---

## What Belongs Here

```
src/domain/
└── entities/
    ├── Theme.ts              # Type + constants + type guard
    ├── Navigation.ts         # Nav links, section IDs, CTA config
    ├── ContactFormData.ts    # Form schema (Zod) + inferred type
    ├── App.ts                # App entity (portfolio items)
    └── Result.ts             # Generic Result<T> type
```

---

## Rules

1. **No React imports** — domain entities are pure TypeScript
2. **No browser APIs** — no `localStorage`, no `document`, no `window`
3. **No data layer imports** — entities do not know how they are stored
4. **No presentation layer imports** — entities do not know how they are rendered
5. **No side effects** — pure functions and type definitions only

---

## Entity Patterns

### Union Types + Type Guards

```ts
// domain/entities/Theme.ts
export type Theme = 'brand' | 'dark' | 'light';

export const THEMES = ['brand', 'dark', 'light'] as const;

export function isTheme(value: unknown): value is Theme {
  return value === 'brand' || value === 'dark' || value === 'light';
}
```

### As Const Constants

```ts
// domain/entities/Navigation.ts
export const SECTION_IDS = {
  Hero: 'hero',
  Services: 'services',
  Apps: 'apps',
  About: 'about',
  Contact: 'contact',
} as const;

export type SectionId = typeof SECTION_IDS[keyof typeof SECTION_IDS];

export interface NavLink {
  id: SectionId;
  label: string;
  href: string;
}

export const NAV_LINKS: readonly NavLink[] = [
  { id: SECTION_IDS.Hero, label: 'Home', href: '#hero' },
  { id: SECTION_IDS.Services, label: 'Services', href: '#services' },
  { id: SECTION_IDS.Apps, label: 'Apps', href: '#apps' },
  { id: SECTION_IDS.About, label: 'About', href: '#about' },
  { id: SECTION_IDS.Contact, label: 'Contact', href: '#contact' },
] as const;
```

### Zod Schemas for Validation

```ts
// domain/entities/ContactFormData.ts
import { z } from 'zod';

export const contactSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  message: z.string().min(10, 'Message must be at least 10 characters'),
});

export type ContactFormData = z.infer<typeof contactSchema>;
```

Zod schemas serve dual purpose: they define the type AND validate data at runtime. Use `z.infer` to derive the TypeScript type — never define the interface manually and the schema separately.

### Result Type

```ts
// domain/entities/Result.ts
export type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };
```

### Rich Entity Types

```ts
// domain/entities/App.ts
export interface App {
  readonly id: string;
  readonly name: string;
  readonly tagline: string;
  readonly description: string;
  readonly iconUrl: string;
  readonly appStoreUrl: string;
  readonly platform: 'ios' | 'macos' | 'web';
  readonly category: string;
}
```

Note: entity properties are `readonly` — entities are immutable value types.

---

## What Zod Schemas Replace

Before Zod, validation logic was scattered across components and hooks. With Zod:

| Old approach | Zod approach |
|---|---|
| Manual validation functions in hooks | `contactSchema.safeParse(data)` |
| Duplicated error message strings | Defined once in the schema |
| Separate TypeScript interface + validation | `z.infer<typeof schema>` generates the type |
| Validation in API layer | Schema is the source of truth, reusable everywhere |

---

## Domain Layer Anti-Patterns

```ts
// BAD — domain entity importing from React
import { useState } from 'react'; // ← never in domain

// BAD — domain entity accessing browser storage
export const storedTheme = localStorage.getItem('theme'); // ← never in domain

// BAD — domain schema importing from a specific UI library
import { Controller } from 'react-hook-form'; // ← never in domain
```
