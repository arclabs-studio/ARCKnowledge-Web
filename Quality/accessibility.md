# Accessibility — ARC Labs Studio

**Target: WCAG 2.2 Level AA**

Accessibility is built in from the start — not added as a final audit. Every component is keyboard navigable, every image has alt text, every form has labels.

---

## WCAG 2.2 AA Checklist

### Perceivable
- [ ] Color contrast ≥ 4.5:1 for normal text (< 18px or < 14px bold)
- [ ] Color contrast ≥ 3:1 for large text (≥ 18px or ≥ 14px bold)
- [ ] Color contrast ≥ 3:1 for UI components and graphical objects
- [ ] No information conveyed by color alone (use text, icons, or patterns)
- [ ] All images have meaningful `alt` text or `alt=""` if decorative
- [ ] Videos have captions (if applicable)
- [ ] Content readable at 200% zoom without horizontal scroll

### Operable
- [ ] All interactive elements keyboard navigable
- [ ] Visible focus indicator on all interactive elements (`focus-visible`)
- [ ] No keyboard traps
- [ ] Skip navigation link to `#main-content`
- [ ] Correct heading hierarchy: one `<h1>`, then `<h2>`, `<h3>` — no skipping
- [ ] Touch targets minimum 44×44px (WCAG 2.5.8)
- [ ] No content that flashes more than 3 times per second
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Drag-and-drop operations have pointer alternatives (WCAG 2.5.7)

### Understandable
- [ ] Language set on `<html lang="en">` (or appropriate locale)
- [ ] Form inputs have visible, associated `<label>` elements
- [ ] Required fields marked with `aria-required="true"` + visible indicator
- [ ] Error messages are specific and associated with the field (`aria-describedby`)
- [ ] Error messages use `role="alert"` for live announcement
- [ ] No timeout that cannot be extended or disabled (WCAG 2.2 new)
- [ ] Authentication does not rely on cognitive tests (WCAG 2.2 new)

### Robust
- [ ] Valid semantic HTML (validate with axe-core)
- [ ] ARIA roles, states, and properties used correctly
- [ ] Interactive components follow ARIA patterns (modal, menu, tabs, etc.)
- [ ] Components work with VoiceOver (macOS/iOS) and NVDA (Windows)

---

## React Patterns

### Skip Link

Every page must have a skip link as the first focusable element:

```tsx
// MainLayout.tsx — first element inside <body>
<a href="#main-content" className={styles.skipLink}>
  Skip to main content
</a>

<main id="main-content">
  {children}
</main>
```

```css
/* MainLayout.module.css */
.skipLink {
  position: absolute;
  top: -100%;
  left: var(--space-4);
  z-index: var(--z-overlay);
  padding: var(--space-3) var(--space-4);
  background-color: var(--color-brand-primary);
  color: var(--color-text-on-brand);
  border-radius: var(--radius-md);
  text-decoration: none;
  font-weight: var(--font-semibold);
}

.skipLink:focus {
  top: var(--space-4);
}
```

### Focus Visible (not Focus)

Use `:focus-visible`, not `:focus`. `:focus` shows outlines during mouse clicks; `:focus-visible` only shows them during keyboard navigation.

```css
.button:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 2px;
}

/* Never remove focus entirely: */
/* .button:focus { outline: none; } ← NEVER DO THIS */
```

### Reduced Motion

Every animation must have a reduced-motion alternative:

```css
.card {
  transition: transform var(--duration-200) var(--ease-out);
}

.card:hover {
  transform: translateY(-4px);
}

@media (prefers-reduced-motion: reduce) {
  .card {
    transition: none;
  }
  .card:hover {
    transform: none;
  }
}
```

### Interactive Elements

```tsx
// BAD — no accessible label
<button onClick={onClose}>×</button>

// GOOD — machine-readable label
<button onClick={onClose} aria-label="Close dialog">×</button>

// BAD — link with non-descriptive text
<a href="/docs">Click here</a>

// GOOD — descriptive link text
<a href="/docs">Read the documentation</a>

// BAD — decorative icon announced by screen reader
<img src="/icon.svg" />

// GOOD — decorative image hidden from a11y tree
<img src="/icon.svg" alt="" aria-hidden="true" />

// GOOD — meaningful image with description
<img src="/hero.jpg" alt="ARC Labs Studio workspace with MacBook and iPad" />
```

### Touch Targets

Minimum 44×44px for all interactive elements:

```css
.iconButton {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 44px;
  min-height: 44px;
  padding: var(--space-2);
}
```

### Forms

```tsx
function EmailInput(): React.JSX.Element {
  return (
    <div className={styles.field}>
      <label htmlFor="email">
        Email <span aria-hidden="true">*</span>
      </label>
      <input
        id="email"
        type="email"
        aria-required="true"
        aria-describedby="email-error"
        autoComplete="email"
      />
      <span id="email-error" role="alert" className={styles.error}>
        {/* error message rendered here when invalid */}
      </span>
    </div>
  );
}
```

### ARIA Roles for Interactive Patterns

```tsx
// Segmented control (theme toggle)
<div role="group" aria-label="Color theme">
  <button aria-pressed={theme === 'brand'} onClick={() => setTheme('brand')}>Brand</button>
  <button aria-pressed={theme === 'dark'} onClick={() => setTheme('dark')}>Dark</button>
  <button aria-pressed={theme === 'light'} onClick={() => setTheme('light')}>Light</button>
</div>

// Modal dialog
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm action</h2>
  ...
</div>

// Navigation landmark
<nav aria-label="Main navigation">
  <ul>...</ul>
</nav>
```

---

## Testing Accessibility

### During Development

```bash
# Install axe-core for React
npm install --save-dev @axe-core/react

# Add to src/index.tsx (development only)
if (import.meta.env.DEV) {
  const axe = await import('@axe-core/react');
  axe.default(React, ReactDOM, 1000);
}
```

### Before Pull Request

Manual checklist:
1. Tab through the entire page — confirm focus order makes sense
2. Activate all interactive elements via keyboard (Enter/Space for buttons, Enter for links)
3. VoiceOver on macOS: Cmd+F5, navigate with VO+Arrow
4. Zoom browser to 200% — no horizontal scroll, no content cut off
5. Turn on high-contrast mode — verify all elements remain visible
6. Run axe DevTools browser extension

### ESLint

`eslint-plugin-jsx-a11y` catches static issues during development:
- Missing `alt` attributes
- Non-interactive elements with click handlers
- Missing `htmlFor` on labels
- Invalid ARIA attribute values
- Empty heading elements
