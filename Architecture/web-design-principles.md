# Web Design Principles — ARC Labs Studio

**Six principles that govern every design decision in ARC Labs web projects.** These are not rules derived from frameworks — they are commitments about how we write code that compound positively over time.

---

## 1. Explicit Types Everywhere

TypeScript's value is not just catching bugs at compile time. It is documentation that never goes stale. Every function signature is a contract; every type is a spec.

**What this means:**
- Explicit return types on every function (ESLint enforced)
- No `any` — ever. Use `unknown` and narrow it.
- No `as` assertions — validate at the boundary instead
- No `enum` — use `as const` + `typeof` for runtime-safe constants
- Strict mode: `strict: true`, `noUncheckedIndexedAccess`, `noUnusedLocals`

```ts
// BAD — implicit, brittle
const getTheme = () => localStorage.getItem('theme') ?? 'brand';

// GOOD — explicit, documented
const getTheme = (): Theme => {
  const raw = localStorage.getItem('theme');
  return isTheme(raw) ? raw : 'brand';
};
```

**Why:** AI-generated code without explicit types accumulates invisible debt. Explicit types force every function to declare its contract. They also make Claude Code more accurate — type signatures are a machine-readable spec.

---

## 2. Hooks as Abstraction Boundary

In React, the hook is the equivalent of a Use Case in Clean Architecture. It is the boundary between business logic and rendering.

**What this means:**
- Logic lives in hooks, JSX lives in components
- Components have no `useState`, no `useEffect`, no business logic
- Hooks are independently testable via `renderHook`
- One hook, one concern (hooks can compose other hooks)

```tsx
// BAD — logic buried in component
function ContactSection(): React.JSX.Element {
  const [status, setStatus] = useState<'idle' | 'submitting' | 'done'>('idle');
  const onSubmit = async (data: ContactFormData): Promise<void> => { ... };
  return <form onSubmit={...}>...</form>;
}

// GOOD — hook is the Use Case
function ContactSection(): React.JSX.Element {
  const { status, onSubmit } = useContactForm();
  return <form onSubmit={onSubmit}>...</form>;
}
```

**Why:** Components that own logic cannot be tested without rendering. Hooks can. This separation makes both easier to maintain and enables AI agents to work on one side without breaking the other.

---

## 3. Composition Over Configuration

Extend behavior by composing at the call site — not by adding props to existing components.

**What this means:**
- Pass `children` instead of passing slot props
- Create specialized wrappers instead of adding `variant` props
- Never add `if (variant === 'new')` to an existing component
- Prop drilling limit: 2 levels max, then restructure

```tsx
// BAD — component grows with every use case
<Card variant="featured" withBorder withShadow headerSlot={<Title />} />

// GOOD — compose at the call site
<Card>
  <CardHeader><Title /></CardHeader>
  <CardBody>...</CardBody>
</Card>
```

**Why:** Configuration-driven components become impossible to understand and test. Composition keeps each component small, with a single clear contract.

---

## 4. Tokens Over Values

Every visual value — color, spacing, typography, shadow, radius — is a design token. Hardcoding values is a build error waiting to happen.

**What this means:**
- All tokens in `src/presentation/styles/tokens.css` as CSS custom properties
- CSS Modules reference tokens via `var(--token-name)` — never raw values
- No inline styles — ever
- No `!important` — ever (except reduced-motion reset)
- Dark/light themes = token overrides on `[data-theme]`, not duplicated styles

```css
/* BAD — hardcoded values break when the design changes */
.card {
  padding: 24px;
  background-color: #1a1a1a;
  border-radius: 8px;
}

/* GOOD — tokens adapt to theme, scale, and change */
.card {
  padding: var(--space-6);
  background-color: var(--color-surface);
  border-radius: var(--radius-lg);
}
```

**Why:** Tokens make design changes a single-file edit. They make theming trivial. They make AI-generated code consistent — Claude can reference tokens by name instead of guessing hex values.

---

## 5. Progressive Enhancement

Build for the baseline first. Then layer on enhancements that degrade gracefully.

**What this means:**
- Mobile-first CSS: base = mobile, `@media (min-width: 768px)` for tablet, `1024px` for desktop
- Animations respect `prefers-reduced-motion` — always
- Focus states work with keyboard before adding pointer interactions
- Images have meaningful `alt` text or `alt=""` if decorative
- No JavaScript required for content — JavaScript adds behavior, not content

```css
.animated {
  transition: transform var(--duration-300) var(--ease-out);
}

@media (prefers-reduced-motion: reduce) {
  .animated {
    transition: none;
  }
}
```

**Why:** Accessibility and performance are not afterthoughts — they are the baseline. Every enhancement is tested against the baseline.

---

## 6. Accessibility by Default

WCAG 2.2 AA is the floor, not the ceiling. Accessibility is tested during development, not as a final audit.

**What this means:**
- Every interactive element is keyboard navigable
- Color contrast ≥ 4.5:1 for normal text, ≥ 3:1 for large text
- `focus-visible` on every interactive element
- Correct heading hierarchy: h1 → h2 → h3 (no skipping)
- Forms: every input has a visible `<label>`
- Skip link to `#main-content` on every page
- Touch targets: minimum 44×44px
- No color-only information

```tsx
// BAD — no accessible label
<button onClick={onClose}>×</button>

// GOOD — machine-readable label
<button onClick={onClose} aria-label="Close dialog">×</button>
```

**Why:** Accessible code is better code. The constraints of accessibility (semantic HTML, keyboard navigation, descriptive labels) produce components that are easier to test, understand, and maintain. WCAG 2.2 also avoids legal risk in most jurisdictions.

---

## Summary

| Principle | The Rule |
|-----------|----------|
| Explicit Types Everywhere | Every function has a declared return type. No `any`. No `as`. |
| Hooks as Abstraction Boundary | Logic lives in hooks. JSX lives in components. |
| Composition Over Configuration | Extend via `children` and wrappers. Never via more props. |
| Tokens Over Values | All visual values are CSS custom properties. No hardcoding. |
| Progressive Enhancement | Mobile first. Reduced-motion aware. No content behind JS. |
| Accessibility by Default | WCAG 2.2 AA from the start. Keyboard navigable by default. |
