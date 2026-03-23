---
name: arc-accessibility
description: |
  WCAG 2.2 AA accessibility patterns for ARC Labs Studio React projects:
  keyboard navigation, focus management, ARIA roles, color contrast, reduced
  motion, touch targets, form labels, skip links. Use when "accessibility audit",
  "a11y", "keyboard navigation", "VoiceOver", "screen reader", "focus ring",
  "ARIA", "color contrast", or "WCAG".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Accessibility (WCAG 2.2 AA)

## Instructions

### Quick Checklist

- [ ] All interactive elements keyboard navigable (Tab + Space/Enter)
- [ ] `focus-visible` on all interactive elements (never just `focus`)
- [ ] Color contrast ≥ 4.5:1 normal text, ≥ 3:1 large text (18px+ or 14px+ bold)
- [ ] Skip link to `#main-content` (first focusable element)
- [ ] Images: meaningful `alt` text, or `alt=""` if decorative
- [ ] Form inputs: associated `<label>` (via `for`/`id` or wrapping)
- [ ] Error messages: `role="alert"`
- [ ] Required fields: `aria-required="true"`
- [ ] Correct heading hierarchy (h1 → h2 → h3, no skips)
- [ ] Touch targets ≥ 44×44px
- [ ] Respects `prefers-reduced-motion`
- [ ] Usable at 200% browser zoom
- [ ] No information conveyed by color alone

### Focus Management

```css
/* GOOD — use focus-visible (only shows ring for keyboard users) */
.button:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 3px;
  border-radius: var(--radius-sm);
}

/* BAD — suppresses focus for all users */
.button:focus {
  outline: none;
}

/* BAD — :focus instead of :focus-visible shows ring on mouse click */
.button:focus {
  outline: 2px solid blue;
}
```

Never use `outline: none` without an alternative visual indicator.

### Skip Link

Every page needs a skip link as the first focusable element:

```tsx
// MainLayout.tsx
function MainLayout({ children }: MainLayoutProps): React.JSX.Element {
  return (
    <>
      <a href="#main-content" className={styles.skipLink}>
        Skip to main content
      </a>
      <Header />
      <main id="main-content">{children}</main>
      <Footer />
    </>
  );
}
```

```css
/* Visible only on focus */
.skipLink {
  position: absolute;
  top: -100%;
  left: var(--space-4);
  padding: var(--space-2) var(--space-4);
  background: var(--color-brand-primary);
  color: var(--color-text-on-brand);
  border-radius: var(--radius-md);
  z-index: var(--z-modal);
  transition: top var(--duration-150);
}

.skipLink:focus-visible {
  top: var(--space-4);
}
```

### Interactive Elements

Minimum touch target: **44×44px**

```css
.button {
  min-height: 44px;
  min-width: 44px;
  padding: var(--space-3) var(--space-6);  /* Ensures target size */
  cursor: pointer;
}
```

Buttons need descriptive text or `aria-label`:
```tsx
{/* BAD — ambiguous */}
<button aria-label="X">×</button>

{/* GOOD — descriptive */}
<button aria-label="Close navigation menu">×</button>
```

Links need descriptive text (never "click here"):
```tsx
{/* BAD */}
<a href="/apps">Click here</a>

{/* GOOD */}
<a href="/apps">View all apps</a>
```

### Forms

Every input requires an associated `<label>`:

```tsx
{/* GOOD — associated via htmlFor/id */}
<label htmlFor="email">Email address</label>
<input
  id="email"
  type="email"
  aria-required="true"
  aria-describedby={errors.email ? 'email-error' : undefined}
/>
{errors.email && (
  <span id="email-error" role="alert">
    {errors.email.message}
  </span>
)}

{/* GOOD — associated by wrapping */}
<label>
  <span>Email address</span>
  <input type="email" />
</label>
```

Submit-level errors use `role="alert"`:
```tsx
{submitError && (
  <p role="alert" className={styles.submitError}>
    {submitError}
  </p>
)}
```

### ARIA Roles

Use ARIA roles only when semantic HTML isn't sufficient:

```tsx
{/* Landmark roles (semantic HTML preferred) */}
<header role="banner">      {/* or just <header> */}
<nav role="navigation">     {/* or just <nav> */}
<main role="main">          {/* or just <main> */}
<footer role="contentinfo"> {/* or just <footer> */}

{/* State roles */}
<button aria-pressed={isActive}>Toggle</button>
<button aria-expanded={isOpen} aria-controls="menu">Menu</button>
<div id="menu" aria-hidden={!isOpen}>...</div>

{/* Live regions */}
<div role="alert">Error message</div>       {/* assertive, interrupts */}
<div role="status">Success message</div>    {/* polite, waits */}
<div aria-live="polite">Loading...</div>

{/* Group labelling */}
<div role="group" aria-label="Theme selection">
  {THEMES.map(t => (
    <button key={t} aria-pressed={theme === t}>{t}</button>
  ))}
</div>
```

### Reduced Motion

```css
/* Entrance animations */
.reveal {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity var(--duration-400) var(--ease-out),
              transform var(--duration-400) var(--ease-out);
}

.reveal.visible {
  opacity: 1;
  transform: none;
}

/* Reset for reduced-motion users */
@media (prefers-reduced-motion: reduce) {
  .reveal {
    opacity: 1 !important;
    transform: none !important;
    transition: none !important;
  }

  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Navigation

Active navigation links:
```tsx
<nav aria-label="Main navigation">
  <ul>
    {NAV_LINKS.map(link => (
      <li key={link.id}>
        <a
          href={`#${link.id}`}
          aria-current={activeSection === link.id ? 'location' : undefined}
          className={`${styles.link} ${activeSection === link.id ? styles.active : ''}`}
        >
          {link.label}
        </a>
      </li>
    ))}
  </ul>
</nav>
```

Mobile menu:
```tsx
<button
  aria-label={isOpen ? 'Close navigation menu' : 'Open navigation menu'}
  aria-expanded={isOpen}
  aria-controls="mobile-nav"
  onClick={handleToggle}
>
  <span aria-hidden="true">{isOpen ? '✕' : '☰'}</span>
</button>

<div
  id="mobile-nav"
  aria-hidden={!isOpen}
  className={`${styles.mobileNav} ${isOpen ? styles.open : ''}`}
>
  ...
</div>
```

### Images

```tsx
{/* Meaningful image — describe what it shows */}
<img src="/images/app-icon.png" alt="Meridian app icon — a compass rose" />

{/* Decorative image — empty alt, not omitted */}
<img src="/images/divider.svg" alt="" role="presentation" />

{/* Background image in CSS — no alt needed (not in DOM) */}
```

Always include `width` and `height` to prevent Cumulative Layout Shift:
```tsx
<img src="/images/hero.jpg" alt="..." width={800} height={600} />
```

### Development Testing

```tsx
// Add @axe-core/react in development
// src/main.tsx
if (import.meta.env.DEV) {
  const { default: axe } = await import('@axe-core/react');
  const { default: React } = await import('react');
  const { default: ReactDOM } = await import('react-dom');
  axe(React, ReactDOM, 1000);
}
```

Manual testing:
1. Tab through the entire page — focus order must be logical
2. VoiceOver (macOS): Cmd+F5, navigate with VO+arrow keys
3. Zoom to 200% — layout must not break or overlap
4. Chrome DevTools Accessibility panel — check computed roles/names

## Further Reading

- `Quality/accessibility.md` — full WCAG 2.2 AA checklist with Perceivable/Operable/Understandable/Robust sections
