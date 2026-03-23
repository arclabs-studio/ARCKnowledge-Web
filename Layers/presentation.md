# Presentation Layer — ARC Labs Studio

The Presentation layer contains everything the user sees and interacts with. It owns JSX, CSS Modules, hooks, and routing.

---

## What Belongs Here

```
src/presentation/
├── components/         # Reusable UI building blocks
│   └── Button/
│       ├── Button.tsx
│       ├── Button.module.css
│       ├── Button.test.tsx
│       └── index.ts
├── hooks/              # ViewModels — logic and state
│   ├── useTheme.ts
│   └── useActiveSection.ts
├── layouts/            # Page-level wrappers (Header + Footer chrome)
│   └── MainLayout/
├── sections/ (or pages/)  # Page sections / full pages
│   └── HeroSection/
└── styles/             # Global CSS (reset, tokens, typography)
    ├── tokens.css
    ├── reset.css
    └── typography.css
```

---

## Component Structure

Every component is a directory with exactly 4 files:

```
ComponentName/
├── ComponentName.tsx          # JSX only
├── ComponentName.module.css   # Scoped styles
├── ComponentName.test.tsx     # Tests (component + hook integration)
└── index.ts                   # Barrel: export { ComponentName } from './ComponentName'
```

### What a Component Contains

- JSX only — no `useState` (except purely local UI state like hover/active)
- No `useEffect`
- No async functions
- No direct repository/API imports
- Props as a TypeScript `interface`
- Explicit `React.JSX.Element` return type

```tsx
import styles from './Button.module.css';

interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps): React.JSX.Element {
  return (
    <button
      className={`${styles.button} ${styles[variant]}`}
      onClick={onClick}
      disabled={disabled}
      type="button"
    >
      {label}
    </button>
  );
}

export { Button };
```

---

## Hooks as ViewModels

Hooks own all state, side effects, validation, and async operations. The component calls the hook and renders the result.

```ts
// useTheme.ts — owns theme state + DOM sync + persistence
interface UseThemeResult {
  theme: Theme;
  setTheme: (theme: Theme) => void;
}

export function useTheme(): UseThemeResult {
  const [theme, setThemeState] = useState<Theme>(() => themeRepository.get());

  const setTheme = useCallback((newTheme: Theme): void => {
    themeRepository.set(newTheme);
    setThemeState(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  }, []);

  return { theme, setTheme };
}
```

```tsx
// ThemeToggle.tsx — JSX only, calls hook
function ThemeToggle(): React.JSX.Element {
  const { theme, setTheme } = useTheme();
  return (
    <div role="group" aria-label="Theme">
      {THEMES.map(t => (
        <button
          key={t}
          className={`${styles.option} ${theme === t ? styles.active : ''}`}
          onClick={() => setTheme(t)}
          aria-pressed={theme === t}
        >
          {t}
        </button>
      ))}
    </div>
  );
}
```

---

## CSS Modules

Every component has its own `.module.css` file. Never share CSS between components.

### Rules

- Use design tokens via `var(--token-name)` — never raw values
- Mobile-first: base = mobile, `@media (min-width: 768px)` for tablet, `1024px` for desktop
- No `!important` (exception: `prefers-reduced-motion` reset)
- Class names: camelCase in CSS Modules (`.primaryButton`, `.isActive`)
- No inline styles in JSX

```css
/* Button.module.css */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-md);
  font-family: var(--font-sans);
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  cursor: pointer;
  transition: opacity var(--duration-150) var(--ease-in-out);
  border: none;
}

.button:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 2px;
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.primary {
  background-color: var(--color-brand-primary);
  color: var(--color-text-on-brand);
}

.secondary {
  background-color: transparent;
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
}

@media (prefers-reduced-motion: reduce) {
  .button {
    transition: none;
  }
}
```

---

## Scroll Reveal Pattern

Use `IntersectionObserver` for entrance animations. The `useScrollReveal` hook adds `reveal-visible` when elements enter the viewport.

```ts
export function useScrollReveal(threshold = 0.1): React.RefObject<HTMLElement> {
  const ref = useRef<HTMLElement>(null);

  useEffect((): (() => void) => {
    const element = ref.current;
    if (!element) return () => undefined;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          element.classList.add('reveal-visible');
          observer.unobserve(element);
        }
      },
      { threshold }
    );

    observer.observe(element);
    return (): void => observer.unobserve(element);
  }, [threshold]);

  return ref;
}
```

Global CSS handles the animation (never in a CSS Module — this is a cross-component concern):

```css
/* styles/global.css */
.reveal {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity var(--duration-400) var(--ease-out),
              transform var(--duration-400) var(--ease-out);
}

.reveal-visible {
  opacity: 1;
  transform: none;
}

@media (prefers-reduced-motion: reduce) {
  .reveal,
  .reveal-visible {
    opacity: 1;
    transform: none;
    transition: none;
  }
}
```

---

## Responsive Breakpoints

| Breakpoint | Min Width | Usage |
|-----------|----------|-------|
| Base | — | Mobile (default, no media query) |
| `md` | 768px | Tablet |
| `lg` | 1024px | Desktop |
| `xl` | 1280px | Wide desktop |

Always mobile-first:

```css
/* Mobile (base) */
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}

/* Tablet */
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-6);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-8);
  }
}
```
