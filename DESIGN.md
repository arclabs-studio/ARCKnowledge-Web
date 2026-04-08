# ARC Labs Studio — DESIGN.md

> **Design system for AI agents.** Google Stitch format.
> Drop this file into any ARC Labs web project. Your AI agent now understands the complete visual language of ARC Labs Studio.

**Last updated:** April 2026 | **Standard:** Google Stitch DESIGN.md

---

## 1. Visual Theme & Atmosphere

ARC Labs Studio is a **dark-first, premium, minimal** software studio. The visual identity is built on deliberate restraint — not minimalism as aesthetic trend, but minimalism as respect for the work. Every element earns its place. Nothing is added for decoration.

**The aesthetic:** Dark surfaces, warm accent, structured typography. Inspired by Apple's precision and editorial clarity — not copied, but channelled. The Burgundy + Gold + Near-black palette signals high-end craft software: distinctive, warm, and unmistakably professional.

**The reference:** [appl.studio](https://appl.studio) — professional indie Apple studio aesthetic.

**What this feels like:**
- Dark surfaces with generous whitespace — content breathes
- Burgundy as a primary action color: deep, premium, never loud
- Gold as an accent that warms without shouting
- Typography-forward layouts — the writing carries the design
- Transitions that feel responsive (150ms) rather than theatrical (never > 400ms)
- No gradients on large areas. No drop shadows on everything. No emoji in UI text.

**What this does not feel like:**
- Tech-bro dark mode (neon accents, saturated gradients)
- Generic SaaS (blue primary, white background, card grids everywhere)
- AI-generated UI (centered long paragraphs, too many weights, loud colors)

---

## 2. Color Palette & Roles

All colors are CSS custom properties. Always use the token name — never the raw hex value in code.

### Brand Colors

| Token | Hex | Role |
|-------|-----|------|
| `--color-brand-primary` | `#541311` | Primary actions, CTA buttons, key highlights |
| `--color-brand-secondary` | `#FFB42E` | Accents, hover underlines, active indicators |
| `--color-brand-dark` | `#000000` | Maximum contrast surface, hero backgrounds |

### Surface Hierarchy

| Token | Brand theme | Dark theme | Light theme | Role |
|-------|------------|------------|-------------|------|
| `--color-background` | `#0f0f0f` | `#000000` | `#ffffff` | Page background, deepest layer |
| `--color-surface` | `#1a1a1a` | `#0a0a0a` | `#f5f5f7` | Cards, panels, content areas |
| `--color-surface-elevated` | `#242424` | `#141414` | `#ebebeb` | Hover states, nested content, skeletons |
| `--color-surface-overlay` | `rgba(0,0,0,0.6)` | `rgba(0,0,0,0.8)` | `rgba(0,0,0,0.4)` | Modal overlays, backdrop |

### Text Colors

| Token | Brand theme | Dark theme | Light theme | Role |
|-------|------------|------------|-------------|------|
| `--color-text-primary` | `#f5f5f7` | `#ffffff` | `#1d1d1f` | Headlines, primary body, labels |
| `--color-text-secondary` | `#a1a1a6` | `#c7c7cc` | `#6e6e73` | Subheadings, captions, meta text |
| `--color-text-tertiary` | `#636366` | `#8e8e93` | `#aeaeb2` | Disabled text, placeholders |
| `--color-text-on-brand` | `#ffffff` | `#ffffff` | `#ffffff` | Text on burgundy backgrounds |

### Semantic Colors

| Token | Value | Role |
|-------|-------|------|
| `--color-focus-ring` | `#FFB42E` | Keyboard focus indicators (2px outline) |
| `--color-border` | `rgba(255,255,255,0.08)` | Subtle borders, dividers |
| `--color-border-strong` | `rgba(255,255,255,0.16)` | Input borders, stronger separators |
| `--color-error` | `#ff453a` | Error states, destructive actions |
| `--color-success` | `#30d158` | Success confirmation |
| `--color-warning` | `#ffd60a` | Warnings, non-destructive alerts |

### Theme System

Themes override token values via `[data-theme]` attribute on `:root`. The default (no attribute) is the **brand** theme.

```css
:root { /* brand theme — default */ }
[data-theme="dark"] { /* dark overrides */ }
[data-theme="light"] { /* light overrides */ }
```

---

## 3. Typography Rules

**Primary font:** Radley Sans (custom, Apple-adjacent feel)
**Fallback stack:** `system-ui, -apple-system, 'Segoe UI', sans-serif`

All typography values are CSS custom properties. Use font tokens — never raw pixel values.

### Type Hierarchy

| Role | Token | Size | Weight Token | Line Height | Letter Spacing | Usage |
|------|-------|------|-------------|-------------|----------------|-------|
| Display | `--text-6xl` | 60px | `--font-bold` | 1.0 | -0.03em | Hero headlines, maximum impact |
| H1 | `--text-5xl` | 48px | `--font-bold` | 1.1 | -0.02em | Page title (one per page) |
| H2 | `--text-4xl` | 36px | `--font-semibold` | 1.2 | -0.015em | Section titles |
| H3 | `--text-3xl` | 30px | `--font-semibold` | 1.3 | -0.01em | Sub-sections, card titles |
| H4 | `--text-2xl` | 24px | `--font-semibold` | 1.4 | -0.005em | Minor headings |
| Lead | `--text-xl` | 20px | `--font-regular` | 1.5 | 0 | Intro paragraphs, hero subtitles |
| Body | `--text-base` | 16px | `--font-regular` | 1.7 | 0 | Main content, descriptions |
| Small | `--text-sm` | 14px | `--font-regular` | 1.6 | 0.01em | Captions, meta, secondary info |
| Micro | `--text-xs` | 12px | `--font-regular` | 1.5 | 0.02em | Labels, badges, footnotes |

### Weight Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--font-regular` | 400 | Body text, descriptions |
| `--font-semibold` | 600 | Subheadings, labels, UI text |
| `--font-bold` | 700 | Headlines, primary emphasis |

**Rule: maximum 2 font weights per view.** Mixing 3+ weights creates visual noise.

### Readability Rules

- **Max line length:** 65ch for body, 75ch maximum — enforce with `max-width`
- **Body line-height:** 1.7 — generous for readability
- **Display line-height:** 1.0–1.1 — tight for large text
- **Left-align body text** — centered long paragraphs are unreadable
- Tight letter-spacing on large text (`-0.02em` at H1 and above), loose on small (`0.01–0.02em` below `--text-sm`)

---

## 4. Component Stylings

All values reference CSS tokens. Raw hex or pixel values are for reference only — always use tokens in code.

### Button — Primary

```css
.buttonPrimary {
  background-color: var(--color-brand-primary);   /* #541311 */
  color: var(--color-text-on-brand);               /* #ffffff */
  padding: var(--space-3) var(--space-6);          /* 12px 24px */
  border-radius: var(--radius-md);                 /* 8px */
  border: 1px solid transparent;
  font-size: var(--text-sm);                       /* 14px */
  font-weight: var(--font-semibold);
  line-height: 1;
  transition: opacity var(--duration-150) var(--ease-in-out);
}
.buttonPrimary:hover  { opacity: 0.85; }
.buttonPrimary:active { transform: scale(0.98); }
.buttonPrimary:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 3px;
}
.buttonPrimary:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
```

### Button — Secondary (Ghost)

```css
.buttonSecondary {
  background-color: transparent;
  color: var(--color-text-primary);
  padding: var(--space-3) var(--space-6);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border-strong);
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  transition:
    background-color var(--duration-150) var(--ease-in-out),
    border-color var(--duration-150) var(--ease-in-out);
}
.buttonSecondary:hover {
  background-color: var(--color-surface-elevated);
  border-color: rgba(255,255,255,0.24);
}
.buttonSecondary:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 3px;
}
```

### Card

```css
.card {
  background-color: var(--color-surface);
  border-radius: var(--radius-lg);                 /* 12px */
  padding: var(--space-6);                         /* 24px */
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-sm);
  transition:
    transform var(--duration-150) var(--ease-out),
    box-shadow var(--duration-150) var(--ease-out);
}
.card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}
```

### Input

```css
.input {
  background-color: var(--color-surface);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-strong);
  border-radius: var(--radius-md);
  padding: var(--space-3) var(--space-4);          /* min 44px height */
  font-size: var(--text-base);
  min-height: 44px;                               /* touch target */
  width: 100%;
  transition: border-color var(--duration-150) var(--ease-in-out);
}
.input::placeholder { color: var(--color-text-tertiary); }
.input:focus-visible {
  outline: none;
  border-color: var(--color-brand-secondary);     /* gold focus */
  box-shadow: 0 0 0 3px rgba(255,180,46,0.2);
}
.input[aria-invalid="true"] {
  border-color: var(--color-error);
  box-shadow: 0 0 0 3px rgba(255,69,58,0.2);
}
.input:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
```

### Navigation Link

```css
.navLink {
  color: var(--color-text-secondary);
  font-size: var(--text-sm);
  font-weight: var(--font-regular);
  text-decoration: none;
  position: relative;
  transition: color var(--duration-150) var(--ease-in-out);
}
.navLink::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: var(--color-brand-secondary);       /* gold underline */
  transition: width var(--duration-300) var(--ease-out);
}
.navLink:hover { color: var(--color-text-primary); }
.navLink:hover::after,
.navLink[aria-current="page"]::after { width: 100%; }
.navLink[aria-current="page"] { color: var(--color-text-primary); }
.navLink:focus-visible {
  outline: 2px solid var(--color-focus-ring);
  outline-offset: 3px;
  border-radius: var(--radius-sm);
}
```

### Section

```css
.section {
  width: 100%;
  padding: var(--space-20) var(--space-6);        /* 80px 24px mobile */
}
.section:nth-child(even) { background-color: var(--color-surface); }
.section:nth-child(odd)  { background-color: var(--color-background); }

.sectionInner {
  max-width: 1200px;
  margin: 0 auto;
}

.sectionContent {
  max-width: 800px;                               /* prose width */
  margin: 0 auto;
}
```

---

## 5. Layout Principles

### Spacing Scale

Base unit: 4px. All spacing values are multiples of 4px.

| Token | Value | Common Use |
|-------|-------|-----------|
| `--space-0` | 0 | Reset |
| `--space-1` | 4px | Icon gap, tight inline |
| `--space-2` | 8px | Button icon gap, small inline |
| `--space-3` | 12px | Button vertical padding |
| `--space-4` | 16px | Card element gap, list spacing |
| `--space-5` | 20px | Form field gap |
| `--space-6` | 24px | Card padding, section element gap |
| `--space-8` | 32px | Component spacing |
| `--space-10` | 40px | Large component gap |
| `--space-12` | 48px | Section horizontal padding (tablet+) |
| `--space-16` | 64px | Large vertical gap between components |
| `--space-20` | 80px | Section vertical padding (mobile) |
| `--space-24` | 96px | Section vertical padding (tablet) |
| `--space-32` | 128px | Section vertical padding (desktop) |

### Grid System

Mobile-first. Single column base, expanding to 2 then 3 columns.

```css
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--space-4);
}
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
    gap: var(--space-6);
  }
}
@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-8);
  }
}
```

### Max Widths

| Context | Value | Purpose |
|---------|-------|---------|
| Section container | 1200px | Full-width sections with contained content |
| Prose / content | 800px | Reading-optimized line length |
| Narrow content | 600px | Forms, single-column focused content |

### Whitespace Philosophy

- Generous section padding: 80px–128px vertically
- Sections breathe — don't stack tightly
- Cards have 24px internal padding minimum
- Alternate section backgrounds to create rhythm without visible borders
- No elements touching viewport edges on mobile (always `--space-6` horizontal padding)

---

## 6. Depth & Elevation

### Shadow Scale

| Token | CSS Value | Use When |
|-------|-----------|---------|
| `--shadow-sm` | `0 1px 3px rgba(0,0,0,0.4)` | Subtle lift, resting cards |
| `--shadow-md` | `0 4px 8px rgba(0,0,0,0.4)` | Interactive cards at rest |
| `--shadow-lg` | `0 8px 24px rgba(0,0,0,0.5)` | Hovered cards, dropdowns |
| `--shadow-xl` | `0 16px 48px rgba(0,0,0,0.6)` | Modals, popovers, dialogs |

**Rule: use shadows sparingly.** Shadows signal elevation — they should only appear where an element is genuinely above the surface. Not on headings. Not on text. Not as decoration.

### Surface Hierarchy

```
Background (--color-background)     ← deepest, page canvas
  └── Surface (--color-surface)     ← cards, panels — shadow-sm
        └── Elevated (--color-surface-elevated)  ← hover states, nested — no shadow (already up)
              └── Overlay (--color-surface-overlay) ← modals, drawers — shadow-xl
```

### Z-Index Layers

| Token | Value | Role |
|-------|-------|------|
| `--z-base` | 0 | Normal document flow |
| `--z-raised` | 10 | Dropdowns, tooltips relative to content |
| `--z-header` | 100 | Sticky navigation |
| `--z-modal` | 200 | Modal dialogs, drawers |
| `--z-overlay` | 300 | Full-screen overlays, toasts |

---

## 7. Do's and Don'ts

### Do

| Do | Why |
|----|-----|
| Use CSS tokens for every visual value | One-file design changes, theme support, AI consistency |
| Left-align all body text | Centered paragraphs are unreadable beyond 2 lines |
| Max 2 font weights per view | More weights = visual noise, not hierarchy |
| Keep all animations ≤ 400ms | Longer = sluggish, self-indulgent |
| Always pair animations with `prefers-reduced-motion` | Accessibility requirement, not optional |
| Use `focus-visible` for all interactive elements | Keyboard navigation is a requirement |
| Alternate section backgrounds for rhythm | Creates visual separation without borders |
| Use `--shadow-lg` on hover (not at rest) | Elevation change should be visible and meaningful |
| Solid colors on large areas | Muted, intentional — not loud |
| 44×44px minimum touch targets | Mobile usability requirement |

### Don't

| Don't | Why |
|-------|-----|
| Loud gradients on large areas | Screams "generated", strains eyes |
| Saturated colors on large backgrounds | Amateur, not premium |
| Box shadows on everything | Dilutes meaning of elevation |
| Animations > 400ms | Feels slow and self-congratulatory |
| Center long paragraphs | Impossible to read |
| 3+ font weights in one view | Breaks visual hierarchy |
| Emoji in UI text | Looks informal and dated |
| Hardcoded hex values in CSS | Breaks themes, impossible to maintain |
| Inline styles (`style={{ }}`) | Architecture violation |
| `!important` (except reduced-motion reset) | Architectural last resort only |
| Generic placeholder images | Use real content or a purposeful empty state |

---

## 8. Responsive Behavior

### Breakpoints

| Name | Value | Strategy |
|------|-------|---------|
| Mobile | `< 768px` | Base styles — single column, stacked layout |
| Tablet | `≥ 768px` | 2-column grids, expanded padding |
| Desktop | `≥ 1024px` | 3-column grids, full spacing scale |

**Always mobile-first:** base = mobile, use `@media (min-width: ...)` to add complexity.

### Section Padding by Breakpoint

```css
.section {
  padding: var(--space-20) var(--space-6);        /* mobile: 80px / 24px */
}
@media (min-width: 768px) {
  .section {
    padding: var(--space-24) var(--space-12);     /* tablet: 96px / 48px */
  }
}
@media (min-width: 1024px) {
  .section {
    padding: var(--space-32) var(--space-12);     /* desktop: 128px / 48px */
  }
}
```

### Touch Targets

- Minimum **44×44px** for all interactive elements on mobile
- Increase list item padding on mobile: `var(--space-4)` vs `var(--space-3)` on desktop
- Inputs: minimum `min-height: 44px`

### Collapsing Strategy

- **Navigation**: horizontal links → hamburger button (aria-expanded, aria-controls)
- **Card grids**: 3-col → 2-col → 1-col
- **Content + sidebar**: side-by-side → stacked (content first)
- **Hero headlines**: `--text-6xl` desktop → `--text-4xl` mobile

### Motion

```css
@media (prefers-reduced-motion: reduce) {
  /* Remove all transitions and animations */
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 9. Agent Prompt Guide

### Quick Color Reference

```
Brand primary (CTA)         → var(--color-brand-primary)     #541311
Brand accent (hover/active) → var(--color-brand-secondary)   #FFB42E
Background                  → var(--color-background)        #0f0f0f
Card surface                → var(--color-surface)           #1a1a1a
Elevated surface            → var(--color-surface-elevated)  #242424
Text primary                → var(--color-text-primary)      #f5f5f7
Text secondary              → var(--color-text-secondary)    #a1a1a6
Focus ring                  → var(--color-focus-ring)        #FFB42E
Border (subtle)             → var(--color-border)            rgba(255,255,255,0.08)
Border (strong)             → var(--color-border-strong)     rgba(255,255,255,0.16)
Error                       → var(--color-error)             #ff453a
```

### Key Token Quick Reference

```
Typography: --text-xs/sm/base/lg/xl/2xl/3xl/4xl/5xl/6xl
Weights:    --font-regular (400) --font-semibold (600) --font-bold (700)
Spacing:    --space-1(4px) --space-2(8px) --space-3(12px) --space-4(16px)
            --space-6(24px) --space-8(32px) --space-12(48px) --space-20(80px) --space-32(128px)
Radius:     --radius-sm --radius-md --radius-lg --radius-full
Shadow:     --shadow-sm --shadow-md --shadow-lg --shadow-xl
Duration:   --duration-150 --duration-300 --duration-400
Easing:     --ease-in-out --ease-out --ease-spring
Z-index:    --z-raised(10) --z-header(100) --z-modal(200) --z-overlay(300)
```

### Ready-to-Use Prompts

**Hero section:**
> "Create a hero section using ARC Labs DESIGN.md. Full-width, background `var(--color-background)`, headline at `--text-5xl` Radley Sans `--font-bold` line-height 1.1 letter-spacing -0.02em color `--color-text-primary`, subtitle `--text-xl` `--font-regular` color `--color-text-secondary`, CTA button with `--color-brand-primary` background. Section padding `--space-20` / `--space-6` mobile, `--space-32` / `--space-12` desktop."

**Card grid:**
> "Create a 3-column card grid using ARC Labs DESIGN.md tokens. Cards: `--color-surface` background, `--radius-lg` border-radius, `--space-6` padding, `--shadow-sm` at rest, `--shadow-lg` + `translateY(-2px)` on hover. Grid: 1-col mobile, 2-col 768px, 3-col 1024px. Gap: `--space-4` mobile, `--space-6` tablet, `--space-8` desktop."

**Contact form:**
> "Create a contact form using ARC Labs DESIGN.md. Inputs: `--color-surface` bg, `--color-border-strong` border, `--radius-md`, `min-height: 44px`, gold focus ring (`--color-brand-secondary`). Submit button: primary style (`--color-brand-primary`). Validate on blur. Show loading/success/error states with `aria-busy` and `role=alert`."

**Navigation bar:**
> "Create a sticky nav using ARC Labs DESIGN.md. Background `--color-background` with `--shadow-md`, `z-index: var(--z-header)`. Logo left, nav links right. Links: `--text-sm` `--font-regular` `--color-text-secondary`, gold underline reveal on hover (`--color-brand-secondary`). Active link via `aria-current='page'`. Mobile: hamburger with `aria-expanded`."

### Cross-References

| Need | Go to |
|------|-------|
| Token implementation guide | `Quality/design-tokens.md` |
| CSS code patterns (animation, layout) | `.claude/skills/arc-frontend-design` |
| WCAG 2.2 AA accessibility | `.claude/skills/arc-accessibility` |
| UX patterns (forms, loading, error) | `.claude/skills/arc-ux-patterns` |
| Component architecture | `CLAUDE.md` + `.claude/skills/arc-presentation-layer` |
| Performance (Core Web Vitals) | `.claude/skills/arc-react-performance` |

---

> **Note:** These are ARC Labs Studio default tokens. Project-specific overrides in `tokens.css` take precedence. When a project diverges, trust `tokens.css` — update this file if the divergence is intentional and permanent.
