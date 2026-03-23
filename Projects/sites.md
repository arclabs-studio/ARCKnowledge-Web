# Single-Page Marketing Sites — ARC Labs Studio

Architecture decisions, structure, and constraints for SPA marketing sites like ARCLabsStudio-Web.

---

## What Is a Marketing Site

A **marketing site** is a single-page React app where:
- Content is mostly static (no user auth, no complex data fetching)
- SEO and performance are critical
- The primary interaction is a contact form and navigation
- Sections are sequential: Hero → Features → About → Contact

This is the simplest web project type. Use this structure for studio/portfolio/landing pages.

---

## Project Structure

```
project-root/
├── src/
│   ├── presentation/
│   │   ├── components/          # Shared UI building blocks
│   │   │   ├── Button/
│   │   │   ├── Header/
│   │   │   ├── Footer/
│   │   │   └── ThemeToggle/
│   │   ├── hooks/               # ViewModels and utilities
│   │   │   ├── useTheme.ts
│   │   │   ├── useActiveSection.ts
│   │   │   └── useScrollReveal.ts
│   │   ├── layouts/             # Page-level wrappers
│   │   │   └── MainLayout/
│   │   ├── sections/            # Page sections (Hero, About, etc.)
│   │   │   ├── HeroSection/
│   │   │   ├── AppsSection/
│   │   │   └── ContactSection/
│   │   └── styles/              # Global CSS (tokens, reset, typography)
│   │       ├── tokens.css
│   │       ├── reset.css
│   │       └── typography.css
│   ├── domain/
│   │   └── entities/            # Pure TS types, constants, validators
│   │       ├── Theme.ts
│   │       ├── Navigation.ts
│   │       └── ContactFormData.ts
│   ├── data/
│   │   └── repositories/        # Storage and API access
│   │       ├── themeRepository.ts
│   │       └── contactRepository.ts
│   ├── assets/
│   │   ├── images/
│   │   └── fonts/
│   ├── test/
│   │   └── setup.ts
│   └── main.tsx
├── e2e/
│   └── contact-form.spec.ts     # Playwright E2E for the contact form
├── public/
│   ├── favicon.ico
│   └── robots.txt
└── index.html                   # Theme flash prevention script
```

---

## App Shell Pattern

`App.tsx` is the single-page shell. It renders all sections sequentially inside `MainLayout`:

```tsx
// App.tsx
import { MainLayout } from '@presentation/layouts/MainLayout';
import { HeroSection } from '@presentation/sections/HeroSection';
import { AppsSection } from '@presentation/sections/AppsSection';
import { ContactSection } from '@presentation/sections/ContactSection';
import { useActiveSection } from '@presentation/hooks/useActiveSection';
import { useScrollReveal } from '@presentation/hooks/useScrollReveal';

function App(): React.JSX.Element {
  const { activeSection } = useActiveSection();
  useScrollReveal();

  return (
    <MainLayout activeSection={activeSection}>
      <HeroSection />
      <AppsSection />
      <ContactSection />
    </MainLayout>
  );
}

export { App };
```

---

## Section Pattern

Each section is a full-width block with a semantic `id` for anchor navigation:

```tsx
// HeroSection.tsx
import { SECTION_IDS } from '@domain/entities/Navigation';
import styles from './HeroSection.module.css';

function HeroSection(): React.JSX.Element {
  return (
    <section id={SECTION_IDS.Hero} className={styles.hero}>
      <div className={styles.content}>
        <h1 className={styles.headline}>...</h1>
        <p className={styles.tagline}>...</p>
      </div>
    </section>
  );
}

export { HeroSection };
```

Section IDs are defined as `as const` in `Navigation.ts` — never hardcoded in section components.

---

## When to Add a New Section

Sections are added in `App.tsx`. The process:

1. Define the section ID in `src/domain/entities/Navigation.ts`
2. Add to `NAV_LINKS` if the section should appear in navigation
3. Create the section directory with 4 files (`.tsx`, `.module.css`, `.test.tsx`, `index.ts`)
4. Import and render in `App.tsx` at the correct position
5. If the section has a contact form or data fetching, create the hook and repository first

Use `/new-page SectionName` to scaffold the 4 files automatically.

---

## Static Data

Marketing sites have mostly static content (app descriptions, team bios, service offerings). Keep static data in domain entities — not hardcoded in JSX:

```ts
// src/domain/entities/App.ts
export interface AppEntity {
  readonly id: string;
  readonly name: string;
  readonly tagline: string;
  readonly description: string;
  readonly iconUrl: string;
  readonly appStoreUrl: string;
}

export const APPS: readonly AppEntity[] = [
  {
    id: 'app-1',
    name: 'My App',
    tagline: 'Short tagline',
    description: 'Longer description',
    iconUrl: '/images/app-1-icon.png',
    appStoreUrl: 'https://apps.apple.com/...',
  },
] as const;
```

This makes the data testable and allows future migration to an API without changing components.

---

## Contact Form

Marketing sites use Netlify Forms for form submission:

- Add `data-netlify="true"` to the `<form>` element
- Add a hidden `<input type="hidden" name="form-name" value="contact" />`
- Add a static HTML form in `index.html` for Netlify's build-time detection
- Use `contactRepository.ts` to POST with `application/x-www-form-urlencoded` encoding

See `Layers/data.md` for the Netlify Forms repository implementation.

---

## SEO Checklist

For a marketing site, SEO is critical:

- [ ] `<title>` tag — specific and descriptive
- [ ] `<meta name="description">` — 150-160 characters, unique per page
- [ ] Open Graph tags: `og:title`, `og:description`, `og:image`, `og:url`
- [ ] Twitter Card tags
- [ ] `<link rel="canonical">` — prevent duplicate content
- [ ] `robots.txt` in `public/`
- [ ] `sitemap.xml` in `public/`
- [ ] Semantic HTML: `<header>`, `<main>`, `<footer>`, `<section>`, `<article>`
- [ ] `<h1>` exactly once per page
- [ ] All images have descriptive `alt` text
- [ ] Structured data (JSON-LD) for organization

---

## Performance Targets

Lighthouse scores for a marketing site:

| Category | Target |
|----------|--------|
| Performance | ≥ 90 |
| Accessibility | ≥ 90 (target 100) |
| Best Practices | ≥ 90 |
| SEO | ≥ 90 |

Use `make lighthouse` to audit before each release.

Core Web Vitals targets:
- **LCP** (Largest Contentful Paint) < 2.5s
- **CLS** (Cumulative Layout Shift) < 0.1
- **FID/INP** (Interaction to Next Paint) < 200ms

---

## Constraints (Marketing Sites)

- **No client-side routing** — single page, anchor navigation only
- **No global state library** (Redux, Zustand, Jotai) — React Context is sufficient
- **No server-side rendering** — Vite SPA, deployed to Netlify CDN
- **No `useEffect` for data fetching** — all data is static or form-submitted
- **Images from `public/`** — avoid base64 encoded images in CSS or JS

If any of these constraints become blockers, the project has grown beyond a marketing site and needs the `Projects/apps.md` architecture.
