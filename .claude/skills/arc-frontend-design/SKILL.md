---
name: arc-frontend-design
description: |
  Visual design and anti-AI-slop principles for ARC Labs Studio: brand aesthetic,
  layout principles, typography, spacing, animation guidelines, design token
  usage, anti-patterns. Use when "visual design decisions", "layout spacing",
  "animation timing", "looks like AI-generated", "feels generic", "improve
  visual quality", "design review", or "brand aesthetic".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# ARC Labs Studio - Frontend Design

## Instructions

### Design Principles

1. **Space to breathe** — Generous whitespace. Apple-inspired restraint. Content needs room.
2. **Less is more** — No gratuitous decoration. Every element earns its place.
3. **Clear hierarchy** — One focal point per section. The eye needs a path.
4. **Obsessive consistency** — Same patterns everywhere. Inconsistency feels unfinished.
5. **Progressive Enhancement** — Mobile baseline. Layer up for larger screens.
6. **Accessibility by Default** — WCAG 2.2 AA from the first line. Not retrofitted.

### Brand Aesthetic

**Visual reference**: appl.studio — professional indie Apple studio aesthetic.

- **Primary**: Burgundy `#541311` (deep, premium, distinctive)
- **Accent**: Gold `#FFB42E` (warm, aspirational)
- **Background**: Near-black `#0f0f0f` (dark, sophisticated)
- **Typography**: Radley Sans (custom, Apple-adjacent)
- **Feel**: Dark, premium, minimal, high-end software studio

### Design Tokens — Always

Never hardcode visual values. Every color, size, spacing, and animation value comes from tokens:

```css
/* GOOD — tokens */
.hero {
  background-color: var(--color-surface);
  padding: var(--space-20) var(--space-6);
  color: var(--color-text-primary);
  border-radius: var(--radius-lg);
  transition: opacity var(--duration-300) var(--ease-out);
}

/* BAD — hardcoded */
.hero {
  background-color: #1a1a1a;
  padding: 80px 24px;
  color: #f5f5f7;
  border-radius: 12px;
  transition: opacity 300ms ease-out;
}
```

### Typography

- **H1**: Single per page, large, bold — the headline
- **H2**: Section titles — clear hierarchy below H1
- **H3**: Sub-sections or card titles
- **Body**: 16px base, generous line-height (1.6–1.8)
- **Max line length**: 65–75 characters for readability

```css
.headline {
  font-size: var(--text-5xl);
  font-weight: var(--font-bold);
  line-height: 1.1;
  letter-spacing: -0.02em;   /* Tight for large display text */
  color: var(--color-text-primary);
}

.body {
  font-size: var(--text-base);
  line-height: 1.7;
  color: var(--color-text-secondary);
  max-width: 65ch;
}
```

### Spacing System

Use the spacing scale consistently. Don't invent values.

```css
/* Section padding */
.section {
  padding: var(--space-20) var(--space-6);    /* Mobile: 80px top/bottom, 24px sides */
}

@media (min-width: 768px) {
  .section {
    padding: var(--space-32) var(--space-12); /* Tablet+ */
  }
}

/* Card inner spacing */
.card {
  padding: var(--space-6);   /* 24px */
  gap: var(--space-4);       /* 16px between elements */
}
```

### Animation Guidelines

- **Max duration**: 400ms for UI animations (longer feels sluggish)
- **Entrance animations**: 200–400ms, ease-out (starts fast, settles)
- **Hover transitions**: 150ms, ease-in-out (snappy, responsive)
- **Loading spinners**: loop with ease-in-out
- **Always respect `prefers-reduced-motion`**

```css
/* Entrance */
.card {
  opacity: 0;
  transform: translateY(16px);
  transition:
    opacity var(--duration-400) var(--ease-out),
    transform var(--duration-400) var(--ease-out);
}

.card.visible {
  opacity: 1;
  transform: none;
}

/* Hover */
.button {
  transition: opacity var(--duration-150) var(--ease-in-out);
}
.button:hover { opacity: 0.8; }

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
  .card { opacity: 1 !important; transform: none !important; transition: none !important; }
}
```

### Layout Patterns

**Section structure**:
```css
.section {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--space-20) var(--space-6);
}

/* Content width (narrower for readability) */
.content {
  max-width: 800px;
  margin: 0 auto;
}

/* Cards grid */
.grid {
  display: grid;
  grid-template-columns: 1fr;          /* Mobile: single column */
  gap: var(--space-6);
}

@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### Anti-Patterns (AI Slop Signals)

These patterns make designs look generic and AI-generated. Avoid them:

| Anti-pattern | Why it's wrong | Fix |
|-------------|----------------|-----|
| Loud gradient backgrounds | Screams "generated" | Solid colors + subtle texture |
| Saturated colors on large areas | Strains eyes, looks amateur | Muted brand colors |
| Box shadows on everything | Overdone depth | Use shadows sparingly, only for elevation |
| Animations > 400ms | Feels slow and self-indulgent | 150–300ms for most UI |
| Centered long paragraphs | Impossible to read | Left-align body text |
| More than 2 font weights per view | Noisy hierarchy | 2 weights: regular + bold |
| Cards with too many props | God-component | Split into focused components |
| Emoji in UI text | Looks informal and dated | Plain text |
| `rgba(0,0,0,0.5)` overlays | Not token-based | `var(--color-overlay)` |
| Responsive with `px` breakpoints in components | Brittle | Use project breakpoints only |

### Section Visual Rhythm

Alternate section backgrounds to create visual separation without borders:

```css
/* Sections alternate between two surface values */
.section:nth-child(even) {
  background-color: var(--color-surface);
}

.section:nth-child(odd) {
  background-color: var(--color-surface-elevated);
}
```

### Focus States

All interactive elements must have a clear focus ring:

```css
/* Use focus-visible, not focus */
.button:focus-visible,
.link:focus-visible,
.input:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 3px;
  border-radius: var(--radius-sm);
}
```

## Further Reading

- `Quality/design-tokens.md` — full token reference, theme system
- `Quality/accessibility.md` — WCAG 2.2 AA, focus states, reduced motion
- `Architecture/web-design-principles.md` — 6 core design principles
