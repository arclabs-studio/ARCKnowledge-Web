# Design Tokens — ARC Labs Studio

All visual values are CSS custom properties in `src/presentation/styles/tokens.css`.

**Rule: Never hardcode colors, spacing, typography, shadows, or border radius. Always reference tokens.**

---

## Token Groups

| Prefix | Purpose | Examples |
|--------|---------|---------|
| `--color-*` | Colors (brand, semantic, application) | `--color-brand-primary`, `--color-surface`, `--color-text-primary` |
| `--text-*` | Font sizes (xs → 6xl) | `--text-sm`, `--text-base`, `--text-2xl` |
| `--font-*` | Font families and weights | `--font-sans`, `--font-semibold`, `--font-bold` |
| `--space-*` | Spacing scale (0 → 32) | `--space-4`, `--space-8`, `--space-16` |
| `--radius-*` | Border radius (sm → full) | `--radius-sm`, `--radius-md`, `--radius-lg`, `--radius-full` |
| `--shadow-*` | Box shadows (sm → xl) | `--shadow-sm`, `--shadow-md`, `--shadow-xl` |
| `--duration-*` | Transition durations | `--duration-150`, `--duration-300`, `--duration-400` |
| `--ease-*` | Easing functions | `--ease-in-out`, `--ease-out`, `--ease-spring` |
| `--z-*` | Z-index layers | `--z-header`, `--z-modal`, `--z-overlay` |

---

## Brand Colors

```css
/* ARC Labs Studio brand */
--color-brand-primary:   #541311;  /* Burgundy */
--color-brand-secondary: #FFB42E;  /* Gold */
--color-brand-dark:      #000000;  /* Pure black */
```

---

## Usage in CSS Modules

```css
/* ComponentName.module.css */
.card {
  padding: var(--space-6);
  background-color: var(--color-surface);
  border-radius: var(--radius-lg);
  color: var(--color-text-primary);
  box-shadow: var(--shadow-md);
}

.title {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: var(--color-text-primary);
}

.button {
  padding: var(--space-3) var(--space-6);
  background-color: var(--color-brand-primary);
  border-radius: var(--radius-md);
  transition: opacity var(--duration-150) var(--ease-in-out);
}
```

---

## Theme System

Themes work by overriding token values on the `[data-theme]` attribute. Base tokens are the brand theme (burgundy + gold).

```css
/* tokens.css */
:root {
  --color-surface: #1a1a1a;
  --color-text-primary: #f5f5f7;
  /* ... brand theme tokens ... */
}

[data-theme="dark"] {
  --color-surface: #0a0a0a;
  --color-text-primary: #ffffff;
  /* ... dark overrides ... */
}

[data-theme="light"] {
  --color-surface: #ffffff;
  --color-text-primary: #1d1d1f;
  /* ... light overrides ... */
}
```

The `useTheme` hook sets `document.documentElement.setAttribute('data-theme', theme)`. The flash prevention script in `index.html` reads the stored theme and applies it before React hydrates.

---

## Anti-Patterns

```css
/* BAD — hardcoded values */
.button {
  background-color: #541311;
  padding: 12px 24px;
  border-radius: 8px;
}

/* GOOD — tokens */
.button {
  background-color: var(--color-brand-primary);
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-md);
}

/* BAD — inline styles in JSX */
<div style={{ color: '#FFB42E', padding: '16px' }}>

/* GOOD — CSS Module class */
<div className={styles.highlight}>
```

---

## Adding New Tokens

1. Add the token to `src/presentation/styles/tokens.css` under `:root`
2. If the token should change with theme, add overrides under `[data-theme="dark"]` and `[data-theme="light"]`
3. Use the token in CSS Modules — never the raw value
4. Document the token in this file

Tokens should be semantic (what they represent) not descriptive (the raw value):

```css
/* BAD — descriptive token name */
--burgundy: #541311;

/* GOOD — semantic token name */
--color-brand-primary: #541311;
--color-button-bg: var(--color-brand-primary);
```
