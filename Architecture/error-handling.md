# Error Handling — ARC Labs Studio

Strategy for error boundaries, async errors, and domain vs runtime failures.

---

## Error Boundaries

**Two boundaries: one at app root, one per major page section.**

- **Root boundary** — catches catastrophic failures; shows a full-page fallback
- **Section boundary** — isolates partial failures; one broken section does not kill the page

```tsx
// App.tsx — root boundary wraps everything
<RootErrorBoundary>
  <MainLayout>
    <HeroSection />
    <SectionErrorBoundary name="Contact">
      <ContactSection />
    </SectionErrorBoundary>
  </MainLayout>
</RootErrorBoundary>
```

Error boundaries must be class components (as of React 19 — `react-error-boundary` provides a functional wrapper):

```tsx
import { ErrorBoundary } from 'react-error-boundary';

function SectionFallback({ error }: { error: Error }): React.JSX.Element {
  return (
    <div role="alert" className={styles.error}>
      <p>This section failed to load.</p>
      {import.meta.env.DEV && <pre>{error.message}</pre>}
    </div>
  );
}

// Usage
<ErrorBoundary FallbackComponent={SectionFallback}>
  <ContactSection />
</ErrorBoundary>
```

---

## Async Error Handling

**Always `try/catch` in event handlers. Never let promise rejections go unhandled.**

```tsx
// BAD — unhandled rejection silently swallows errors
const handleSubmit = async (data: ContactFormData): Promise<void> => {
  await submitForm(data); // throws on network failure, nothing catches it
};

// GOOD — catch and surface the error
const handleSubmit = async (data: ContactFormData): Promise<void> => {
  try {
    await submitForm(data);
    setStatus('success');
  } catch (error) {
    setSubmitError('Something went wrong. Please try again.');
    if (import.meta.env.DEV) {
      console.error('[ContactForm] submit failed:', error);
    }
  }
};
```

---

## Never Swallow Errors Silently

An empty `catch` block is always wrong. Log in dev or surface every caught error.

```ts
// BAD — silent swallow, production bug invisible
try {
  const theme = JSON.parse(raw);
  return theme;
} catch {}

// GOOD — fallback with dev logging
try {
  const theme = JSON.parse(raw);
  return isTheme(theme) ? theme : 'brand';
} catch (error) {
  if (import.meta.env.DEV) {
    console.error('[themeRepository] failed to parse theme:', error);
  }
  return 'brand';
}
```

---

## Domain Errors vs Runtime Errors

**Predictable failures return data. Unexpected failures throw.**

| Scenario | Approach |
|---|---|
| Form validation fails | Return `{ ok: false, error: 'Email is required' }` |
| API returns 4xx | Return `{ ok: false, error: message }` |
| Network is offline | Throw (unexpected, caller must handle) |
| `JSON.parse` on corrupt data | Catch + return fallback |
| Invariant violated | Throw with descriptive message |

---

## Result Pattern

Use a `Result` type for operations that can fail predictably.

```ts
// domain/entities/Result.ts
type Result<T> =
  | { ok: true; data: T }
  | { ok: false; error: string };
```

```ts
// data/repositories/contactRepository.ts
async function submitContactForm(data: ContactFormData): Promise<Result<void>> {
  try {
    const response = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      return { ok: false, error: `Server error: ${response.status}` };
    }
    return { ok: true, data: undefined };
  } catch {
    return { ok: false, error: 'Failed to send message. Please try again.' };
  }
}
```

```ts
// Hook call site — forced to handle both cases
const result = await submitContactForm(formData);
if (!result.ok) {
  setSubmitError(result.error);
  return;
}
setStatus('success');
```

---

## Form Error Levels

- **Field-level errors** — react-hook-form handles via `register` + `resolver`
- **Submit-level errors** — component state (`useState<string | null>`) for server-returned messages

```tsx
function ContactSection(): React.JSX.Element {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(contactSchema),
  });
  const [submitError, setSubmitError] = useState<string | null>(null);

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" {...register('email')} aria-describedby="email-error" />
        {errors.email && (
          <span id="email-error" role="alert">{errors.email.message}</span>
        )}
      </div>

      {submitError && (
        <p role="alert" className={styles.submitError}>{submitError}</p>
      )}

      <button type="submit">Send</button>
    </form>
  );
}
```

---

## Logging Rules

**`console.error` only in development.** Never log to console in production builds.

```ts
// GOOD — gated behind DEV flag
if (import.meta.env.DEV) {
  console.error('[ComponentName] unexpected state:', value);
}
```

In production, errors should be surfaced to the user via UI feedback (error messages, fallbacks) — not to the console.

---

## Quick Reference

| Scenario | Pattern |
|---|---|
| Async event handler | `try/catch`, surface error to UI |
| Predictable API failure | `Result<T>` return type |
| Unpredictable failure | `throw` + Error Boundary |
| Storage parsing failure | `catch` + fallback value |
| Empty `catch` | Never — always log or return fallback |
| Console in production | Never — use `import.meta.env.DEV` guard |
