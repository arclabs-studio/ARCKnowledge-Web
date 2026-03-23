# Project Structure — ARC Labs Studio

How to organize files and directories in ARC Labs web projects.

---

## Single-Page Application (Marketing Site)

For `ARCLabsStudio-Web` and similar single-page sites:

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
│   ├── assets/                  # Static files (images, fonts, icons)
│   │   ├── images/
│   │   └── fonts/
│   ├── test/
│   │   └── setup.ts             # @testing-library/jest-dom
│   └── main.tsx                 # Entry point
├── e2e/                         # Playwright E2E tests
│   └── contact-form.spec.ts
├── public/                      # Files served as-is (favicon, robots.txt)
├── .claude/                     # Claude Code configuration
│   ├── skills/                  # Symlinked from ARCKnowledge-Web
│   └── agents/                  # Symlinked from ARCKnowledge-Web
├── .github/workflows/           # CI/CD
├── vite.config.ts
├── tsconfig.app.json
├── eslint.config.js
├── CLAUDE.md
└── package.json
```

---

## Feature-Based Organization (For Larger Apps)

When sections grow into multiple components, organize by feature rather than by type:

```
src/presentation/
├── features/
│   ├── contact/
│   │   ├── ContactSection.tsx
│   │   ├── ContactSection.module.css
│   │   ├── ContactSection.test.tsx
│   │   ├── ContactForm.tsx
│   │   ├── ContactForm.module.css
│   │   ├── ContactForm.test.tsx
│   │   └── useContactForm.ts       # Hook lives with the feature
│   └── apps/
│       ├── AppsSection.tsx
│       ├── AppCard.tsx
│       └── useApps.ts
└── shared/
    ├── components/                 # Truly shared UI primitives
    │   ├── Button/
    │   └── LoadingSpinner/
    └── hooks/
        ├── useTheme.ts             # Global concern — goes in shared
        └── useScrollReveal.ts
```

Switch to feature-based organization when:
- A "section" has more than 3 components
- Multiple sections share logic with each other
- You're building a full web app (not a marketing site)

---

## Naming Conventions

| File type | Naming | Example |
|-----------|--------|---------|
| React component | PascalCase + `.tsx` | `AppCard.tsx` |
| CSS Module | PascalCase + `.module.css` | `AppCard.module.css` |
| Test file | Same as component + `.test.tsx` | `AppCard.test.tsx` |
| Barrel export | `index.ts` | `index.ts` |
| Custom hook | camelCase + `.ts` | `useTheme.ts` |
| Repository | camelCase + `Repository.ts` | `themeRepository.ts` |
| Domain entity | PascalCase + `.ts` | `Theme.ts`, `Navigation.ts` |
| E2E test | kebab-case + `.spec.ts` | `contact-form.spec.ts` |
| Global CSS | kebab-case + `.css` | `design-tokens.css`, `reset.css` |

---

## What Belongs Where

| Item | Location |
|------|---------|
| React components | `src/presentation/components/` or `src/presentation/sections/` |
| Custom hooks (ViewModels) | `src/presentation/hooks/` |
| Design tokens, reset, typography | `src/presentation/styles/` |
| TypeScript types, constants, Zod schemas | `src/domain/entities/` |
| localStorage, API calls | `src/data/repositories/` |
| Static assets (images, fonts) | `src/assets/` |
| Files served verbatim (favicon, robots.txt) | `public/` |
| Unit + integration tests | Co-located with components |
| E2E tests | `e2e/` directory |
| Vitest setup | `src/test/setup.ts` |
