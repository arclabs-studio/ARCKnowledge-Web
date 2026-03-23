---
name: arc-web-stack
description: |
  ARC Labs Studio web stack decisions, constraints, and rationale. Use when
  "choosing a library", "adding a dependency", "stack decisions", "why are
  we using X", "can we use Tailwind", "can we use Next.js", "should I use
  Redux", or any question about what tooling is approved for ARC Labs projects.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Web Stack

## Instructions

### Approved Stack

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| Language | TypeScript | 5.9+ | Strict mode, explicit types, no `any` |
| UI | React | 19 | React Compiler, `use()` hook, concurrent features |
| Build | Vite | 7 | Fast HMR, native ESM, excellent plugin ecosystem |
| Styling | CSS Modules | — | Scoped styles, no runtime, works with design tokens |
| Design tokens | CSS Custom Properties | — | Themeable, no JS needed, browser-native |
| Forms | react-hook-form + zod | latest | Uncontrolled forms, Zod schema reuse across layers |
| Testing | Vitest + RTL | latest | Same pipeline as Vite, fast, modern |
| E2E testing | Playwright | latest | Cross-browser, reliable, Lighthouse integration |
| Deployment | Netlify | — | Zero-config from GitHub, Forms, edge functions |
| Dead code | Knip | latest | Finds unused exports, deps, files |
| Linting | ESLint 9.x flat config | 9.x | Type-checked rules, layer boundary enforcement |
| Formatting | Prettier | latest | Opinionated, no debates |
| Git hooks | Husky + lint-staged | latest | Pre-commit format, pre-push tests |

### Stack Constraints (Never Violate)

- **No Tailwind CSS** — we use CSS Modules + CSS Custom Properties. Tailwind is utility-class-first; we are module-scoped and token-based.
- **No Next.js** — Vite SPA is sufficient for marketing sites. Server-side rendering adds complexity without benefit.
- **No Redux** — React Context handles global state; TanStack Query handles server state. Redux is overhead.
- **No `styled-components` / `emotion`** — CSS-in-JS has runtime cost. CSS Modules are zero-runtime.
- **No `any` type** — ESLint error. Use type guards and `unknown`.
- **No `export default`** — named exports only, everywhere.
- **No `enum`** — use `as const` + `typeof`.
- **No `!important`** in CSS — except `prefers-reduced-motion` reset.
- **No inline styles** in JSX — use CSS Module classes.
- **No hardcoded colors/spacing/fonts** — always use design tokens.
- **No repository imports in `.tsx` files** — route through hooks.

### Adding Dependencies — Checklist

Before adding any npm package:

1. **Bundle size**: Check https://bundlephobia.com — is the cost justified?
2. **Maintenance**: Last publish date, weekly downloads, open issue count
3. **TypeScript**: Does it include types? Prefer packages with bundled types.
4. **Tree-shakeable**: Will unused code be excluded from the bundle?
5. **Alternative**: Is there a simpler implementation we can write ourselves?
6. **Layer fit**: Which layer does this belong in? (Presentation/Domain/Data)

### Approved Optional Dependencies

| Package | Purpose | Layer |
|---------|---------|-------|
| `@tanstack/react-query` | Server state (full apps only) | Presentation/hooks |
| `react-router-dom` v7 | Client routing (full apps only) | Presentation/layouts |
| `zustand` | Complex client state (last resort, full apps) | Presentation/hooks |
| `framer-motion` | Complex animations beyond CSS | Presentation/components |
| `date-fns` | Date formatting (avoid moment.js) | Domain/utilities |

### Rejected Dependencies — Explained

| Package | Why Rejected |
|---------|-------------|
| `tailwindcss` | Conflicts with CSS Modules token system |
| `redux` / `@reduxjs/toolkit` | Overkill; Context + TanStack Query sufficient |
| `styled-components` / `emotion` | Runtime CSS; we use zero-runtime CSS Modules |
| `next.js` | SSR complexity unnecessary for SPA; different paradigm |
| `axios` | `fetch` is built-in; axios adds 13kB for no benefit |
| `moment.js` | 300kB; use `date-fns` or `Intl` |
| `lodash` | Write specific utilities or use `Array.prototype` |
| `classnames` / `clsx` | Template literals are sufficient for most cases |
| `react-query` v3 | Use TanStack Query v5 (the rename) |

### MCP Servers (Available)

| MCP | Purpose |
|-----|---------|
| Context7 | Live library docs (React, Vite, Vitest, TanStack Query) |
| Playwright | Browser automation, E2E testing, Lighthouse |
| Vitest MCP | Structured test output, no watch-mode hang |
| GitHub (claude_ai) | PR/issue management |
| Figma (claude_ai) | Design-to-code |
| Netlify (per-project) | Deploy management, form monitoring |

### Design Aesthetic

- **Visual reference**: appl.studio — professional indie Apple studio aesthetic
- **Brand**: Burgundy (`#541311`) + Gold (`#FFB42E`) on dark background
- **Typography**: Radley Sans
- **Feel**: Dark, premium, generous whitespace, Apple-inspired
- **Anti-patterns**: Loud gradients, saturated colors on large areas, animations > 400ms, centered long paragraphs

### Deployment

- Auto-deploy on push to `main` via Netlify
- Deploy previews for every PR
- `netlify.toml` configures build settings and redirects
- Environment variables in Netlify dashboard (never committed)
