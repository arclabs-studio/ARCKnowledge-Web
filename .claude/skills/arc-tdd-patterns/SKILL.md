---
name: arc-tdd-patterns
description: |
  TDD patterns for ARC Labs Studio web projects: Vitest + React Testing Library,
  Given/When/Then structure, RTL query priority, hook testing with renderHook,
  async testing patterns, mocking at boundaries. Use when "writing tests",
  "test-driven development", "testing a hook", "testing a component",
  "writing a unit test", "RTL query", or "test structure".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - TDD Patterns

## Instructions

### TDD Workflow

Write tests **before** implementation:

1. **Red** — Write failing tests describing expected behaviour
2. **Green** — Write minimum code to make tests pass
3. **Refactor** — Improve quality while keeping tests green

```bash
# Keep Vitest running during development
npx vitest

# Run a specific file
npx vitest run src/presentation/hooks/useTheme.test.ts
```

### Test Structure: Given/When/Then

```tsx
describe('ComponentName', () => {
  describe('Given [initial state]', () => {
    it('When [action], Then [expected outcome]', () => {
      // Arrange
      render(<ComponentName />);

      // Act
      fireEvent.click(screen.getByRole('button', { name: /submit/i }));

      // Assert
      expect(screen.getByRole('alert')).toHaveTextContent('Name is required');
    });
  });
});
```

### RTL Query Priority (most to least preferred)

```
1. getByRole           ← always preferred (matches accessibility tree)
2. getByLabelText      ← form inputs
3. getByText           ← visible text
4. getByPlaceholderText ← input placeholder (acceptable)
5. getByDisplayValue   ← form values
6. getByAltText        ← images
7. getByTitle          ← title attribute
8. getByTestId         ← LAST RESORT — requires design sign-off
```

```tsx
// BAD — implementation detail
screen.getByTestId('submit-button')

// GOOD — semantic, matches accessibility tree
screen.getByRole('button', { name: /send message/i })
```

### Testing Components

```tsx
// ContactSection.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ContactSection } from './ContactSection';

describe('ContactSection', () => {
  describe('Given the form is empty', () => {
    it('When the user submits, Then validation errors are shown', async () => {
      render(<ContactSection />);

      fireEvent.click(screen.getByRole('button', { name: /send/i }));

      await waitFor(() => {
        expect(screen.getByText(/name is required/i)).toBeInTheDocument();
        expect(screen.getByText(/email is required/i)).toBeInTheDocument();
      });
    });
  });

  describe('Given the form is filled correctly', () => {
    it('When the user submits, Then success message is shown', async () => {
      global.fetch = vi.fn().mockResolvedValue({ ok: true });
      render(<ContactSection />);

      fireEvent.change(screen.getByLabelText(/name/i), { target: { value: 'John' } });
      fireEvent.change(screen.getByLabelText(/email/i), { target: { value: 'john@example.com' } });
      fireEvent.change(screen.getByLabelText(/message/i), { target: { value: 'Hello world message' } });
      fireEvent.click(screen.getByRole('button', { name: /send/i }));

      await waitFor(() => {
        expect(screen.getByRole('alert')).toHaveTextContent(/message sent/i);
      });
    });
  });
});
```

### Testing Hooks with `renderHook`

```ts
// useTheme.test.ts
import { renderHook, act } from '@testing-library/react';
import { useTheme } from './useTheme';

describe('useTheme', () => {
  beforeEach(() => {
    localStorage.clear();
    document.documentElement.removeAttribute('data-theme');
  });

  describe('Given no stored theme', () => {
    it('When hook initialises, Then brand theme is returned', () => {
      const { result } = renderHook(() => useTheme());
      expect(result.current.theme).toBe('brand');
    });
  });

  describe('Given the brand theme is active', () => {
    it('When setTheme("dark") is called, Then theme changes to dark', () => {
      const { result } = renderHook(() => useTheme());

      act(() => {
        result.current.setTheme('dark');
      });

      expect(result.current.theme).toBe('dark');
      expect(document.documentElement.getAttribute('data-theme')).toBe('dark');
      expect(localStorage.getItem('arc-theme')).toBe('dark');
    });
  });
});
```

### Mocking Rules — Boundaries Only

Mock at system boundaries, never mock the module under test.

```tsx
// GOOD — mock system boundaries
global.fetch = vi.fn();                                    // network
vi.spyOn(Storage.prototype, 'setItem');                   // localStorage
vi.setSystemTime(new Date('2024-01-01'));                  // Date

// BAD — mocking what you're testing
vi.mock('@presentation/hooks/useTheme');                   // ✗
vi.mock('react');                                          // ✗
```

### Async Testing — Always `waitFor` or `findBy*`

```tsx
// BAD — arbitrary sleep
await new Promise(r => setTimeout(r, 100));

// GOOD
expect(await screen.findByText('Success')).toBeInTheDocument();

// GOOD — multiple assertions
await waitFor(() => {
  expect(screen.getByRole('status')).toHaveTextContent('Sent!');
  expect(screen.getByRole('button')).toBeEnabled();
});
```

### Test What, Not How

```tsx
// BAD — testing implementation details
expect(button).toHaveClass('button--loading');
expect(result.current.internalCount).toBe(3);

// GOOD — testing observable behaviour
expect(button).toBeDisabled();
expect(screen.getByRole('status')).toHaveTextContent('Sending…');
```

### What to Test

- User interactions: click, type, submit, keyboard navigation
- Conditional rendering: empty state, loading state, error state
- Form validation: required fields, format errors, submit blocked
- Async state transitions: idle → loading → success / error
- Accessibility attributes: roles, labels, disabled states

### What NOT to Test

- That `useState` / `useEffect` work (trust React)
- CSS classes or visual appearance (visual regression territory)
- Third-party library internals (react-hook-form, zod validation)
- Implementation details: internal variable names, private functions

### ESLint Plugin Scoping

Vitest + RTL rules must only apply to test files:
```
src/**/*.test.{ts,tsx}  → @vitest/eslint-plugin + eslint-plugin-testing-library
e2e/**/*.spec.{ts,tsx}  → eslint-plugin-playwright
```

Never let these globs overlap — they have conflicting `expect` type signatures.

### Playwright E2E (Contact Form)

```ts
// e2e/contact-form.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Contact form', () => {
  test('submits successfully with valid data', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('link', { name: /contact/i }).click();

    await page.getByLabel('Name').fill('John Doe');
    await page.getByLabel('Email').fill('john@example.com');
    await page.getByLabel('Message').fill('Hello, I have a question about your services.');

    await page.getByRole('button', { name: /send/i }).click();

    await expect(page.getByRole('alert')).toContainText('Message sent');
  });
});
```

## Further Reading

- `Quality/testing.md` — full testing strategy with E2E patterns
- `Architecture/error-handling.md` — testing error boundaries
