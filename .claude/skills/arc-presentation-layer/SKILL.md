---
name: arc-presentation-layer
description: |
  Presentation layer patterns for ARC Labs Studio: React components (JSX only),
  CSS Modules with design tokens, hooks as ViewModels, scroll reveal, responsive
  breakpoints. Use when "creating a component", "adding a section", "styling a
  component", "writing a hook", "adding CSS", "mobile responsive", or any question
  about the Presentation layer structure.
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Presentation Layer

## Instructions

### Component Rule: JSX Only

A component file contains **only JSX**. No `useEffect`, no `async` functions, no repository imports, no business logic.

```tsx
// BAD — business logic in component
function ContactSection(): React.JSX.Element {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const handleSubmit = async (e: React.FormEvent): Promise<void> => {
    setIsSubmitting(true);
    await fetch('/api/contact', { ... }); // logic belongs in hook
    setIsSubmitting(false);
  };
  return <form onSubmit={handleSubmit}>...</form>;
}

// GOOD — JSX only, hook owns logic
function ContactSection(): React.JSX.Element {
  const { status, handleSubmit, register, errors } = useContactForm();
  return (
    <section id="contact" className={styles.section}>
      <form onSubmit={handleSubmit}>
        <input {...register('email')} />
        {errors.email && <span role="alert">{errors.email.message}</span>}
        <button type="submit" disabled={status === 'submitting'}>
          {status === 'submitting' ? 'Sending…' : 'Send'}
        </button>
      </form>
    </section>
  );
}
```

### Component Directory Pattern (4 files — mandatory)

```
ComponentName/
├── ComponentName.tsx          # Component implementation
├── ComponentName.module.css   # Scoped styles
├── ComponentName.test.tsx     # Tests (Given/When/Then)
└── index.ts                   # export { ComponentName } from './ComponentName';
```

Never skip the `index.ts` barrel. Never use default exports.

### Hook Pattern (ViewModel)

The hook owns all state, effects, and logic. The component calls the hook.

```ts
// hooks/useContactForm.ts

// 1. External imports
import { useState, useCallback } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

// 2. Internal imports
import { contactRepository } from '@data/repositories/contactRepository';
import { contactSchema, type ContactFormData } from '@domain/entities/ContactFormData';

// 3. Return type interface
interface UseContactFormResult {
  status: 'idle' | 'submitting' | 'success' | 'error';
  handleSubmit: (e: React.FormEvent) => void;
  register: ReturnType<typeof useForm>['register'];
  errors: FieldErrors<ContactFormData>;
  submitError: string | null;
}

// 4. Hook definition
function useContactForm(): UseContactFormResult {
  const [status, setStatus] = useState<'idle' | 'submitting' | 'success' | 'error'>('idle');
  const [submitError, setSubmitError] = useState<string | null>(null);

  const { register, handleSubmit: rhfSubmit, formState: { errors } } = useForm<ContactFormData>({
    resolver: zodResolver(contactSchema),
  });

  const handleSubmit = useCallback(
    rhfSubmit(async (data: ContactFormData): Promise<void> => {
      setStatus('submitting');
      const result = await contactRepository.submit(data);
      if (result.ok) {
        setStatus('success');
      } else {
        setStatus('error');
        setSubmitError(result.error);
      }
    }),
    [rhfSubmit],
  );

  return { status, handleSubmit, register, errors, submitError };
}

export { useContactForm };
```

### CSS Modules Rules

1. **Tokens only** — never hardcode colors, spacing, or fonts
2. **Mobile-first** — base styles for mobile, `@media (min-width: ...)` for larger
3. **camelCase class names** — `.primaryButton`, `.isActive`, `.hasError`
4. **No `!important`** (exception: `prefers-reduced-motion` reset)
5. **No inline styles** in JSX

```css
/* ContactSection.module.css */

.section {
  padding: var(--space-20) var(--space-6);
  background-color: var(--color-surface);
}

.form {
  max-width: 600px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

/* Mobile-first responsive */
@media (min-width: 768px) {
  .section {
    padding: var(--space-32) var(--space-12);
  }
}

@media (min-width: 1024px) {
  .form {
    max-width: 720px;
  }
}

/* Accessibility */
.submitButton:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 2px;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .animated {
    animation: none !important;
    transition: none !important;
  }
}
```

### Responsive Breakpoints

| Breakpoint | Token | Usage |
|------------|-------|-------|
| Base | — | Mobile (< 768px) |
| `md` | `min-width: 768px` | Tablet |
| `lg` | `min-width: 1024px` | Desktop |
| `xl` | `min-width: 1280px` | Wide desktop |

### Import Order in Component Files

```tsx
// 1. External imports
import { useState } from 'react';

// 2. Internal imports (domain/data — through hook, never direct data import in .tsx)
import type { Theme } from '@domain/entities/Theme';
import { useTheme } from '@presentation/hooks/useTheme';

// 3. Relative imports (CSS Module)
import styles from './ThemeToggle.module.css';

// 4. Type definitions
interface ThemeToggleProps {
  defaultTheme?: Theme;
}

// 5. Component
function ThemeToggle({ defaultTheme = 'brand' }: ThemeToggleProps): React.JSX.Element {
  const { theme, setTheme } = useTheme();
  return (...);
}

// 6. Named export
export { ThemeToggle };
```

### Scroll Reveal

`useScrollReveal` provides entrance animations via IntersectionObserver:

```tsx
// Already called in App.tsx — do not call in individual sections
// Add className="reveal" to elements that should animate in:

<div className={`${styles.card} reveal`}>
  ...
</div>
```

CSS for reveal animations:
```css
/* In global styles or via CSS Module composing from global */
.reveal {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity var(--duration-400) var(--ease-out),
              transform var(--duration-400) var(--ease-out);
}

.reveal.reveal-visible {
  opacity: 1;
  transform: translateY(0);
}

@media (prefers-reduced-motion: reduce) {
  .reveal {
    opacity: 1 !important;
    transform: none !important;
    transition: none !important;
  }
}
```

### Named Exports Only

```ts
// BAD
export default function Button() { ... }

// GOOD
export function Button() { ... }
// OR
export { Button };
```

### Event Handler Naming

```ts
// Props: on + EventName
interface CardProps {
  onClose: () => void;
  onSelect: (id: string) => void;
}

// Internal handlers: handle + What
const handleClose = (): void => { ... };
const handleSelect = (id: string): void => { ... };
```

## Further Reading

- `Layers/presentation.md` — full presentation layer documentation
- `Quality/design-tokens.md` — token groups and theme system
- `Quality/code-style.md` — naming conventions, import order
- `Quality/accessibility.md` — focus-visible, ARIA, touch targets
