---
name: arc-ux-patterns
description: |
  UX patterns for ARC Labs Studio: form UX, loading states, error states,
  empty states, animation UX, responsive behavior, interaction feedback,
  microinteractions. Use when "form design", "loading state", "error state",
  "empty state", "user feedback", "interaction design", "UX patterns",
  "responsive behavior", or "microinteractions".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - UX Patterns

## Instructions

### Form UX

#### Validation Timing

```tsx
// Validate on blur, not on every keystroke — reduces anxiety
const { register } = useForm({
  mode: 'onBlur',           // GOOD — validates when user leaves field
  // mode: 'onChange',      // BAD for new users — shows errors while typing
  // mode: 'onSubmit',      // Too late — user waits until submit to see issues
});
```

#### Error Messages — Be Specific

```tsx
// BAD — vague
{errors.email && <span role="alert">Invalid</span>}

// GOOD — actionable
{errors.email && (
  <span role="alert">
    {errors.email.type === 'required'
      ? 'Email address is required'
      : 'Enter a valid email (e.g. name@example.com)'}
  </span>
)}
```

#### Submit State

Show what's happening during submission:

```tsx
function ContactForm(): React.JSX.Element {
  const { status, handleSubmit, register, errors } = useContactForm();

  return (
    <form onSubmit={handleSubmit}>
      {/* ... inputs ... */}

      <button
        type="submit"
        disabled={status === 'submitting'}
        aria-busy={status === 'submitting'}
        className={`${styles.submit} ${status === 'submitting' ? styles.loading : ''}`}
      >
        {status === 'submitting' ? 'Sending…' : 'Send message'}
      </button>

      {status === 'success' && (
        <p role="status" className={styles.successMessage}>
          Message sent! We'll be in touch soon.
        </p>
      )}

      {status === 'error' && (
        <p role="alert" className={styles.errorMessage}>
          Something went wrong. Please try again.
        </p>
      )}
    </form>
  );
}
```

#### Input Sizing

Inputs should signal expected input length:

```css
/* Short inputs for short values */
.zipCode { width: 120px; }
.phone { width: 200px; }

/* Full-width for free-form text */
.name, .email { width: 100%; }
.message { width: 100%; min-height: 120px; }
```

### Loading States

Never leave users wondering if something is happening:

```tsx
// Component loading
function AppsList(): React.JSX.Element {
  const { apps, isLoading, error } = useApps();

  if (isLoading) return <AppsListSkeleton />;
  if (error) return <ErrorMessage message={error} />;
  if (apps.length === 0) return <EmptyState />;

  return <ul>{apps.map(app => <AppCard key={app.id} {...app} />)}</ul>;
}
```

**Skeleton screens over spinners** for content that has a predictable shape:

```tsx
// Skeleton matches the shape of the real content
function AppCardSkeleton(): React.JSX.Element {
  return (
    <div className={styles.skeleton} aria-hidden="true">
      <div className={styles.skeletonIcon} />
      <div className={styles.skeletonTitle} />
      <div className={styles.skeletonDescription} />
    </div>
  );
}
```

```css
.skeleton {
  background: var(--color-surface-elevated);
  border-radius: var(--radius-lg);
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@media (prefers-reduced-motion: reduce) {
  .skeleton { animation: none; }
}
```

### Empty States

Empty states are a UX opportunity — not just absence of content:

```tsx
function EmptyApps(): React.JSX.Element {
  return (
    <div className={styles.empty} role="status">
      <img src="/images/empty-apps.svg" alt="" role="presentation" width={120} height={120} />
      <h3 className={styles.emptyTitle}>No apps yet</h3>
      <p className={styles.emptyDescription}>
        Check back soon — we're always building.
      </p>
    </div>
  );
}
```

### Error States

Error states should be actionable:

```tsx
function ErrorMessage({ message, onRetry }: ErrorMessageProps): React.JSX.Element {
  return (
    <div className={styles.error} role="alert">
      <p className={styles.errorText}>{message}</p>
      {onRetry && (
        <button onClick={onRetry} className={styles.retryButton}>
          Try again
        </button>
      )}
    </div>
  );
}
```

### Microinteractions

Small, purposeful feedback signals — not decoration:

```css
/* Button press feedback */
.button:active {
  transform: scale(0.98);
  transition: transform var(--duration-150) var(--ease-in-out);
}

/* Card hover — subtle lift */
.card {
  transition: transform var(--duration-150) var(--ease-out),
              box-shadow var(--duration-150) var(--ease-out);
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

/* Link underline reveal */
.navLink {
  position: relative;
  text-decoration: none;
}

.navLink::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--color-brand-secondary);
  transition: width var(--duration-300) var(--ease-out);
}

.navLink:hover::after,
.navLink[aria-current="location"]::after {
  width: 100%;
}

/* All microinteractions: respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  .button:active { transform: none; }
  .card:hover { transform: none; }
  .navLink::after { transition: none; }
}
```

### Responsive Behavior

Mobile-first. Content reflows gracefully:

```css
/* Mobile: single column, stacked */
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}

/* Tablet: 2 columns */
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-6);
  }
}

/* Desktop: 3 columns */
@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-8);
  }
}
```

Touch targets on mobile — ensure adequate spacing in lists:

```css
/* Mobile: more padding for finger targets */
.listItem {
  padding: var(--space-4);
}

@media (min-width: 768px) {
  .listItem {
    padding: var(--space-3);
  }
}
```

### Navigation UX

Active section highlighting (single-page):

```tsx
// IntersectionObserver-based active tracking
function useActiveSection(): { activeSection: string } {
  const [activeSection, setActiveSection] = useState('');

  useEffect(() => {
    const observer = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        });
      },
      { rootMargin: '-30% 0px -60% 0px' }, // Trigger when section is in center
    );

    document.querySelectorAll('[id]').forEach(section => observer.observe(section));
    return () => observer.disconnect();
  }, []);

  return { activeSection };
}
```

### Feedback Principles

1. **Immediate** — feedback within 100ms of action (button press, focus)
2. **Proportional** — small actions get small feedback; big actions get bigger feedback
3. **Informative** — tell users what happened, not just that something happened
4. **Recoverable** — error states should always offer a path forward

## Further Reading

- `Quality/accessibility.md` — ARIA live regions, focus management
- `Quality/design-tokens.md` — animation duration and easing tokens
- `Architecture/web-design-principles.md` — Progressive Enhancement principle
