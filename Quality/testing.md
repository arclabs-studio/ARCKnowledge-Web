# Testing Strategy — ARC Labs Studio

What to test, how to test it, and what to skip entirely.

---

## Test Pyramid

```
         [ e2e / Playwright ]   ← critical user flows (form submit, nav)
       [  integration tests  ]  ← component + hook together (most value)
      [    unit tests        ]  ← hooks, utils, domain validators
```

- **Unit**: hooks (`renderHook`), utility functions, domain validators, Zod schemas
- **Integration**: component + hook rendering and interaction (primary surface)
- **E2E** (Playwright): critical user flows — form submission, navigation, theme toggle

---

## RTL Query Priority

Use the most semantic query available. `getByTestId` is a last resort.

```
getByRole            ← always preferred (matches accessibility tree)
getByLabelText       ← form inputs
getByText            ← visible text content
getByPlaceholderText ← input placeholders (acceptable)
getByTestId          ← last resort — requires explicit design sign-off
```

```tsx
// BAD
screen.getByTestId('submit-button')

// GOOD
screen.getByRole('button', { name: /send message/i })
```

---

## Test Behavior, Not Implementation

Never assert on CSS classes, internal state values, or component tree structure.

```tsx
// BAD — testing implementation details
expect(button).toHaveClass('button--loading');
expect(result.current.internalCount).toBe(3);

// GOOD — testing observable behavior
expect(button).toBeDisabled();
expect(screen.getByRole('status')).toHaveTextContent('Sending…');
```

---

## What to Test

- **User interactions**: click, type, submit, keyboard navigation
- **Conditional rendering**: empty state, loading state, error state, success state
- **Form validation**: required fields, format errors, submit blocked when invalid
- **Async state transitions**: idle → loading → success / error
- **Accessibility**: roles, labels, disabled states, aria attributes

---

## What NOT to Test

- That `useState` or `useEffect` work — trust React
- CSS classes or visual appearance — use visual regression (Percy, Chromatic) for that
- Third-party library behavior (react-hook-form internals, zod validation engine)
- Implementation details: internal variable names, private helper functions
- Netlify / third-party API behavior — mock at the boundary

---

## Mocking Rules

**Mock at system boundaries only.** Never mock the module under test.

```tsx
// Mock these (system boundaries):
global.fetch = vi.fn();                   // network boundary
vi.spyOn(Storage.prototype, 'setItem');   // localStorage boundary
vi.setSystemTime(new Date('2026-01-01')); // Date boundary

// Never mock these:
vi.mock('@presentation/hooks/useTheme');  // mocking what you're testing
vi.mock('react');                         // mocking the framework
```

---

## One Concept Per Test

Multiple `expect`s are fine when describing the same observable outcome. Split tests when concepts diverge.

```tsx
// GOOD — two expects, one concept (button is disabled during submit)
it('When form is submitting, Then submit button is disabled and shows loading text', () => {
  expect(button).toBeDisabled();
  expect(button).toHaveTextContent('Sending…');
});

// BAD — two unrelated concepts
it('validates email AND submits form', () => { ... });
```

---

## Async Testing

Always use `waitFor` or `findBy*`. Never arbitrary `setTimeout`.

```tsx
// BAD
await new Promise(r => setTimeout(r, 100));
expect(screen.getByText('Success')).toBeInTheDocument();

// GOOD
expect(await screen.findByText('Success')).toBeInTheDocument();

// GOOD — multiple assertions after async action
await waitFor(() => {
  expect(screen.getByRole('alert')).toHaveTextContent('Message sent!');
});
```

---

## Test Structure (Given/When/Then)

Co-locate test files with components. Use Given/When/Then in descriptions.

```tsx
// ComponentName.test.tsx
describe('ContactForm', () => {
  describe('Given the form is empty', () => {
    it('When the user submits, Then validation errors are shown', () => {
      // arrange
      render(<ContactForm />);
      // act
      fireEvent.click(screen.getByRole('button', { name: /send/i }));
      // assert
      expect(screen.getByText(/name is required/i)).toBeInTheDocument();
    });
  });

  describe('Given the form is filled correctly', () => {
    it('When the user submits, Then a success message is shown', async () => {
      global.fetch = vi.fn().mockResolvedValue({ ok: true });
      render(<ContactForm />);
      await userEvent.type(screen.getByLabelText(/name/i), 'Alex');
      await userEvent.type(screen.getByLabelText(/email/i), 'alex@example.com');
      await userEvent.type(screen.getByLabelText(/message/i), 'Hello there, this is a test');
      await userEvent.click(screen.getByRole('button', { name: /send/i }));
      expect(await screen.findByRole('alert')).toHaveTextContent(/message sent/i);
    });
  });
});
```

---

## ESLint Plugin Scoping

Apply testing-related ESLint plugins to the correct file globs — never mix Playwright and Vitest/RTL rules on the same files.

```js
// eslint.config.js
import vitestPlugin from '@vitest/eslint-plugin';
import testingLibrary from 'eslint-plugin-testing-library';
import playwright from 'eslint-plugin-playwright';

export default [
  // Unit/integration tests — Vitest + Testing Library
  {
    files: ['src/**/*.test.{ts,tsx}', 'src/**/*.spec.{ts,tsx}'],
    plugins: { vitest: vitestPlugin, 'testing-library': testingLibrary },
    rules: {
      ...vitestPlugin.configs.recommended.rules,
      ...testingLibrary.configs['flat/react'].rules,
    },
  },

  // E2E tests — Playwright only
  {
    files: ['e2e/**/*.spec.ts', 'e2e/**/*.test.ts'],
    plugins: { playwright },
    rules: playwright.configs['flat/recommended'].rules,
  },
];
```

---

## Vitest Configuration

```ts
// vite.config.ts
export default defineConfig({
  test: {
    globals: true,          // no need to import describe/it/expect
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      include: ['src/**/*.{ts,tsx}'],
      exclude: ['src/**/*.test.*', 'src/test/**'],
    },
  },
});
```

```ts
// src/test/setup.ts
import '@testing-library/jest-dom';
```

---

## Playwright E2E Tests

```ts
// e2e/contact-form.spec.ts
import { test, expect } from '@playwright/test';

test('contact form submits successfully', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('link', { name: /contact/i }).click();
  await page.getByLabel(/name/i).fill('Alex');
  await page.getByLabel(/email/i).fill('alex@example.com');
  await page.getByLabel(/message/i).fill('Hello from Playwright');
  await page.getByRole('button', { name: /send message/i }).click();
  await expect(page.getByRole('alert')).toContainText(/message sent/i);
});
```
