# Documentation — ARC Labs Studio

Standards for code comments, JSDoc, and README files.

---

## When to Document

Document the *why*, not the *what*. Code describes what happens; comments explain decisions that are not obvious from the code alone.

**Document:**
- Non-obvious decisions ("We use URLEncoded instead of JSON because Netlify Forms requires it")
- Complex algorithms or formulas
- Workarounds for third-party limitations
- Performance trade-offs

**Don't document:**
- What the code does when the code is self-explanatory
- TypeScript types that already document themselves
- Standard patterns (CRUD operations, React hooks, etc.)

---

## JSDoc for Exported Utilities

Exported functions that are not self-documenting should have JSDoc:

```ts
/**
 * Applies the theme to the document root and persists it to storage.
 * Must be called on the client — reads/writes document.documentElement.
 *
 * @param theme - The theme to apply. 'brand' restores the default.
 */
export function applyTheme(theme: Theme): void {
  document.documentElement.setAttribute('data-theme', theme);
  themeRepository.set(theme);
}
```

Components do not require JSDoc — their TypeScript interface documents the contract:

```tsx
// No JSDoc needed — the interface is the documentation
interface ButtonProps {
  /** The text label for the button. Must be non-empty. */
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}
```

---

## Inline Comments

Keep inline comments short and purposeful:

```ts
// Flash prevention: apply theme before React hydrates to avoid FOUC
document.documentElement.setAttribute('data-theme', storedTheme ?? 'brand');

// Intersection observer is disconnected after first trigger — intentional one-shot
observer.unobserve(element);
```

---

## README Standards

Every new component or module does not need its own README. The project-level README covers the stack and architecture.

For non-obvious configuration or integrations, add a comment at the top of the relevant file:

```ts
// data/repositories/contactRepository.ts
//
// Netlify Forms integration — form submissions are handled by Netlify's
// built-in form processing when deployed. For local development, POST
// requests return 404 (expected). The HTML form in ContactSection.tsx
// must include data-netlify="true" and a hidden input with the form name.
```

---

## No Commented-Out Code

Remove dead code — do not comment it out. Git history preserves removed code.

```ts
// BAD
// const oldHandler = async (data) => {
//   await fetch('/api/old-endpoint', { ... });
// };

const handler = async (data: ContactFormData): Promise<void> => { ... };
```

---

## TODO Policy

Every TODO must reference a Linear ticket:

```ts
// BAD
// TODO: add GitHub API integration

// GOOD
// TODO(ARCW-42): integrate GitHub API for live repository data
```

Untracked TODOs are found and flagged by Knip. Zero tolerance in production code.
